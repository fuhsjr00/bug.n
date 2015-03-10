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

Debug_initLog(filename, level = 0, truncateFile = True)
{
  Global Debug_logFilename, Debug_logLevel

  Debug_logFilename := filename
  Debug_logLevel := level
  If truncateFile
    If FileExist(Debug_logFilename)
      FileDelete, %Debug_logFilename%
}

Debug_logHelp()
{
  Debug_logMessage("Help Display", 0)
  Debug_logMessage("Window list columns", 0, False)
  Debug_logMessage("    ID - Windows ID. Unique, OS-assigned ID", 0, False)
  Debug_logMessage("    H - Hidden. Whether bug.n thinks this window is hidden.", 0, False)
  Debug_logMessage("    W - Windows active. This window is active according to Windows.", 0, False)
  Debug_logMessage("    A - View active. This window is active according to bug.n.", 0, False)
  Debug_logMessage("    F - Floating. This window should not be positioned and resized by the layout.", 0, False)
  Debug_logMessage("    D - Decorated. Does the window have a title bar?", 0, False)
  Debug_logMessage("    R - Responsive. Is responding to messages?", 0, False)
  Debug_logMessage("    G - Ghost. Is this window a ghost of another hung window?", 0, False)
  Debug_logMessage("    M - Monitor number.", 0, False)
  Debug_logMessage("    Tags - Bit-mask of the views in which the window is active.", 0, False)
  Debug_logMessage("    X - Windows X position.", 0, False)
  Debug_logMessage("    Y - Windows Y position.", 0, False)
  Debug_logMessage("    W - Windows width.", 0, False)
  Debug_logMessage("    H - Windows height.", 0, False)
  Debug_logMessage("    Style - Windows style.", 0, False)
  Debug_logMessage("    Proc / Class / Title - Process/Class/Title of the window.", 0, False)
}

Debug_logManagedWindowList()
{
  Local wndIds

  Debug_logMessage("Window dump for manager")
  Debug_logMessage("ID`t`tH W A F D R G M`tTags`tX`tY`tW`tH`tStyle`t`tProc / Class / Title", 0, False)

  StringTrimRight, wndIds, Manager_managedWndIds, 1
  Loop, PARSE, wndIds, `;
  {
    Debug_logWindowInfo(A_LoopField)
  }
}

Debug_logMessage(text, level = 1, includeTimestamp = True)
{
  Global Debug_logFilename, Debug_logLevel

  If (Debug_logLevel >= level)
  {
    If includeTimestamp
    {
      FormatTime, time, , yyyy-MM-dd HH:mm:ss
      text := time " " text
    }
    Else
      text := "                    " text
    FileAppend, %text%`r`n, %Debug_logFilename%
  }
}

Debug_logViewWindowList()
{
  Local v, wndIds

  v := Monitor_#%Manager_aMonitor%_aView_#1
  Debug_logMessage("Window dump for active view (" . Manager_aMonitor . ", " . v . ")")
  Debug_logMessage("ID`t`tH W A F D R G M`tTags`tX`tY`tW`tH`tStyle`t`tProc / Class / Title", 0, False)

  StringTrimRight, wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, 1
  Loop, PARSE, wndIds, `;
  {
    Debug_logWindowInfo(A_LoopField)
  }
}

Debug_logWindowInfo(wndId) {
  Local aWndId, detectHidden, text, v
  Local isBugnActive, isDecorated, isFloating, isGhost, isHidden, isResponsive, isWinFocus
  Local wndClass, wndH, wndPId, wndPName, wndStyle, wndTitle, wndW, wndX, wndY

  detectHidden := A_DetectHiddenWindows
  DetectHiddenWindows, On
  WinGet, aWndId, ID, A
  If aWndId = %wndId%
    isWinFocus := "*"
  Else
    isWinFocus := " "
  v := Monitor_#%Manager_aMonitor%_aView_#1
  If (View_getActiveWindow(Manager_aMonitor, v) = wndId)
    isBugnActive := "*"
  Else
    isBugnActive := " "
  WinGetTitle, wndTitle, ahk_id %wndId%
  WinGetClass, wndClass, ahk_id %wndId%
  WinGet, wndPName, ProcessName, ahk_id %wndId%
  WinGet, wndPId, PID, ahk_id %wndId%
  If InStr(Bar_hiddenWndIds, wndId)
    isHidden := "*"
  Else
    isHidden := " "
  If Window_#%wndId%_isFloating
    isFloating := "*"
  Else
    isFloating := " "
  If Window_#%wndId%_isDecorated
    isDecorated := "*"
  Else
    isDecorated := " "
  WinGet, wndStyle, Style, ahk_id %wndId%
  WinGetPos, wndX, wndY, wndW, wndH, ahk_id %wndId%
  If Window_isGhost(wndId)
    isGhost := "*"
  Else
    isGhost := " "
  DetectHiddenWindows, %detectHidden%

  ;; Intentionally don't detect hidden windows here to see what Manager_hungTest does
  If Window_isHung(wndId)
    isResponsive := " "
  Else
    isResponsive := "*"

  text := wndId "`t"
  text .= isHidden " " isWinFocus " " isBugnActive " " isFloating " " isDecorated " " isResponsive " " isGhost " "
  text .= Window_#%wndId%_monitor "`t" Window_#%wndId%_tags "`t"
  text .= wndX "`t" wndY "`t" wndW "`t" wndH "`t" wndStyle "`t" wndPName " [" wndPId "] / " wndClass " / " wndTitle
  Debug_logMessage(text , 0, False)
}

Debug_setLogLevel(i, d) {
  Global Debug_logLevel

  If (i = 0)
    i := Debug_logLevel
  i += d
  If (i >= 0) And (i != Debug_logLevel) {
    Debug_logLevel := i
    If (i = 0)
      Debug_logMessage("Logging disabled.", 0)
    Else
      Debug_logMessage("Log level set to " i ".")
  }
}

;; vim:sts=2 ts=2 sw=2 et
