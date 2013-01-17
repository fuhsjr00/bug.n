/*
  bug.n -- tiling window management
  Copyright (c) 2010-2012 Joshua Fuhs, joten

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.

  @version 8.4.0
*/

Bar_init(m)
{
  Local appBarMsg, GuiN, h1, h2, i, text, titleWidth, trayWndId, w, wndId, wndTitle, wndWidth, x1, x2, y1, y2

  If (SubStr(Config_barWidth, 0) = "%")
  {
    StringTrimRight, wndWidth, Config_barWidth, 1
    wndWidth := Round(Monitor_#%m%_width * wndWidth / 100)
  }
  Else
    wndWidth := Config_barWidth
  Monitor_#%m%_barWidth := wndWidth
  titleWidth := wndWidth
  h1 := Bar_ctrlHeight
  x1 := 0
  x2 := wndWidth
  y1 := 0
  y2 := (Bar_ctrlHeight - Bar_textHeight) / 2
  h2 := Bar_ctrlHeight - 2 * y2

  ;; Create the GUI window
  wndTitle := "bug.n_BAR_" m
  GuiN := (m - 1) + 1
  Debug_logMessage("DEBUG[6] Bar_init(): Gui, " . GuiN . ": Default", 6)
  Gui, %GuiN%: Default
  Gui, Destroy
  Gui, +AlwaysOnTop -Caption +LabelBar_Gui +LastFound +ToolWindow
  Gui, Color, %Config_normBgColor1%
  Gui, Font, c%Config_normFgColor1% s%Config_fontSize%, %Config_fontName%

  ;; Tags
  Loop, % Config_viewCount
  {
    i := A_Index
    text := " " Config_viewNames_#%i% " "
    w := Bar_getTextWidth(text)
    Gui, Add, Text, x%x1% y%y1% w%w% h%h1% BackgroundTrans vBar_#%m%_#%i%_view gBar_GuiClick,
    If (w <= h1)
      Gui, Add, Progress, x%x1% y%y1% w%w% h%h1% Background%Config_normBgColor1% Vertical vBar_#%m%_#%i%_tagged
    Else
      Gui, Add, Progress, x%x1% y%y1% w%w% h%h1% Background%Config_normBgColor1% vBar_#%m%_#%i%_tagged
    Gui, Add, Text, x%x1% y%y2% w%w% h%h2% -Wrap Center BackgroundTrans vBar_#%m%_#%i%, %text%
    titleWidth -= w
    x1 += w
  }
  ;; Layout
  i := Config_viewCount + 1
  text := " ?????? "
  w := Bar_getTextWidth(text)
  Gui, Add, Text, x%x1% y%y1% w%w% h%h1% BackgroundTrans vBar_#%m%_#%i%_layout gBar_GuiClick,
  Gui, Add, Progress, x%x1% y%y1% w%w% h%h1% Background%Config_normBgColor2%
  Gui, Font, c%Config_normFgColor2%
  Gui, Add, Text, x%x1% y%y2% w%w% h%h2% -Wrap Center BackgroundTrans vBar_#%m%_#%i%, %text%
  titleWidth -= w
  x1 += w

  ;; The x-position and width of the sub-windows right of the window title are set from the right.
  Loop, 4
  {
    i := Config_viewCount + 7 - A_Index
    w := 0
    If (i = Config_viewCount + 6)
    {    ;; Command gui
      Gui, -Disabled
      w := Bar_getTextWidth(" ?? ")
      x2 -= w
      titleWidth -= w
      Gui, Add, Text, x%x2% y%y1% w%w% h%h1% BackgroundTrans vBar_#%m%_#%i% gBar_toggleCommandGui,
      Gui, Add, Progress, x%x2% y%y1% w%w% h%h1% Background%Config_normBgColor2%
      Gui, Add, Text, x%x2% y%y2% w%w% h%h2% Center BackgroundTrans, #!
    }
    Else If (i = Config_viewCount + 5) And Config_readinTime
    {    ;; Time
      w  := Bar_getTextWidth(" ??:?? ")
      x2 -= w
      titleWidth -= w
      If Config_readinAny() Or Config_readinBat
      {
        Gui, Font, c%Config_normFgColor1%
        Gui, Add, Text, x%x2% y%y1% w%w% h%h1%,
      }
      Gui, Add, Text, x%x2% y%y2% w%w% h%h2% BackgroundTrans Center vBar_#%m%_#%i%, ??:??
    }
    Else If (i = Config_viewCount + 4) And Config_readinAny()
    {    ;; Any
      text := Config_readinAny()
      w := Bar_getTextWidth(text)
      x2 -= w
      titleWidth -= w
      Gui, Add, Progress, x%x2% y%y1% w%w% h%h1% Background%Config_normBgColor2%
      Gui, Font, c%Config_normFgColor2%
      Gui, Add, Text, x%x2% y%y2% w%w% h%h2% Center BackgroundTrans vBar_#%m%_#%i%, %text%
    }
    Else If (i = Config_viewCount + 3) And Config_readinBat
    {    ;; Battery level
      w := Bar_getTextWidth(" BAT: ???% ")
      x2 -= w
      titleWidth -= w
      Gui, Add, Progress, x%x2% y%y1% w%w% h%h1% Background%Config_normBgColor2% c%Config_normFgColor3% vBar_#%m%_#%i%_tagged
      Gui, Font, c%Config_normFgColor2%
      Gui, Add, Text, x%x2% y%y2% w%w% h%h2% BackgroundTrans Center vBar_#%m%_#%i%, BAT: ???`%
    }
  }

  ;; Window title (remaining space)
  Gui, Add, Text, x%x1% y%y1% w%titleWidth% h%h1%,
  If Not Config_singleRowBar
  {
    titleWidth := wndWidth
    x1 := 0
    y1 += h1
    y2 += h1
  }
  i := Config_viewCount + 2
  Gui, Font, c%Config_normFgColor1%
  Gui, Add, Text, x%x1% y%y1% w%titleWidth% h%h1%,
  Gui, Add, Text, x%x1% y%y2% w%titleWidth% h%h2% BackgroundTrans Center vBar_#%m%_#%i%,

  If (Config_horizontalBarPos = "left")
    x1 := 0
  Else If (Config_horizontalBarPos = "right")
    x1 := Monitor_#%m%_width - wndWidth
  Else If (Config_horizontalBarPos = "center")
    x1 := (Monitor_#%m%_width - wndWidth) / 2
  Else If (Config_horizontalBarPos => 0)
    x1 := Config_horizontalBarPos
  Else If (Config_horizontalBarPos < 0)
    x1 := Monitor_#%m%_width - wndWidth + Config_horizontalBarPos
  If Not (Config_verticalBarPos = "tray" And m = Manager_taskBarMonitor)
    x1 += Monitor_#%m%_x

  Bar_#%m%_titleWidth := titleWidth
  Monitor_#%m%_barX := x1
  y1 := Monitor_#%m%_barY

  If Monitor_#%m%_showBar
    Gui, Show, NoActivate x%x1% y%y1% w%wndWidth% h%Bar_height%, %wndTitle%
  Else
    Gui, Show, NoActivate Hide x%x1% y%y1% w%wndWidth% h%Bar_height%, %wndTitle%
  wndId := WinExist(wndTitle)
  If (Config_verticalBarPos = "tray" And m = Manager_taskBarMonitor)
  {
    trayWndId := WinExist("ahk_class Shell_TrayWnd")
    DllCall("SetParent", "UInt", wndId, "UInt", trayWndId)
  }
  Else
  {
    appBarMsg := DllCall("RegisterWindowMessage", Str, "AppBarMsg")

    ;; appBarData: http://msdn2.microsoft.com/en-us/library/ms538008.aspx
    VarSetCapacity(Bar_appBarData, 36, 0)
    offset := NumPut(             36, Bar_appBarData)
    offset := NumPut(          wndId, offset+0)
    offset := NumPut(      appBarMsg, offset+0)
    offset := NumPut(              1, offset+0)
    offset := NumPut(             x1, offset+0)
    offset := NumPut(             y1, offset+0)
    offset := NumPut(  x1 + wndWidth, offset+0)
    offset := NumPut(y1 + Bar_height, offset+0)
    offset := NumPut(              1, offset+0)

    DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_NEW := 0x0)     , "UInt", &Bar_appBarData)
    DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_QUERYPOS := 0x2), "UInt", &Bar_appBarData)
    DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_SETPOS := 0x3)  , "UInt", &Bar_appBarData)
    ;; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)
  }
}

