/*
  bug.n -- tiling window management
  Copyright (c) 2010-2018 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.2
*/

Monitor_init(m, doRestore) {
  Global

  Monitor_#%m%_aView_#1 := 1
  Monitor_#%m%_aView_#2 := 1
  Monitor_#%m%_showBar  := Config_showBar
  Monitor_#%m%_showTaskBar  := Config_showTaskBar
  Monitor_#%m%_taskBarClass := ""
  Monitor_#%m%_taskBarPos   := ""
  Loop, % Config_viewCount
    View_init(m, A_Index)
  If doRestore
    Config_restoreLayout(Main_autoLayout, m)
  Else
    Config_restoreLayout(Config_filePath, m)
  SysGet, Monitor_#%m%_name, MonitorName, %m%
  Monitor_getWorkArea(m)
  If Not Monitor_#%m%_showTaskBar {
    Monitor_#%m%_showTaskBar := True
    Monitor_toggleTaskBar(m)
  }
  Bar_init(m)
}

Monitor_activateView(i, d = 0) {
  Local aMonitor, aView, aWndId, detectHidden, m, n, wndId, wndIds

  aMonitor := Manager_aMonitor
  If (i = -1)
    i := Monitor_#%aMonitor%_aView_#2
  Else If (i = 0)
    i := Monitor_#%aMonitor%_aView_#1
  i := Manager_loop(i, d, 1, Config_viewCount)

  Debug_logMessage("DEBUG[1] Monitor_activateView; i: " . i . ", d: " . d . ", Manager_aMonitor: " . aMonitor . ", wndIds: " . View_#%Manager_aMonitor%_#%i%_wndIds, 1)
  If (i <= 0) Or (i > Config_viewCount) Or Manager_hideShow
    Return
  ;; Re-arrange the windows on the active view.
  If (i = Monitor_#%aMonitor%_aView_#1) {
    View_arrange(aMonitor, i)
    Return
  }

  aView := Monitor_#%aMonitor%_aView_#1
  WinGet, aWndId, ID, A
  If WinExist("ahk_id" aWndId) And InStr(View_#%aMonitor%_#%aView%_wndIds, aWndId ";") And Window_isProg(aWndId)
    View_setActiveWindow(aMonitor, aView, aWndId)

  n := Config_syncMonitorViews
  If (n = 1)
    n := Manager_monitorCount
  Else If (n < 1)
    n := 1
  Loop, % n {
    If (n = 1)
      m := aMonitor
    Else
      m := A_Index

    Monitor_#%m%_aView_#2 := aView
    Monitor_#%m%_aView_#1 := i
    Manager_hideShow := True
    SetWinDelay, 0
    StringTrimRight, wndIds, View_#%m%_#%aView%_wndIds, 1
    Loop, PARSE, wndIds, `;
    {
      If A_LoopField And Not (Window_#%A_LoopField%_tags & (1 << i - 1))
        Window_hide(A_LoopField)
    }
    SetWinDelay, 10
    detectHidden := A_DetectHiddenWindows
    DetectHiddenWindows, On
    wndId := View_getActiveWindow(m, i)
    If wndId
      Window_set(wndId, "AlwaysOnTop", "On")
    View_arrange(m, i)
    DetectHiddenWindows, %detectHidden%
    StringTrimRight, wndIds, View_#%m%_#%i%_wndIds, 1
    SetWinDelay, 0
    Loop, PARSE, wndIds, `;
    {
      Window_show(A_LoopField)
    }
    Window_set(wndId, "AlwaysOnTop", "Off")
    SetWinDelay, 10
    Manager_hideShow := False

    Bar_updateView(m, aView)
    Bar_updateView(m, i)
  }

  wndId := View_getActiveWindow(aMonitor, i)
  Manager_winActivate(wndId)
}

Monitor_find(d, n) {
  Local mName
  
  If (d < 0 Or d > 0) {
    Loop, % n {
      SysGet, mName, MonitorName, %A_Index%
      If Not (mName = Monitor_#%A_Index%_name)
        Return, A_Index
    }
  }
  Return, 0
}

Monitor_get(x, y)
{
  Local m

  m := 0
  Loop, % Manager_monitorCount
  {    ;; Check if the window is on this monitor.
    If (x >= Monitor_#%A_Index%_x && x <= Monitor_#%A_Index%_x+Monitor_#%A_Index%_width && y >= Monitor_#%A_Index%_y && y <= Monitor_#%A_Index%_y+Monitor_#%A_Index%_height)
    {
      m := A_Index
      Break
    }
  }

  Return, m
}

Monitor_getWorkArea(m) {
  Local bHeight, bTop, x, y
  Local monitor, monitorBottom, monitorLeft, monitorRight, monitorTop
  Local wndClasses, wndHeight, wndId, wndWidth, wndX, wndY

  SysGet, monitor, Monitor, %m%

  wndClasses := "Shell_TrayWnd;Shell_SecondaryTrayWnd"
  ;; @TODO What about third and so forth TrayWnd?
  If Config_bbCompatibility
    wndClasses .= ";bbLeanBar;bbSlit;BBToolbar;SystemBarEx"
  Loop, PARSE, wndClasses, `;
  {
    wndId := WinExist("ahk_class " A_LoopField)
    If wndId {
      WinGetPos, wndX, wndY, wndWidth, wndHeight, ahk_id %wndId%
      x := wndX + wndWidth / 2
      y := wndY + wndHeight / 2
      If (x >= monitorLeft && x <= monitorRight && y >= monitorTop && y <= monitorBottom) {
        If (A_LoopField = "Shell_TrayWnd") Or (A_LoopField = "Shell_SecondaryTrayWnd")
          Monitor_#%m%_taskBarClass := A_LoopField

        If (wndHeight < wndWidth) {
          ;; Horizontal
          If (wndY <= monitorTop) {
            ;; Top
            wndHeight += wndY - monitorTop
            monitorTop += wndHeight
            If (A_LoopField = "Shell_TrayWnd") Or (A_LoopField = "Shell_SecondaryTrayWnd")
              Monitor_#%m%_taskBarPos := "top"
          } Else {
            ;; Bottom
            wndHeight := monitorBottom - wndY
            monitorBottom -= wndHeight
          }
        } Else {
          ;; Vertical
          If (wndX <= monitorLeft) {
            ;; Left
            wndWidth += wndX
            monitorLeft += wndWidth
          } Else {
            ;; Right
            wndWidth := monitorRight - wndX
            monitorRight -= wndWidth
          }
        }
      }
    }
  }
  bHeight := Round(Bar_height / Config_scalingFactor)
  bTop := 0
  If (Config_verticalBarPos = "top") Or (Config_verticalBarPos = "tray") And Not Monitor_#%m%_taskBarClass {
    bTop := monitorTop
    If Monitor_#%m%_showBar
      monitorTop += bHeight
  } Else If (Config_verticalBarPos = "bottom") {
    bTop := monitorBottom - bHeight
    If Monitor_#%m%_showBar
      monitorBottom -= bHeight
  }

  Monitor_#%m%_height := monitorBottom - monitorTop
  Monitor_#%m%_width  := monitorRight - monitorLeft
  Monitor_#%m%_x      := monitorLeft
  Monitor_#%m%_y      := monitorTop
  Monitor_#%m%_barY   := bTop

  Monitor_setWorkArea(monitorLeft, monitorTop, monitorRight, monitorBottom)
}

Monitor_moveToIndex(m, n) {
  Global

  Monitor_#%n%_aView_#1 := Monitor_#%m%_aView_#1
  Monitor_#%n%_aView_#2 := Monitor_#%m%_aView_#2
  Monitor_#%n%_name     := Monitor_#%m%_name
  Monitor_#%n%_showBar  := Monitor_#%m%_showBar
  Monitor_#%n%_showTaskBar  := Monitor_#%m%_showTaskBar
  Monitor_#%n%_taskBarClass := Monitor_#%m%_taskBarClass
  Monitor_#%n%_taskBarPos   := Monitor_#%m%_taskBarPos
  Monitor_#%n%_height := Monitor_#%m%_height
  Monitor_#%n%_width  := Monitor_#%m%_width
  Monitor_#%n%_x      := Monitor_#%m%_x
  Monitor_#%n%_y      := Monitor_#%m%_y
  Monitor_#%n%_barY   := Monitor_#%m%_barY
  Loop, % Config_viewCount
    View_moveToIndex(m, A_Index, n, A_Index)
}

Monitor_setWindowTag(i, d = 0) {
  Local aView, aWndId, wndId

  If (i = 0)
    i := Monitor_#%Manager_aMonitor%_aView_#1
  If Not (i = 10)
    i := Manager_loop(i, d, 1, Config_viewCount)

  WinGet, aWndId, ID, A
  If InStr(Manager_managedWndIds, aWndId ";") And (i > 0) And (i <= Config_viewCount Or i = 10) {
    If (i = 10) {
      Loop, % Config_viewCount {
        If Not (Window_#%aWndId%_tags & (1 << A_Index - 1)) {
          View_#%Manager_aMonitor%_#%A_Index%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%A_Index%_wndIds
          View_setActiveWindow(Manager_aMonitor, A_Index, aWndId)
          Bar_updateView(Manager_aMonitor, A_Index)
          Window_#%aWndId%_tags += 1 << A_Index - 1
        }
      }
    } Else {
      Loop, % Config_viewCount {
        If Not (A_index = i) {
          StringReplace, View_#%Manager_aMonitor%_#%A_Index%_wndIds, View_#%Manager_aMonitor%_#%A_Index%_wndIds, %aWndId%`;,
          View_setActiveWindow(Manager_aMonitor, A_Index, 0)
          Bar_updateView(Manager_aMonitor, A_Index)
        }
      }

      If Not (Window_#%aWndId%_tags & (1 << i - 1))
        View_#%Manager_aMonitor%_#%i%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%i%_wndIds
      View_setActiveWindow(Manager_aMonitor, i, aWndId)
      Window_#%aWndId%_tags := 1 << i - 1

      aView := Monitor_#%Manager_aMonitor%_aView_#1
      If Not (i = aView) {
        Manager_hideShow := True
        wndId := SubStr(View_#%Manager_aMonitor%_#%aView%_wndIds, 1, InStr(View_#%Manager_aMonitor%_#%aView%_wndIds, ";") - 1)
        Manager_winActivate(wndId)
        Manager_hideShow := False
        If Config_viewFollowsTagged
          Monitor_activateView(i)
        Else {
          Manager_hideShow := True
          Window_hide(aWndId)
          Manager_hideShow := False
          If Config_dynamicTiling
            View_arrange(Manager_aMonitor, aView)
          Bar_updateView(Manager_aMonitor, i)
        }
      }
    }
  }
}

Monitor_setWorkArea(left, top, right, bottom) {
   VarSetCapacity(area, 16)
   NumPut(left,   area,  0)
   NumPut(top,    area,  4)
   NumPut(right,  area,  8)
   NumPut(bottom, area, 12)
   DllCall("SystemParametersInfo", UInt, 0x2F, UInt, 0, UInt, &area, UInt, 0)   ; 0x2F = SPI_SETWORKAREA
}
;; flashkid: Send SetWorkArea to second Monitor (http://www.autohotkey.com/board/topic/42564-send-setworkarea-to-second-monitor/)

Monitor_toggleBar()
{
  Global

  Monitor_#%Manager_aMonitor%_showBar := Not Monitor_#%Manager_aMonitor%_showBar
  Bar_toggleVisibility(Manager_aMonitor)
  Monitor_getWorkArea(Manager_aMonitor)
  View_arrange(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1)
  Manager_winActivate(Bar_aWndId)
}

Monitor_toggleNotifyIconOverflowWindow() {
  Static wndId

  If Not WinExist("ahk_class NotifyIconOverflowWindow") {
    WinGet, wndId, ID, A
    detectHidden := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinShow, ahk_class NotifyIconOverflowWindow
    WinActivate, ahk_class NotifyIconOverflowWindow
    DetectHiddenWindows, %detectHidden%
  } Else {
    WinHide, ahk_class NotifyIconOverflowWindow
    WinActivate, ahk_id %wndId%
  }
}

Monitor_toggleTaskBar(m := 0) {
  Global

  m := m ? m : Manager_aMonitor
  If Monitor_#%m%_taskBarClass {
    Monitor_#%m%_showTaskBar := Not Monitor_#%m%_showTaskBar
    Manager_hideShow := True
    If Not Monitor_#%m%_showTaskBar {
      WinHide, Start ahk_class Button
      WinHide, % "ahk_class " Monitor_#%m%_taskBarClass
    } Else {
      WinShow, Start ahk_class Button
      WinShow, % "ahk_class " Monitor_#%m%_taskBarClass
    }
    Manager_hideShow := False
    Monitor_getWorkArea(m)
    Bar_move(m)
    View_arrange(m, Monitor_#%m%_aView_#1)
  }
}

Monitor_toggleWindowTag(i, d = 0) {
  Local aWndId, wndId

  WinGet, aWndId, ID, A
  If (InStr(Manager_managedWndIds, aWndId ";") And i >= 0 And i <= Config_viewCount) {
    If (Window_#%aWndId%_tags & (1 << i - 1)) {
      If Not ((Window_#%aWndId%_tags - (1 << i - 1)) = 0) {
        Window_#%aWndId%_tags -= 1 << i - 1
        StringReplace, View_#%Manager_aMonitor%_#%i%_wndIds, View_#%Manager_aMonitor%_#%i%_wndIds, %aWndId%`;,
        Bar_updateView(Manager_aMonitor, i)
        If (i = Monitor_#%Manager_aMonitor%_aView_#1) {
          Manager_hideShow := True
          Window_hide(aWndId)
          Manager_hideShow := False
          wndId := SubStr(View_#%Manager_aMonitor%_#%i%_wndIds, 1, InStr(View_#%Manager_aMonitor%_#%i%_wndIds, ";")-1)
          Manager_winActivate(wndId)
          If Config_dynamicTiling
            View_arrange(Manager_aMonitor, i)
        }
      }
    } Else {
      View_#%Manager_aMonitor%_#%i%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%i%_wndIds
      View_setActiveWindow(Manager_aMonitor, i, aWndId)
      Bar_updateView(Manager_aMonitor, i)
      Window_#%aWndId%_tags += 1 << i - 1
    }
  }
}
