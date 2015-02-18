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

Window_activate(wndId) {
  If Window_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Window_activate: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinActivate, ahk_id %wndId%
    WinGet, aWndId, ID, A
    If (wndId != aWndId)
      Return, 1
    Else
      Return, 0
  }
}

Window_close(wndId) {
  If Window_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Window_close: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinClose, ahk_id %wndId%
    Return, 0
  }
}

;; Given a ghost window, try to find its body. This is only known to work on Windows 7
Window_findHung(ghostWndId) {
  Global Config_ghostWndSubString

  WinGetTitle, ghostWndTitle, ahk_id %ghostWndId%
  StringReplace, ghostWndTitle, ghostWndTitle, %Config_ghostWndSubString%,
  WinGetPos, ghostWndX, ghostWndY, ghostWndW, ghostWndH, ahk_id %ghostWndId%

  SetTitleMatchMode, 2
  WinGet, wndId, List, %ghostWndTitle%
  Loop, % wndId {
    If (wndId%A_Index% = ghostWndId)
      Continue
    WinGetPos, wndX, wndY, wndW, wndH, % "ahk_id" wndId%A_Index%
    If (wndX = ghostWndX) And (wndY = ghostWndY) And (wndW = ghostWndW) And (wndH = ghostWndH)
      Return, wndId%A_Index%
  }
  Return, 0
}

Window_hide(wndId) {
  If Window_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Window_hide: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinHide, ahk_id %wndId%
    Return, 0
  }
}

Window_isChild(wndId) {
  WS_POPUP = 0x40000000
  WinGet, wndStyle, Style, ahk_id %wndId%

  Return, wndStyle & WS_POPUP
}

Window_isElevated(wndId) {
  WinGetTitle, wndTitle, ahk_id %wndId%
  WinSetTitle, ahk_id %wndId%, , % wndTitle " "
  WinGetTitle, newWndTitle, ahk_id %wndId%
  WinSetTitle, ahk_id %wndId%, , % wndTitle
  Return, (newWndTitle = wndTitle)
}

Window_isGhost(wndId) {
  Local wndClass, wndProc

  WinGet, wndProc, ProcessName, ahk_id %wndId%
  WinGetClass, wndClass, ahk_id %wndId%
  If (wndProc = "dwm.exe") And (wndClass = "Ghost")
    Return, 1
  Else
    Return, 0
}

Window_isHidden(wndId, ByRef wndClass, ByRef wndTitle) {
  WinGetClass, wndClass, ahk_id %wndId%
  WinGetTitle, wndTitle, ahk_id %wndId%
  If Not wndClass And Not wndTitle {
    detectHiddenWnds := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGetClass, wndClass, ahk_id %wndId%
    WinGetTitle, wndTitle, ahk_id %wndId%
    DetectHiddenWindows, %detectHiddenWnds%
    ;; If now wndClass Or wndTitle, but Not wndClass And Not wndTitle before, wnd is hidden.
    Return, (wndClass Or wndTitle)
  } Else
    Return, False
}

;; 0 - Not hung
;; 1 - Hung
Window_isHung(wndId) {
  Local detectSetting, result, WM_NULL

  WM_NULL = 0
  detectSetting := A_DetectHiddenWindows
  DetectHiddenWindows, On
  SendMessage, WM_NULL, , , , ahk_id %wndId%
  result := ErrorLevel
  DetectHiddenWindows, %detectSetting%

  If result
  {
    Debug_logMessage("DEBUG[6] Window_isHung(" wndId ") = " result, 6)
    Return, 1
  }
  Else
    Return, 0
}

Window_isPopup(wndId) {
  WS_POPUP = 0x80000000
  WinGet, wndStyle, Style, ahk_id %wndId%

  Return, wndStyle & WS_POPUP
}

Window_isProg(wndId) {
  WinGetClass, wndClass, ahk_id %wndId%
  WinGetTitle, wndTitle, ahk_id %wndId%
  If Not (wndClass = "Progman") And Not (wndClass = "WorkerW") And Not (wndClass = "DesktopBackgroundClass")
     And Not (wndClass = "AutoHotkeyGui" And SubStr(wndTitle, 1, 10) = "bug.n_BAR_")
    Return, wndId
  Else
    Return, 0
}

Window_maximize(wndId) {
  If Window_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Window_maximize: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinMaximize, ahk_id %wndId%
    Return, 0
  }
}

Window_move(wndId, x, y, width, height) {
  If Window_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Window_move: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinGet, wndMin, MinMax, ahk_id %wndId%
    If (wndMin = -1)
      WinRestore, ahk_id %wndId%
  }

  WM_ENTERSIZEMOVE = 0x0231
  WM_EXITSIZEMOVE  = 0x0232
  SendMessage, WM_ENTERSIZEMOVE, , , , ahk_id %wndId%
  If ErrorLevel {
    Debug_logMessage("DEBUG[2] Window_move: Potentially hung window " . wndId, 1)
    Return, 1
  } Else {
    WinMove, ahk_id %wndId%, , %x%, %y%, %width%, %height%
    SendMessage, WM_EXITSIZEMOVE, , , , ahk_id %wndId%
    Return, 0
  }
}

Window_set(wndId, type, value) {
  If Window_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Window_set: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinSet, %type%, %value%, ahk_id %wndId%
    Return, 0
  }
}

Window_show(wndId) {
  If Window_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Window_show: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinShow, ahk_id %wndId%
    Return, 0
  }
}

Window_toggleDecor(wndId = 0) {
  Global

  If (wndId = 0)
    WinGet, wndId, ID, A

  Window_#%wndId%_isDecorated := Not Window_#%wndId%_isDecorated
  If Window_#%wndId%_isDecorated
    Window_set(wndId, "Style", "+0xC00000")
  Else
    Window_set(wndId, "Style", "-0xC00000")
}

;; vim:sts=2 ts=2 sw=2 et