Bar_initCmdGui()
{
  Global Bar_#0_#0, Bar_#0_#0H, Bar_#0_#0W, Bar_cmdGuiIsVisible, Config_barCommands, Config_fontName, Config_fontSize, Config_normBgColor1, Config_normFgColor1

  Bar_cmdGuiIsVisible := False
  wndTitle := "bug.n_BAR_0"
  Gui, 99: Default
  Gui, +LabelBar_cmdGui
  IfWinExist, %wndTitle%
    Gui, Destroy
  Gui, +LastFound -Caption +ToolWindow +AlwaysOnTop +Delimiter`;
  Gui, Color, Default
  Gui, Font, s%Config_fontSize%, %Config_fontName%
  StringSplit, cmd, Config_barCommands, `;
  Gui, Add, ComboBox, x10 y0 r%cmd0% w300 Background%Config_normBgColor1% c%Config_normFgColor1% Simple vBar_#0_#0 gBar_cmdGuiEnter, % Config_barCommands
  Gui, Add, Button, Y0 Hidden Default gBar_cmdGuiEnter, OK
  GuiControlGet, Bar_#0_#0, Pos
  Bar_#0_#0W += 20
  Gui, Show, Hide w%Bar_#0_#0W% h%Bar_#0_#0H%, %wndTitle%
}

