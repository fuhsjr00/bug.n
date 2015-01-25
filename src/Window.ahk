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

;; Given a ghost window, try to find its body. This is only known to work on Windows 7
Manager_findHung(ghostWndId) {
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

Manager_isGhost(wndId) {
  Local wndClass, wndProc

  WinGet, wndProc, ProcessName, ahk_id %wndId%
  WinGetClass, wndClass, ahk_id %wndId%
  If (wndProc = "dwm.exe") And (wndClass = "Ghost")
    Return, 1
  Else
    Return, 0
}

;; 0 - Not hung
;; 1 - Hung
Manager_isHung(wndId) {
  Local detectSetting, result, WM_NULL

  WM_NULL = 0
  detectSetting := A_DetectHiddenWindows
  DetectHiddenWindows, On
  SendMessage, WM_NULL, , , , ahk_id %wndId%
  result := ErrorLevel
  DetectHiddenWindows, %detectSetting%

  If result
    Return, 1
  Else
    Return, 0
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

Manager_winClose(wndId) {
  If Manager_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Manager_winClose: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinClose, ahk_id %wndId%
    Return, 0
  }
}

Manager_winHide(wndId) {
  If Manager_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Manager_winHide: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinHide, ahk_id %wndId%
    Return, 0
  }
}

Manager_winMaximize(wndId) {
  If Manager_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Manager_winMaximize: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinMaximize, ahk_id %wndId%
    Return, 0
  }
}

Manager_winMove(wndId, x, y, width, height) {
  If Manager_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Manager_winMove: Potentially hung window " . wndId, 2)
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
    Debug_logMessage("DEBUG[2] Manager_winMove: Potentially hung window " . wndId, 1)
    Return, 1
  } Else {
    WinMove, ahk_id %wndId%, , %x%, %y%, %width%, %height%
    SendMessage, WM_EXITSIZEMOVE, , , , ahk_id %wndId%
    Return, 0
  }
}

Manager_winSet(type, value, wndId) {
  If Manager_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Manager_winSet: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinSet, %type%, %value%, ahk_id %wndId%
    Return, 0
  }
}

Manager_winShow(wndId) {
  If Manager_isHung(wndId) {
    Debug_logMessage("DEBUG[2] Manager_winShow: Potentially hung window " . wndId, 2)
    Return, 1
  } Else {
    WinShow, ahk_id %wndId%
    Return, 0
  }
}

Manager_toggleDecor(wndId = 0) {
  Global

  If (wndId = 0)
    WinGet, wndId, ID, A

  Manager_#%wndId%_isDecorated := Not Manager_#%wndId%_isDecorated
  If Manager_#%wndId%_isDecorated
    Manager_winSet("Style", "+0xC00000", wndId)
  Else
    Manager_winSet("Style", "-0xC00000", wndId)
}

Window_activate(wndId) {
  If Manager_isHung(wndId) {
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
