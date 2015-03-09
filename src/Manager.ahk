/*
  bug.n -- tiling window management
  Copyright (c) 2010-2015 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.0
*/

Manager_init()
{
  Local doRestore

  Manager_setWindowBorders()
  Bar_getHeight()
  ; axes, dimensions, percentage, flipped, gapWidth
  Manager_layoutDirty := 0
  ; New/closed windows, active changed,
  Manager_windowsDirty := 0
  Manager_aMonitor := 1

  doRestore := 0
  If (Config_autoSaveSession = "ask")
  {
    MsgBox, 0x4, , Would you like to restore an auto-saved session?
    IfMsgBox Yes
      doRestore := 1
  }
  Else If (Config_autoSaveSession = "auto")
  {
    doRestore := 1
  }

  SysGet, Manager_monitorCount, MonitorCount
  Loop, % Manager_monitorCount
  {
    Monitor_init(A_Index, doRestore)
  }
  Bar_initCmdGui()
  If Not Config_showTaskBar
    Monitor_toggleTaskBar()

  Manager_hideShow      := False
  Bar_hideTitleWndIds   := ""
  Manager_allWndIds     := ""
  Manager_managedWndIds := ""
  Manager_initial_sync(doRestore)

  Bar_updateStatus()
  Bar_updateTitle()
  Loop, % Manager_monitorCount
  {
    View_arrange(A_Index, Monitor_#%A_Index%_aView_#1)
    Bar_updateView(A_Index, Monitor_#%A_Index%_aView_#1)
  }

  Manager_registerShellHook()
  SetTimer, Manager_doMaintenance, %Config_maintenanceInterval%
  SetTimer, Bar_loop, %Config_readinInterval%
}

Manager_activateMonitor(i, d = 0) {
  Local aView, aWndHeight, aWndId, aWndWidth, aWndX, aWndY, v, wndId

  If (Manager_monitorCount > 1) {
    aView := Monitor_#%Manager_aMonitor%_aView_#1
    WinGet, aWndId, ID, A
    If WinExist("ahk_id" aWndId) And InStr(View_#%Manager_aMonitor%_#%aView%_wndIds, aWndId ";") And Window_isProg(aWndId) {
      WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
      If (Monitor_get(aWndX + aWndWidth / 2, aWndY + aWndHeight / 2) = Manager_aMonitor)
        View_setActiveWindow(Manager_aMonitor, aView, aWndId)
    }

    ;; Manually set the active monitor.
    If (i = 0)
      i := Manager_aMonitor
    Manager_aMonitor := Manager_loop(i, d, 1, Manager_monitorCount)
    v := Monitor_#%Manager_aMonitor%_aView_#1
    wndId := View_getActiveWindow(Manager_aMonitor, v)
    Debug_logMessage("DEBUG[1] Manager_activateMonitor: Manager_aMonitor: " Manager_aMonitor ", i: " i ", d: " d ", wndId: " wndId, 1)
    Manager_winActivate(wndId)
  }
}

Manager_applyRules(wndId, ByRef isManaged, ByRef m, ByRef tags, ByRef isFloating, ByRef isDecorated, ByRef hideTitle, ByRef action) {
  Local i, wndClass, wndTitle
  Local rule0, rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8, rule9, rule10

  isManaged   := True
  m           := 0
  tags        := 0
  isFloating  := False
  isDecorated := False
  hideTitle   := False
  action      := ""

  WinGetClass, wndClass, ahk_id %wndId%
  WinGetTitle, wndTitle, ahk_id %wndId%
  If (wndClass Or wndTitle) {
    Loop, % Config_ruleCount {
      ;; The rules are traversed in reverse order.
      i := Config_ruleCount - A_Index + 1
      StringSplit, rule, Config_rule_#%i%, `;
      If RegExMatch(wndClass . ";" . wndTitle, rule1 . ";" . rule2) And (rule3 = "" Or %rule3%(wndId)) {
        isManaged   := rule4
        m           := rule5
        tags        := rule6
        isFloating  := rule7
        isDecorated := rule8
        hideTitle   := rule9
        action      := rule10
        ;; The first matching rule is returned, i. e. the last in the original rder of Config_rule.
        Break
      }
    }
    Debug_logMessage("DEBUG[6] Manager_applyRules: class: " wndClass ", title: " wndTitle ", wndId: " wndId ", action: " action, 6)
  } Else {
    isManaged := False
    If wndTitle
      hideTitle := True
  }
}

Manager_cleanup()
{
  Local aWndId, m, ncmSize, ncm, wndIds

  WinGet, aWndId, ID, A

  Manager_restoreWindowBorders()

  ;; Show borders and title bars.
  StringTrimRight, wndIds, Manager_managedWndIds, 1
  Manager_hideShow := True
  Loop, PARSE, wndIds, `;
  {
    Window_show(A_LoopField)
    If Not Config_showBorder
      Window_set(A_LoopField, "Style", "+0x40000")
    Window_set(A_LoopField, "Style", "+0xC00000")
  }

  ;; Show the task bar.
  WinShow, Start ahk_class Button
  WinShow, ahk_class Shell_TrayWnd
  Manager_hideShow := False

  ;; Restore window positions and sizes.
  Loop, % Manager_monitorCount
  {
    m := A_Index
    Monitor_#%m%_showBar := False
    Monitor_#%m%_showTaskBar := True
    Monitor_getWorkArea(m)
    Loop, % Config_viewCount
    {
      View_arrange(m, A_Index, True)
    }
  }
  Window_set(aWndId, "AlwaysOnTop", "On")
  Window_set(aWndId, "AlwaysOnTop", "Off")

  DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_REMOVE := 0x1), "UInt", &Bar_appBarData)
  ;; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)
}

Manager_closeWindow() {
  Local aWndId

  WinGet, aWndId, ID, A
  If Window_isProg(aWndId)
    Window_close(aWndId)
}

; Asynchronous management of various WM properties.
; We want to make sure that we can recover the layout and windows in the event of
; unexpected problems.
; Periodically check for changes to these things and save them somewhere (not over
; user-defined files).
Manager_doMaintenance:
  Critical

  ;; @TODO: Manager_sync?
  If Not (Config_autoSaveSession = "off") And Not (Config_autoSaveSession = "False")
    Manager_saveState()
Return

Manager_getWindowInfo()
{
  Local aWndClass, aWndHeight, aWndId, aWndMinMax, aWndPId, aWndPName, aWndStyle, aWndTitle, aWndWidth, aWndX, aWndY, rule, text, v

  WinGet, aWndId, ID, A
  WinGetClass, aWndClass, ahk_id %aWndId%
  WinGetTitle, aWndTitle, ahk_id %aWndId%
  WinGet, aWndPName, ProcessName, ahk_id %aWndId%
  WinGet, aWndPId, PID, ahk_id %aWndId%
  WinGet, aWndStyle, Style, ahk_id %aWndId%
  WinGet, aWndMinMax, MinMax, ahk_id %aWndId%
  WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
  text := "ID: " aWndId "`nclass:`t" aWndClass "`ntitle:`t" aWndTitle
  rule := "Config_rule=" aWndClass ";" aWndTitle ";"
  If InStr(Manager_managedWndIds, aWndId ";")
    rule .= ";1"
  Else
    rule .= ";0"
  rule .= ";" Window_#%aWndId%_monitor ";" Window_#%aWndId%_tags ";" Window_#%aWndId%_isFloating ";" Window_#%aWndId%_isDecorated
  If InStr(Bar_hiddenWndIds, aWndId) {
    text .= " (hidden)"
    rule .= ";1;"
  } Else
    rule .= ";0;"
  If (aWndMinMax = 1)
    rule .= "maximize"
  text .= "`nprocess:`t" aWndPName " [" aWndPId "]`nstyle:`t" aWndStyle "`nmetrics:`tx: " aWndX ", y: " aWndY ", width: " aWndWidth ", height: " aWndHeight "`ntags:`t" Window_#%aWndId%_tags
  If Window_#%aWndId%_isFloating
    text .= " (floating)"
  text .= "`n`n" rule
  MsgBox, 260, bug.n: Window Information, % text "`n`nCopy text to clipboard?"
  IfMsgBox Yes
    Clipboard := text
}

Manager_getWindowList()
{
  Local text, v, aWndId, wndIds, aWndTitle

  v := Monitor_#%Manager_aMonitor%_aView_#1
  aWndId := View_getActiveWindow(Manager_aMonitor, v)
  WinGetTitle, aWndTitle, ahk_id %aWndId%
  text := "Active Window`n" aWndId ":`t" aWndTitle

  StringTrimRight, wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, 1
  text .= "`n`nWindow List"
  Loop, PARSE, wndIds, `;
  {
    WinGetTitle, wndTitle, ahk_id %A_LoopField%
    text .= "`n" A_LoopField ":`t" wndTitle
  }

  MsgBox, 260, bug.n: Window List, % text "`n`nCopy text to clipboard?"
  IfMsgBox Yes
    Clipboard := text
}

Manager_lockWorkStation()
{
  Global Config_shellMsgDelay

  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 0
  Sleep, % Config_shellMsgDelay
  DllCall("LockWorkStation")
  Sleep, % 4 * Config_shellMsgDelay
  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 1
}
;; Unambiguous: Re-use WIN+L as a hotkey in bug.n (http://www.autohotkey.com/community/viewtopic.php?p=500903&sid=eb3c7a119259b4015ff045ef80b94a81#p500903)

Manager_loop(index, increment, lowerBound, upperBound) {
  If (upperBound <= 0) Or (upperBound < lowerBound) Or (upperBound = 0)
    Return, 0

  numberOfIndexes := upperBound - lowerBound + 1
  lowerBoundBasedIndex := index - lowerBound
  lowerBoundBasedIndex := Mod(lowerBoundBasedIndex + increment, numberOfIndexes)
  If (lowerBoundBasedIndex < 0)
    lowerBoundBasedIndex += numberOfIndexes

  Return, lowerBound + lowerBoundBasedIndex
}

Manager__setWinProperties(wndId, isManaged, m, tags, isDecorated, isFloating, hideTitle, action = "")
{
  Local a

  If Not Instr(Manager_allWndIds, wndId ";")
    Manager_allWndIds .= wndId ";"

  If (isManaged)
  {
    If (action = "close" Or action = "maximize")
      Window_%action%(wndId)

    Manager_managedWndIds .= wndId ";"
    Monitor_moveWindow(m, wndId)
    Window_#%wndId%_tags        := tags
    Window_#%wndId%_isDecorated := isDecorated
    Window_#%wndId%_isFloating  := isFloating
    Window_#%wndId%_area        := 0

    If Not Config_showBorder
      Window_set(wndId, "Style", "-0x40000")
    If Not Window_#%wndId%_isDecorated
      Window_set(wndId, "Style", "-0xC00000")

    a := Window_#%wndId%_tags & (1 << (Monitor_#%m%_aView_#1 - 1))
    If a
    {
      ;; A newly created window defines the active monitor, if it is visible.
      Manager_aMonitor := m
      Manager_winActivate(wndId)
    }
    Else
    {
      Manager_hideShow := True
      Window_hide(wndId)
      Manager_hideShow := False
    }
  }
  If hideTitle
    Bar_hideTitleWndIds .= wndId . ";"

  Return, a
}

;; Accept a window to be added to the system for management.
;; Provide a monitor and view preference, but don't override the config.
Manager_manage(preferredMonitor, preferredView, wndId)
{
  Local a, action, c0, hideTitle, i, isDecorated, isFloating, isManaged, l, m, n, replace, search, tags, body
  Local wndControlList0, wndId0, wndIds, wndX, wndY, wndWidth, wndHeight

  ;; Manage any window only once.
  If InStr(Manager_allWndIds, wndId ";")
    Return

  body := 0
  If Window_isGhost(wndId)
  {
    Debug_logMessage("DEBUG[2] A window has given up the ghost (Ghost wndId: " . wndId . ")", 2)
    body := Window_findHung(wndId)
    If body
    {
      isManaged := InStr(Manager_managedWndIds, body ";")
      m := Window_#%body%_monitor
      tags := Window_#%body%_tags
      isDecorated := Window_#%body%_isDecorated
      isFloating := Window_#%body%_isFloating
      hideTitle := InStr(Bar_hideTitleWndIds, body ";")
      action := ""
    }
    Else
    {
      Debug_logMessage("DEBUG[1] No body could be found for ghost wndId: " . wndId, 1)
    }
  }

  ;; Apply rules if the window is either a normal window or a ghost without a body.
  If (body = 0)
  {
    Manager_applyRules(wndId, isManaged, m, tags, isFloating, isDecorated, hideTitle, action)
    If (m = 0)
      m := preferredMonitor
    If (m < 0)
      m := 1
    If (m > Manager_monitorCount)    ;; If the specified monitor is out of scope, set it to the max. monitor.
      m := Manager_monitorCount
    If (tags = 0)
      tags := 1 << (preferredView - 1)
  }

  a := Manager__setWinProperties( wndId, isManaged, m, tags, isDecorated, isFloating, hideTitle, action)

  ; Do view placement.
  If isManaged {
    Loop, % Config_viewCount
      If (Window_#%wndId%_tags & (1 << (A_Index - 1))) {
        If (body) {
          ; Try to position near the body.
          View_ghostWindow(m, A_Index, body, wndId)
        }
        Else
          View_addWindow(m, A_Index, wndId)
      }
  }

  Return, a
}

Manager_maximizeWindow() {
  Local aWndId

  WinGet, aWndId, ID, A
  If Not Window_#%aWndId%_isFloating
    View_toggleFloatingWindow(aWndId)
  Window_set(aWndId, "Top", "")

  Window_move(aWndId, Monitor_#%Manager_aMonitor%_x, Monitor_#%Manager_aMonitor%_y, Monitor_#%Manager_aMonitor%_width, Monitor_#%Manager_aMonitor%_height)
}

Manager_minimizeWindow() {
  Local aView, aWndId

  WinGet, aWndId, ID, A
  aView := Monitor_#%Manager_aMonitor%_aView_#1
  StringReplace, View_#%Manager_aMonitor%_#%aView%_aWndIds, View_#%Manager_aMonitor%_#%aView%_aWndIds, % aWndId ";",, All
  If Not Window_#%aWndId%_isFloating
    View_toggleFloatingWindow(aWndId)
  Window_set(aWndId, "Bottom", "")

  Window_minimize(aWndId)
}

Manager_moveWindow() {
  Local aWndId, SC_MOVE, WM_SYSCOMMAND

  WinGet, aWndId, ID, A
  If Not Window_#%aWndId%_isFloating
    View_toggleFloatingWindow(aWndId)
  Window_set(aWndId, "Top", "")

  WM_SYSCOMMAND = 0x112
  SC_MOVE       = 0xF010
  SendMessage, WM_SYSCOMMAND, SC_MOVE, , , ahk_id %aWndId%
}

Manager_onDisplayChange(a, wParam, uMsg, lParam) {
  Debug_logMessage("DEBUG[1] Manager_onDisplayChange( a: " . a . ", uMsg: " . uMsg . ", wParam: " . wParam . ", lParam: " . lParam . " )", 1)
  MsgBox, 0x4, , Would you like to reset the monitor configuration?
  IfMsgBox Yes
    Manager_resetMonitorConfiguration()
}

/*
  Possible indications for a ...
    new window: 1 (started by Windows Explorer) or 6 (started by cmd, shell or Win+E).
      There doesn't seem to be a reliable way to get all application starts.
    closed window: 2 (always?) or 13 (ghost)
    focus change: 4 or 32772
    title change: 6 or 32774
*/
Manager_onShellMessage(wParam, lParam) {
  Local a, isChanged, aWndClass, aWndHeight, aWndId, aWndTitle, aWndWidth, aWndX, aWndY, i, m, t, wndClass, wndId, wndId0, wndIds, wndIsDesktop, wndIsHidden, wndTitle, x, y
  ;; HSHELL_* become global.

  ;; MESSAGE NAME AND         ... NUMBER    COMMENTS, POSSIBLE EVENTS
  HSHELL_WINDOWCREATED        :=  1         ;; window shown
  HSHELL_WINDOWDESTROYED      :=  2         ;; window hidden, destroyed or deactivated
  HSHELL_ACTIVATESHELLWINDOW  :=  3
  HSHELL_WINDOWACTIVATED      :=  4         ;; window title changed, window activated (by mouse, Alt+Tab or hotkey); alternative message: 32772
  HSHELL_GETMINRECT           :=  5
  HSHELL_REDRAW               :=  6         ;; window title changed
  HSHELL_TASKMAN              :=  7
  HSHELL_LANGUAGE             :=  8
  HSHELL_SYSMENU              :=  9
  HSHELL_ENDTASK              := 10
  HSHELL_ACCESSIBILITYSTATE   := 11
  HSHELL_APPCOMMAND           := 12
  ;; The following two are seen when a hung window recovers.
  HSHELL_WINDOWREPLACED       := 13         ;; hung window recovered and replaced the ghost window (lParam indicates the ghost window.)
  HSHELL_WINDOWREPLACING      := 14         ;; hung window recovered (lParam indicates the previously hung and now recovered window.)
  HSHELL_HIGHBIT              := 32768      ;; 0x8000
  HSHELL_FLASH                := 32774      ;; (HSHELL_REDRAW|HSHELL_HIGHBIT); window signalling an application update (The window is flashing due to some event, one message for each flash.)
  HSHELL_RUDEAPPACTIVATED     := 32772      ;; (HSHELL_WINDOWACTIVATED|HSHELL_HIGHBIT); full-screen app or root-privileged window activated? alternative message: 4
  ;; Any message may be missed, if bug.n is hung or they come in too quickly.

  SetFormat, Integer, hex
  lParam := lParam + 0
  SetFormat, Integer, d

  Debug_logMessage("DEBUG[2] Manager_onShellMessage( wParam: " . wParam . ", lParam: " . lParam . " )", 2)

  wndIsHidden := Window_getHidden(lParam, wndClass, wndTitle)
  If wndIsHidden {
    ;; If there is no window class or title, it is assumed that the window is not identifiable.
    ;;   The problem was, that i. a. claws-mail triggers Manager_sync, but the application window
    ;;   would not be ready for being managed, i. e. class and title were not available. Therefore more
    ;;   attempts were needed.
    Return
  }

  wndIsDesktop := (lParam = 0)
  If wndIsDesktop {
    WinGetClass, wndClass, A
    WinGetTitle, wndTitle, A
  }
  WinGet, aWndId, ID, A
  WinGetClass, aWndClass, ahk_id %aWndId%
  WinGetTitle, aWndTitle, ahk_id %aWndId%
  If ((wParam = 4 Or wParam = 32772) And (aWndClass = "WorkerW" And aWndTitle = "" Or lParam = 0 And aWndClass = "Progman" And aWndTitle = "Program Manager"))
  {
    MouseGetPos, x, y
    m := Monitor_get(x, y)
    ;; The current position of the mouse cursor defines the active monitor, if the desktop has been activated.
    If m
      Manager_aMonitor := m
    Bar_updateTitle()
  }

  ;; This was previously inactive due to `HSHELL_WINDOWREPLACED` not being defined in this function.
  ;; Afterwards it caused problems managing new windows, when messages come in too quickly.
;  If (wParam = HSHELL_WINDOWREPLACED)
;  {    ;; This shouldn't need a redraw because the window was supposedly replaced.
;    Manager_unmanage(lParam)
;  }

; If (wParam = 14)
; {    ;; Window recovered from being hung. Maybe force a redraw.
; }

  ;; @todo: There are two problems with the use of Manager_hideShow:
  ;;   1) If Manager_hideShow is set when we hit this block, we won't take some actions that should eventually be taken.
  ;;      This _may_ explain why some windows never get picked up when spamming Win+e
  ;;   2) There is a race condition between the time that Manager_hideShow is checked and any other action which we are
  ;;      trying to protect against. If another process (hotkey) enters a hideShow block after Manager_hideShow has
  ;;      been checked here, bad things could happen. I've personally observed that windows may be permanently hidden.
  ;;   Look into the use of AHK synchronization primitives.
  If (wParam = 1 Or wParam = 2 Or wParam = 4 Or wParam = 6 Or wParam = 32772) And lParam And Not Manager_hideShow
  {
    isChanged := Manager_sync(wndIds)
    If wndIds
      isChanged := False

    If isChanged
    {
      If Config_dynamicTiling
        View_arrange(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1)
      Bar_updateView(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1)
    }

    If (Manager_monitorCount > 1)
    {
      WinGet, aWndId, ID, A
      WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
      m := Monitor_get(aWndX + aWndWidth / 2, aWndY + aWndHeight / 2)
      Debug_logMessage("DEBUG[1] Manager_onShellMessage: Manager_monitorCount: " Manager_monitorCount ", Manager_aMonitor: " Manager_aMonitor ", m: " m ", aWndId: " aWndId, 1)
      ;; The currently active window defines the active monitor.
      If m
        Manager_aMonitor := m
    }

    If wndIds
    {    ;; If there are new (unrecognized) windows, which are hidden ...
      If (Config_onActiveHiddenWnds = "view")
      {  ;; ... change the view to show the first hidden window
        wndId := SubStr(wndIds, 1, InStr(wndIds, ";") - 1)
        Loop, % Config_viewCount
        {
          If (Window_#%wndId%_tags & 1 << A_Index - 1)
          {
            Debug_logMessage("DEBUG[3] Switching views because " . wndId . " is considered hidden and active", 3)
            ;; A newly created window defines the active monitor, if it is visible.
            Manager_aMonitor := Window_#%wndId%_monitor
            Monitor_activateView(A_Index)
            Break
          }
        }
      }
      Else
      {  ;; ... re-hide them
        StringTrimRight, wndIds, wndIds, 1
        StringSplit, wndId, wndIds, `;
        If (Config_onActiveHiddenWnds = "hide")
        {
          Loop, % wndId0
          {
            Window_hide(wndId%A_Index%)
          }
        }
        Else If (Config_onActiveHiddenWnds = "tag")
        {
          ;; ... or tag all of them for the current view.
          t := Monitor_#%Manager_aMonitor%_aView_#1
          Loop, % wndId0
          {
            wndId := wndId%A_Index%
            View_#%Manager_aMonitor%_#%t%_wndIds := wndId ";" View_#%Manager_aMonitor%_#%t%_wndIds
            View_setActiveWindow(Manager_aMonitor, t, wndId)
            Window_#%wndId%_tags += 1 << t - 1
          }
          Bar_updateView(Manager_aMonitor, t)
          If Config_dynamicTiling
            View_arrange(Manager_aMonitor, t)
        }
      }
    }

    If InStr(Manager_managedWndIds, lParam ";") {
      View_setActiveWindow(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1, lParam)
      If Window_#%lParam%_isMinimized {
        Window_#%lParam%_isFloating := False
        Window_#%lParam%_isMinimized := False
        View_arrange(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1)
      }
    }

    ;; This is a workaround for a redrawing problem of the bug.n bar, which
    ;; seems to get lost, when windows are created or destroyed under the
    ;; following conditions.
    If (Manager_monitorCount > 1) And (Config_verticalBarPos = "tray") {
      Loop, % (Manager_monitorCount - 1) {
        i := A_Index + 1
        Bar_updateLayout(i)
        Bar_updateStatic(i)
        Loop, % Config_viewCount
          Bar_updateView(i, A_Index)
      }
      Bar_updateStatus()
    }
    Bar_updateTitle()
  }
}

Manager_registerShellHook() {
  WM_DISPLAYCHANGE := 126   ;; This message is sent when the display resolution has changed.
  Gui, +LastFound
  hWnd := WinExist()
  WinGetClass, wndClass, ahk_id %hWnd%
  WinGetTitle, wndTitle, ahk_id %hWnd%
  DllCall("RegisterShellHookWindow", "UInt", hWnd)    ;; Minimum operating systems: Windows 2000 (http://msdn.microsoft.com/en-us/library/ms644989(VS.85).aspx)
  Debug_logMessage("DEBUG[1] Manager_registerShellHook; hWnd: " . hWnd . ", wndClass: " . wndClass . ", wndTitle: " . wndTitle, 1)
  msgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
  OnMessage(msgNum, "Manager_onShellMessage")
  OnMessage(WM_DISPLAYCHANGE, "Manager_onDisplayChange")
}
;; SKAN: How to Hook on to Shell to receive its messages? (http://www.autohotkey.com/forum/viewtopic.php?p=123323#123323)

Manager_resetMonitorConfiguration() {
  Local GuiN, hWnd, i, m, wndClass, wndIds, wndTitle

  m := Manager_monitorCount
  SysGet, Manager_monitorCount, MonitorCount
  If (Manager_monitorCount < m) {
    Loop, % m - Manager_monitorCount {
      i := Manager_monitorCount + A_Index
      GuiN := (i - 1) + 1
      Gui, %GuiN%: Destroy
      Loop, % Config_viewCount {
        If View_#%i%_#%A_Index%_wndIds {
          View_#1_#%A_Index%_wndIds := View_#%i%_#%A_Index%_wndIds View_#1_#%A_Index%_wndIds

          StringTrimRight, wndIds, View_#%i%_#%A_Index%_wndIds, 1
          Loop, PARSE, wndIds, `;
          {
            Loop, % Config_viewCount {
              StringReplace, View_#%i%_#%A_Index%_wndIds, View_#%i%_#%A_Index%_wndIds, %A_LoopField%`;,
              View_setActiveWindow(i, A_Index, 0)
            }
            Monitor_moveWindow(1, A_LoopField)
          }

          ;; Manually set the active monitor.
          Manager_aMonitor := 1
        }
      }
    }
    m := Manager_monitorCount
  } Else If (Manager_monitorCount > m) {
    Loop, % Manager_monitorCount - m
      Monitor_init(m + A_Index, True)
  }
  Loop, % m {
    Monitor_getWorkArea(A_Index)
    Bar_init(A_Index)
  }
  Manager_saveState()
  Loop, % Manager_monitorCount {
    View_arrange(A_Index, Monitor_#%A_Index%_aView_#1)
    Bar_updateView(A_Index, Monitor_#%A_Index%_aView_#1)
  }
  Manager__restoreWindowState(Main_autoWindowState)
  Bar_updateStatus()
  Bar_updateTitle()

  Gui, +LastFound
  hWnd := WinExist()
  WinGetClass, wndClass, ahk_id %hWnd%
  WinGetTitle, wndTitle, ahk_id %hWnd%
  DllCall("RegisterShellHookWindow", "UInt", hWnd)    ;; Minimum operating systems: Windows 2000 (http://msdn.microsoft.com/en-us/library/ms644989(VS.85).aspx)
  Debug_logMessage("DEBUG[1] Manager_registerShellHook; hWnd: " . hWnd . ", wndClass: " . wndClass . ", wndTitle: " . wndTitle, 1)
}

Manager_restoreWindowBorders()
{
  Local ncm, ncmSize

  If Config_selBorderColor
    DllCall("SetSysColors", "Int", 1, "Int*", 10, "UInt*", Manager_normBorderColor)
  If (Config_borderWidth > 0) Or (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
  {
    ncmSize := VarSetCapacity(ncm, 4 * (A_OSVersion = WIN_VISTA ? 11 : 10) + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), 0)
    NumPut(ncmSize, ncm, 0, "UInt")
    DllCall("SystemParametersInfo", "UInt", 0x0029, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
    If (Config_borderWidth > 0)
      NumPut(Manager_borderWidth, ncm, 4, "Int")
    If (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
      NumPut(Manager_borderPadding, ncm, 40 + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), "Int")
    DllCall("SystemParametersInfo", "UInt", 0x002a, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
  }
}

;; Restore previously saved window state.
;; If the state is completely different, this function won't do much. However, if restoring from a crash
;; or simply restarting bug.n, it should completely recover the window state.
Manager__restoreWindowState(filename) {
  Local vidx, widx, i, j, m, v, candidate_set, detectHidden, view_set, excluded_view_set, view_m0, view_v0, view_list0, wnds0, items0, wndPName, view_var, isManaged, isFloating, isDecorated, hideTitle

  If Not FileExist(filename)
    Return

  widx := 1
  vidx := 1

  view_set := ""
  excluded_view_set := ""

  ;; Read all interesting things from the file.
  Loop, READ, %filename%
  {
    If (SubStr(A_LoopReadLine, 1, 5) = "View_") {
      i := InStr(A_LoopReadLine, "#")
      j := InStr(A_LoopReadLine, "_", false, i)
      m := SubStr(A_LoopReadLine, i + 1, j - i - 1)
      i := InStr(A_LoopReadLine, "#", false, j)
      j := InStr(A_LoopReadLine, "_", false, i)
      v := SubStr(A_LoopReadLine, i + 1, j - i - 1)

      i := InStr(A_LoopReadLine, "=", j + 1)


      If (m <= Manager_monitorCount) And ( v <= Config_viewCount ) {
        view_list%vidx% := SubStr(A_LoopReadLine, i + 1)
        view_m%vidx% := m
        view_v%vidx% := v
        view_set := view_set . view_list%vidx%
        vidx := vidx + 1
      } Else {
        excluded_view_set := excluded_view_set . view_list%vidx%
        Debug_logMessage("View (" . m . ", " . v . ") is no longer available (" . vidx . ")", 0)
      }
    } Else If (SubStr(A_LoopReadLine, 1, 7) = "Window ") {
      wnds%widx% := SubStr(A_LoopReadLine, 8)
      widx := widx + 1
    }
  }

  ;Debug_logMessage("view_set: " . view_set, 1)
  ;Debug_logMessage("excluded_view_set: " . excluded_view_set, 1)

  candidate_set := ""

  ; Scan through all defined windows. Create a candidate set of windows based on whether the properties of existing windows match.
  Loop, % (widx - 1) {
    StringSplit, items, wnds%A_Index%, `;
    If (items0 < 9) {
      Debug_logMessage("Window '" . wnds%A_Index% . "' could not be processed due to parse error", 0)
      Continue
    }

    i := 1
    i := items%i%
    j := 2

    detectHidden := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGet, wndPName, ProcessName, ahk_id %i%
    DetectHiddenWindows, %detectHidden%
    If Not ( items%j% = wndPName ) {
      Debug_logMessage("Window ahk_id " . i . " process '" . wndPName . "' doesn't match expected '" . items%j% . "', forgetting this window", 0)
      Continue
    }

    j := 8
    isManaged := items%j%

    ; If Managed
    If ( items%j% ) {
      If ( InStr(view_set, i) = 0) {
        If ( InStr(excluded_view_set, i) )
          Debug_logMessage("Window ahk_id " . i . " is being ignored because it no longer belongs to an active view", 0)
        Else
          Debug_logMessage("Window ahk_id " . i . " is being ignored because it doesn't exist in any views", 0)
        Continue
      }
    }

    ; Set up the window.

    j := 3
    m := items%j%
    j := 4
    v := items%j%
    j := 5
    isFloating := items%j%
    j := 6
    isDecorated := items%j%
    j := 7
    hideTitle := items%j%

    Manager__setWinProperties(i, isManaged, m, v, isDecorated, isFloating, hideTitle )
    ;Window_hide(i)

    candidate_set := candidate_set . i . ";"
  }

  ;Debug_logMessage("candidate_set: " . candidate_set, 1)

  ; Set up all views. Must filter the window list by those from the candidate set.
  Loop, % (vidx - 1) {
    StringSplit, items, view_list%A_Index%, `;
    view_set := ""
    Loop, % (items0 - 1) {
      If ( InStr(candidate_set, items%A_Index% ) > 0 )
        view_set := view_set . items%A_Index% . ";"
    }
    view_var := "View_#" . view_m%A_Index% . "_#" . view_v%A_Index% . "_wndIds"
    %view_var% := view_set
  }
}

Manager_saveState() {
  Critical
  Global Config_filePath, Config_viewCount, Main_autoLayout, Main_autoWindowState, Manager_layoutDirty, Manager_monitorCount, Manager_windowsDirty

  Debug_logMessage("DEBUG[2] Manager_saveState", 2)

  ;; @TODO: Check for changes to the layout.
  ;If Manager_layoutDirty {
    Debug_logMessage("DEBUG[2] Manager_saveState: " Main_autoLayout, 2)
    Config_saveSession(Config_filePath, Main_autoLayout)
    Manager_layoutDirty := 0
  ;}

  ;; @TODO: Check for changes to windows.
  ;If Manager_windowsDirty {
    Debug_logMessage("DEBUG[2] Manager_saveState: " Main_autoWindowState, 2)
    Manager_saveWindowState(Main_autoWindowState, Manager_monitorCount, Config_viewCount)
    Manager_windowsDirty := 0
  ;}
}

Manager_saveWindowState(filename, nm, nv) {
  Local allWndId0, allWndIds, detectHidden, wndPName, title, text, monitor, wndId, view, isManaged, isTitleHidden

  text := "; bug.n - tiling window management`n; @version " VERSION "`n`n"

  tmpfname := filename . ".tmp"
  FileDelete, %tmpfname%

  ; Dump window ID and process name. If these two don't match an existing process, we won't try
  ;   to recover that window.
  StringTrimRight, allWndIds, Manager_allWndIds, 1
  StringSplit, allWndId, allWndIds, `;
  detectHidden := A_DetectHiddenWindows
  DetectHiddenWindows, On
  Loop, % allWndId0 {
    wndId := allWndId%A_Index%
    WinGet, wndPName, ProcessName, ahk_id %wndId%
    ; Include title for informative reasons.
    WinGetTitle, title, ahk_id %wndId%

    ; wndId;processName;Tags;Floating;Decorated;HideTitle;Managed;Title

    isManaged := InStr(Manager_managedWndIds, wndId . ";")
    isTitleHidden := InStr(Bar_hideTitleWndIds, wndId . ";")

    text .= "Window " . wndId . ";" . wndPName . ";" . Window_#%wndId%_monitor . ";" . Window_#%wndId%_tags . ";" . Window_#%wndId%_isFloating . ";" . Window_#%wndId%_isDecorated . ";" . isTitleHidden . ";" . isManaged . ";" . title . "`n"
  }
  DetectHiddenWindows, %detectHidden%

  text .= "`n"

  ;; Dump window arrangements on every view. If some views or monitors have disappeared, leave their
  ;;   corresponding windows alone.

  Loop, % nm {
    monitor := A_Index
    Loop, % nv {
      view := A_Index
      ;; Dump all view window lists
      text .= "View_#" . monitor . "_#" . view . "_wndIds=" . View_#%monitor%_#%view%_wndIds . "`n"
    }
  }

  FileAppend, %text%, %tmpfname%
  If ErrorLevel {
    If FileExist(tmpfname)
      FileDelete, %tmpfname%
  } Else
    FileMove, %tmpfname%, %filename%, 1
}

Manager_setCursor(wndId) {
  Local wndHeight, wndWidth, wndX, wndY

  If Config_mouseFollowsFocus {
    If wndId {
      WinGetPos, wndX, wndY, wndWidth, wndHeight, ahk_id %wndId%
      DllCall("SetCursorPos", "Int", Round(wndX + wndWidth / 2), "Int", Round(wndY + wndHeight / 2))
    } Else
      DllCall("SetCursorPos", "Int", Round(Monitor_#%Manager_aMonitor%_x + Monitor_#%Manager_aMonitor%_width / 2), "Int", Round(Monitor_#%Manager_aMonitor%_y + Monitor_#%Manager_aMonitor%_height / 2))
  }
}

Manager_setViewMonitor(i, d = 0) {
  Local aView, aWndId, v, wndIds

  aView := Monitor_#%Manager_aMonitor%_aView_#1
  If (Manager_monitorCount > 1) And View_#%Manager_aMonitor%_#%aView%_wndIds {
    If (i = 0)
      i := Manager_aMonitor
    i := Manager_loop(i, d, 1, Manager_monitorCount)
    v := Monitor_#%i%_aView_#1
    View_#%i%_#%v%_wndIds := View_#%Manager_aMonitor%_#%aView%_wndIds View_#%i%_#%v%_wndIds

    StringTrimRight, wndIds, View_#%Manager_aMonitor%_#%aView%_wndIds, 1
    Loop, PARSE, wndIds, `;
    {
      Loop, % Config_viewCount {
        StringReplace, View_#%Manager_aMonitor%_#%A_Index%_wndIds, View_#%Manager_aMonitor%_#%A_Index%_wndIds, %A_LoopField%`;,
        View_setActiveWindow(Manager_aMonitor, A_Index, 0)
      }

      Monitor_moveWindow(i, A_LoopField)
      Window_#%A_LoopField%_tags := 1 << v - 1
    }
    View_arrange(Manager_aMonitor, aView)
    Loop, % Config_viewCount {
      Bar_updateView(Manager_aMonitor, A_Index)
    }

    ;; Manually set the active monitor.
    Manager_aMonitor := i
    View_arrange(i, v)
    WinGet, aWndId, ID, A
    Manager_winActivate(aWndId)
    Bar_updateView(i, v)
  }
}

Manager_setWindowBorders()
{
  Local ncm, ncmSize

  If Config_selBorderColor
  {
    SetFormat, Integer, hex
    Manager_normBorderColor := DllCall("GetSysColor", "Int", 10)
    SetFormat, Integer, d
    DllCall("SetSysColors", "Int", 1, "Int*", 10, "UInt*", Config_selBorderColor)
  }
  If (Config_borderWidth > 0) Or (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
  {
    ncmSize := VarSetCapacity(ncm, 4 * (A_OSVersion = WIN_VISTA ? 11 : 10) + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), 0)
    NumPut(ncmSize, ncm, 0, "UInt")
    DllCall("SystemParametersInfo", "UInt", 0x0029, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
    Manager_borderWidth := NumGet(ncm, 4, "Int")
    Manager_borderPadding := NumGet(ncm, 40 + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), "Int")
    If (Config_borderWidth > 0)
      NumPut(Config_borderWidth, ncm, 4, "Int")
    If (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
      NumPut(Config_borderPadding, ncm, 40 + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), "Int")
    DllCall("SystemParametersInfo", "UInt", 0x002a, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
  }
}

Manager_setWindowMonitor(i, d = 0) {
  Local aWndId, v

  WinGet, aWndId, ID, A
  If (Manager_monitorCount > 1 And InStr(Manager_managedWndIds, aWndId ";")) {
    Loop, % Config_viewCount {
      StringReplace, View_#%Manager_aMonitor%_#%A_Index%_wndIds, View_#%Manager_aMonitor%_#%A_Index%_wndIds, %aWndId%`;,
      If (View_getActiveWindow(Manager_aMonitor, A_Index) = aWndId)
        View_setActiveWindow(Manager_aMonitor, A_Index, 0)
      Bar_updateView(Manager_aMonitor, A_Index)
    }
    If Config_dynamicTiling
      View_arrange(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1)

    ;; Manually set the active monitor.
    If (i = 0)
      i := Manager_aMonitor
    Manager_aMonitor := Manager_loop(i, d, 1, Manager_monitorCount)
    Monitor_moveWindow(Manager_aMonitor, aWndId)
    v := Monitor_#%Manager_aMonitor%_aView_#1
    Window_#%aWndId%_tags := 1 << v - 1
    View_#%Manager_aMonitor%_#%v%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%v%_wndIds
    View_setActiveWindow(Manager_aMonitor, v, aWndId)
    If Config_dynamicTiling
      View_arrange(Manager_aMonitor, v)
    Manager_winActivate(aWndId)
    Bar_updateView(Manager_aMonitor, v)
  }
}

Manager_sizeWindow() {
  Local aWndId, SC_SIZE, WM_SYSCOMMAND

  WinGet, aWndId, ID, A
  If Not Window_#%aWndId%_isFloating
    View_toggleFloatingWindow(aWndId)
  Window_set(aWndId, "Top", "")

  WM_SYSCOMMAND = 0x112
  SC_SIZE       = 0xF000
  SendMessage, WM_SYSCOMMAND, SC_SIZE, , , ahk_id %aWndId%
}

;; No windows are known to the system yet.
;; Try to do something smart with the initial layout.
Manager_initial_sync(doRestore) {
  Local wndId, wndId0, wnd, wndX, wndY, wndW, wndH, x, y, m, len

  ;; Initialize lists
  ;; Note that these variables make this function non-reentrant.
  Loop, % Manager_monitorCount
    Manager_initial_sync_m#%A_Index%_wndList := ""

  ;; Use saved window placement settings to first determine
  ;;   which monitor/view a window should be attached to.
  If doRestore
    Manager__restoreWindowState(Main_autoWindowState)

  ;; Check all remaining visible windows against the known windows
  WinGet, wndId, List, , ,
  Loop, % wndId {
    ;; Based on some analysis here, determine which monitors and layouts would best
    ;; serve existing windows. Do not override configuration settings.

    ;; Which monitor is it on?
    wnd := wndId%A_Index%
    WinGetPos, wndX, wndY, wndW, wndH, ahk_id %wnd%

    x := wndX + wndW/2
    y := wndY + wndH/2

    m := Monitor_get(x, y)
    If m > 0
      Manager_initial_sync_m#%m%_wndList .= wndId%A_Index% ";"

  }

  Loop, % Manager_monitorCount {
    m := A_Index
    StringTrimRight, wndIds, Manager_initial_sync_m#%m%_wndList, 1
    StringSplit, wndId, wndIds, `;
    Loop, % wndId0
      Manager_manage(m, 1, wndId%A_Index%)
  }
}

;; @todo: This constantly tries to re-add windows that are never going to be manageable.
;;   Manager_manage should probably ignore all windows that are already in Manager_allWndIds.
;;   The problem was, that i. a. claws-mail triggers Manager_sync, but the application window
;;   would not be ready for being managed, i. e. class and title were not available. Therefore more
;;   attempts were needed.
;;   Perhaps this method can be refined by not adding any window to Manager_allWndIds, but only
;;   those, which have at least a title or class.
Manager_sync(ByRef wndIds = "")
{
  Local a, flag, shownWndIds, v, visibleWndIds, wndId

  Loop, % Manager_monitorCount
  {
    v := Monitor_#%A_Index%_aView_#1
    shownWndIds .= View_#%A_Index%_#%v%_wndIds
  }
  ;; Check all visible windows against the known windows
  WinGet, wndId, List, , ,
  Loop, % wndId
  {
    If Not InStr(shownWndIds, wndId%A_Index% ";")
    {
      If Not InStr(Manager_managedWndIds, wndId%A_Index% ";")
      {
        flag := Manager_manage(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1, wndId%A_Index%)
        If flag
          a := flag
      }
      Else If Not Window_isHung(wndId%A_Index%)
      {
        ;; This is a window that is already managed but was brought into focus by something.
        ;; Maybe it would be useful to do something with it.
        wndIds .= wndId%A_Index% ";"
      }
    }
    visibleWndIds := visibleWndIds wndId%A_Index% ";"
  }

  ;; @todo-future: Find out why this unmanage code exists and if it's still needed.
  ;; check, if a window, that is known to be visible, is actually not visible
  StringTrimRight, shownWndIds, shownWndIds, 1
  Loop, PARSE, shownWndIds, `;
  {
    If Not InStr(visibleWndIds, A_LoopField)
    {
      flag := Manager_unmanage(A_LoopField)
      If flag
        a := flag
    }
  }

  Return, a
}

Manager_unmanage(wndId) {
  Local a, aView

  aView := Monitor_#%Manager_aMonitor%_aView_#1

  a := Window_#%wndId%_tags & 1 << aView - 1
  Loop, % Config_viewCount {
    If (Window_#%wndId%_tags & 1 << A_Index - 1) {
      StringReplace, View_#%Manager_aMonitor%_#%A_Index%_wndIds, View_#%Manager_aMonitor%_#%A_Index%_wndIds, % wndId ";",, All
      StringReplace, View_#%Manager_aMonitor%_#%A_Index%_aWndIds, View_#%Manager_aMonitor%_#%A_Index%_aWndIds, % wndId ";",, All
      Bar_updateView(Manager_aMonitor, A_Index)
    }
  }
  Window_#%wndId%_monitor     :=
  Window_#%wndId%_tags        :=
  Window_#%wndId%_isDecorated :=
  Window_#%wndId%_isFloating  :=
  Window_#%wndId%_area        :=
  StringReplace, Bar_hideTitleWndIds, Bar_hideTitleWndIds, %wndId%`;,
  StringReplace, Manager_allWndIds, Manager_allWndIds, %wndId%`;,
  StringReplace, Manager_managedWndIds, Manager_managedWndIds, %wndId%`;, , All

  Return, a
}

Manager_winActivate(wndId) {
  Manager_setCursor(wndId)
  Debug_logMessage("DEBUG[1] Activating window: " wndId, 1)
  If Not wndId {
    If (A_OSVersion = "WIN_8" Or A_OSVersion = "WIN_8.1")
      WinGet, wndId, ID, ahk_class WorkerW
    Else
      WinGet, wndId, ID, Program Manager ahk_class Progman
    Debug_logMessage("DEBUG[1] Activating Desktop: " wndId, 1)
  }

  If Window_activate(wndId)
    Return, 1
  Else {
    Bar_updateTitle()
    Return 0
  }
}

;; vim:sts=2 ts=2 sw=2 et