Bar_cmdGuiEscape:
  Bar_cmdGuiIsVisible := False
  Gui, Cancel
  WinActivate, ahk_id %Bar_aWndId%
Return

Bar_cmdGuiEnter:
  If (A_GuiControl = "OK") Or (A_GuiControl = "Bar_#0_#0" And A_GuiControlEvent = "DoubleClick")
  {
    Gui, Submit, NoHide
    Bar_cmdGuiIsVisible := False
    Gui, Cancel
    WinActivate, ahk_id %Bar_aWndId%
    Main_evalCommand(Bar_#0_#0)
    Bar_#0_#0 := ""
  }
Return

Bar_getBatteryStatus(ByRef batteryLifePercent, ByRef acLineStatus)
{
  VarSetCapacity(powerStatus, (1 + 1 + 1 + 1 + 4 + 4))
  success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
  If (ErrorLevel != 0 Or success = 0)
  {
    MsgBox 16, Power Status, Can't get the power status...
    Return
  }
  acLineStatus     := NumGet(powerStatus, 0, "Char")
  batteryLifePercent := NumGet(powerStatus, 2, "Char")

  If acLineStatus = 0
    acLineStatus = off
  Else If acLineStatus = 1
    acLineStatus = on
  Else If acLineStatus = 255
    acLineStatus = ?

  If batteryLifePercent = 255
    batteryLifePercent = ???
}
;; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)

Bar_getHeight()
{
  Global Bar_#0_#1, Bar_#0_#1H, Bar_#0_#2, Bar_#0_#2H, Bar_ctrlHeight, Bar_height, Bar_textHeight
  Global Config_fontName, Config_fontSize, Config_singleRowBar, Config_spaciousBar, Config_verticalBarPos

  wndTitle := "bug.n_BAR_0"
  Gui, 99: Default
  Gui, Font, s%Config_fontSize%, %Config_fontName%
  Gui, Add, Text, x0 y0 vBar_#0_#1, |
  GuiControlGet, Bar_#0_#1, Pos
  Bar_textHeight := Bar_#0_#1H
  If Config_spaciousBar
  {
    Gui, Add, ComboBox, r9 x0 y0 vBar_#0_#2, |
    GuiControlGet, Bar_#0_#2, Pos
    Bar_ctrlHeight := Bar_#0_#2H
  }
  Else
    Bar_ctrlHeight := Bar_textHeight
  Gui, Destroy

  Bar_height := Bar_ctrlHeight
  If Not Config_singleRowBar
    Bar_height *= 2
  If (Config_verticalBarPos = "tray")
  {
    WinGetPos, , , , buttonH, Start ahk_class Button
    WinGetPos, , , , barH, ahk_class Shell_TrayWnd
    If WinExist("Start ahk_class Button") And (buttonH < barH)
      Bar_height := buttonH
    Else
      Bar_height := barH
    Bar_ctrlHeight := Bar_height
    If Not Config_singleRowBar
      Bar_ctrlHeight := Bar_height / 2
  }
}

Bar_getTextWidth(x, reverse=False)
{
  Global Config_fontSize

  If reverse
  {    ;; 'reverse' calculates the number of characters to a given width.
    w := x
    i := w / (Config_fontSize - 1)
    If (Config_fontSize = 7 Or (Config_fontSize > 8 And Config_fontSize < 13))
      i := w / (Config_fontSize - 2)
    Else If (Config_fontSize > 12 And Config_fontSize < 18)
      i := w / (Config_fontSize - 3)
    Else If (Config_fontSize > 17)
      i := w / (Config_fontSize - 4)
    textWidth := i
  }
  Else
  {    ;; 'else' calculates the width to a given string.
    textWidth := StrLen(x) * (Config_fontSize - 1)
    If (Config_fontSize = 7 Or (Config_fontSize > 8 And Config_fontSize < 13))
      textWidth := StrLen(x) * (Config_fontSize - 2)
    Else If (Config_fontSize > 12 And Config_fontSize < 18)
      textWidth := StrLen(x) * (Config_fontSize - 3)
    Else If (Config_fontSize > 17)
      textWidth := StrLen(x) * (Config_fontSize - 4)
  }

  Return, textWidth
}

Bar_GuiClick:
  Manager_winActivate(Bar_aWndId)
  If (A_GuiEvent = "Normal")
  {
    If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
      Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
    If (SubStr(A_GuiControl, -6) = "_layout")
      View_setLayout(-1)
    Else If (SubStr(A_GuiControl, -4) = "_view")
      Monitor_activateView(SubStr(A_GuiControl, InStr(A_GuiControl, "_#", False, 0) + 2, 1))
  }
Return

Bar_GuiContextMenu:
  Manager_winActivate(Bar_aWndId)
  If (A_GuiEvent = "RightClick")
  {
    If (SubStr(A_GuiControl, -6) = "_layout")
    {
      If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
        Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
      View_setLayout(">")
    }
    Else If (SubStr(A_GuiControl, -4) = "_view")
    {
      If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
        Manager_setWindowMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
      Monitor_setWindowTag(SubStr(A_GuiControl, InStr(A_GuiControl, "_#", False, 0) + 2, 1))
    }
  }
Return

Bar_loop:
  Bar_updateStatus()
Return

Bar_move(m)
{
  Local wndTitle, x, y

  x := Monitor_#%m%_barX
  y := Monitor_#%m%_barY

  wndTitle := "bug.n_BAR_" m
  WinMove, %wndTitle%, , %x%, %y%
}

Bar_toggleCommandGui:
  If Not Bar_cmdGuiIsVisible
    If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
      Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
  Bar_toggleCommandGui()
Return

Bar_toggleCommandGui()
{
  Local wndId, x, y

  Gui, 99: Default
  If Bar_cmdGuiIsVisible
  {
    Bar_cmdGuiIsVisible := False
    Gui, Cancel
    Manager_winActivate(Bar_aWndId)
  }
  Else
  {
    Bar_cmdGuiIsVisible := True
    x := Monitor_#%Manager_aMonitor%_barX + Monitor_#%Manager_aMonitor%_barWidth - Bar_#0_#0W
    If (Config_verticalBarPos = "top") Or (Config_verticalBarPos = "tray" And (Manager_taskBarPos = "top" Or Not Manager_aMonitor = Manager_taskBarMonitor))
      y := Monitor_#%Manager_aMonitor%_y
    Else
      y := Monitor_#%Manager_aMonitor%_y + Monitor_#%Manager_aMonitor%_height - Bar_#0_#0H
    Gui, Show
    WinMove, bug.n_BAR_0, , %x%, %y%
    GuiControl, Focus, % Bar_#0_#0
  }
}

Bar_toggleVisibility(m)
{
  Local GuiN

  GuiN := (m - 1) + 1
  If Monitor_#%m%_showBar
  {
    If Not (GuiN = 99) Or Bar_cmdGuiIsVisible
      Gui, %GuiN%: Show
  }
  Else
    Gui, %GuiN%: Cancel
}

Bar_updateLayout(m)
{
  Local aView, GuiN, i

  aView := Monitor_#%m%_aView_#1
  i := Config_viewCount + 1
  GuiN := (m - 1) + 1
  GuiControl, %GuiN%: , Bar_#%m%_#%i%, % View_#%m%_#%aView%_layoutSymbol
}

Bar_updateStatus()
{
  Local anyContent, anyText, b1, b2, b3, GuiN, i, m

  Loop, % Manager_monitorCount
  {
    m := A_Index
    GuiN := (m - 1) + 1
    Debug_logMessage("DEBUG[6] Bar_updateStatus(): Gui, " . GuiN . ": Default", 6)
    Gui, %GuiN%: Default
    If Config_readinBat
    {
      Bar_getBatteryStatus(b1, b2)
      b3 := SubStr("  " b1, -2)
      i := Config_viewCount + 3
      If (b1 < 10) And (b2 = "off")
      {    ;; Change the color, if the battery level is below 10%
        GuiControl, +Background%Config_normBgColor4% +c%Config_normBgColor2%, Bar_#%m%_#%i%_tagged
        GuiControl, +c%Config_selFgColor6%, Bar_#%m%_#%i%
      }
      Else If (b2 = "off")
      {    ;; Change the color, if the pc is not plugged in
        GuiControl, +Background%Config_normBgColor2% +c%Config_normFgColor5%, Bar_#%m%_#%i%_tagged
        GuiControl, +c%Config_normFgColor4%, Bar_#%m%_#%i%
      }
      Else
      {
        GuiControl, +Background%Config_normBgColor3% +c%Config_normFgColor3%, Bar_#%m%_#%i%_tagged
        GuiControl, +c%Config_normFgColor2%, Bar_#%m%_#%i%
      }
      GuiControl, , Bar_#%m%_#%i%_tagged, %b3%
      GuiControl, , Bar_#%m%_#%i%, % " BAT: " b3 "% "
    }
    anyText := Config_readinAny()
    If anyText
    {
      i := Config_viewCount + 4
      GuiControlGet, anyContent, , Bar_#%m%_#%i%
      If Not (anyText = anyContent)
        GuiControl, , Bar_#%m%_#%i%, % anyText
    }
    If Config_readinTime
    {
      i := Config_viewCount + 5
      GuiControl, , Bar_#%m%_#%i%, % " " A_Hour ":" A_Min " "
    }
  }
}

Bar_updateTitle(debugMsg = "")
{
  Local aWndId, aWndTitle, content, GuiN, i, title

  If debugMsg
    aWndTitle := debugMsg
  Else
  {
    WinGet, aWndId, ID, A
    WinGetTitle, aWndTitle, ahk_id %aWndId%
    If InStr(Bar_hideTitleWndIds, aWndId ";") Or (aWndTitle = "bug.n_BAR_0")
      aWndTitle := ""
    If Manager_#%aWndId%_isFloating
      aWndTitle := "~ " aWndTitle
    If (Manager_monitorCount > 1)
      aWndTitle := "[" Manager_aMonitor "] " aWndTitle
  }
  title := " " . aWndTitle . " "

  If (Bar_getTextWidth(title) > Bar_#%Manager_aMonitor%_titleWidth)
  {    ;; Shorten the window title if its length exceeds the width of the bar
    i := Bar_getTextWidth(Bar_#%Manager_aMonitor%_titleWidth, True) - 6
    StringLeft, title, aWndTitle, i
    title := " " . title . " ... "
  }

  i := Config_viewCount + 2
  Loop, % Manager_monitorCount
  {
    GuiN := (A_Index - 1) + 1
    Debug_logMessage("DEBUG[6] Bar_updateTitle(): Gui, " . GuiN . ": Default", 6)
    Gui, %GuiN%: Default
    GuiControlGet, content, , Bar_#%A_Index%_#%i%
    If (A_Index = Manager_aMonitor)
    {
      If Not (content = title)
        GuiControl, , Bar_#%A_Index%_#%i%, % title
    } Else If Not (content = "")
      GuiControl, , Bar_#%A_Index%_#%i%,
  }
  Bar_aWndId := aWndId
}

Bar_updateView(m, v)
{
  Local managedWndId0, wndId0, wndIds

  GuiN := (m - 1) + 1
  Gui, %GuiN%: Default
  Debug_logMessage("DEBUG[6] Bar_updateView(): m: " . m . "; Gui, " . GuiN . ": Default", 6)

  StringTrimRight, wndIds, Manager_managedWndIds, 1
  StringSplit, managedWndId, wndIds, `;

  If (v = Monitor_#%m%_aView_#1)
  { ;; Set foreground/background colors if the view is the current view.
    GuiControl, +Background%Config_selBgColor1% +c%Config_selFgColor2%, Bar_#%m%_#%v%_tagged
    GuiControl, +c%Config_selFgColor1%, Bar_#%m%_#%v%
  }
  Else If wndId0
  { ;; Set foreground/background colors if the view contains windows.
    GuiControl, +Background%Config_normBgColor5% +c%Config_normFgColor8%, Bar_#%m%_#%v%_tagged
    GuiControl, +c%Config_normFgColor7%, Bar_#%m%_#%v%
  }
  Else
  { ;; Set foreground/background colors if the view is empty.
    GuiControl, +Background%Config_normBgColor1% +c%Config_normFgColor8%, Bar_#%m%_#%v%_tagged
    GuiControl, +c%Config_normFgColor1%, Bar_#%m%_#%v%
  }

  Loop, %Config_viewCount%
  {
    StringTrimRight, wndIds, View_#%m%_#%A_Index%_wndIds, 1
    StringSplit, wndId, wndIds, `;
    GuiControl, , Bar_#%m%_#%A_Index%_tagged, % wndId0 / managedWndId0 * 100    ;; Update the percentage fill for the view.
    GuiControl, , Bar_#%m%_#%A_Index%, % Config_viewNames_#%A_Index%            ;; Refresh the number on the bar.
  }
}
