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

Bar_init(m) {
  Local appBarMsg, anyText, color, color0, GuiN, h1, h2, i, id, id0, text, text0, titleWidth, trayWndId, w, wndId, wndTitle, wndWidth, x1, x2, y1, y2

  If (SubStr(Config_barWidth, 0) = "%") {
    StringTrimRight, wndWidth, Config_barWidth, 1
    wndWidth := Round(Monitor_#%m%_width * wndWidth / 100)
  } Else
    wndWidth := Config_barWidth

  wndWidth := Round(wndWidth * Config_scalingFactor)
  If (Config_verticalBarPos = "tray" And Monitor_#%m%_taskBarClass) {
    Bar_ctrlHeight := Round(Bar_ctrlHeight * Config_scalingFactor)
    Bar_height := Round(Bar_height * Config_scalingFactor)
  }

  Monitor_#%m%_barWidth := wndWidth
  titleWidth := wndWidth
  h1 := Bar_ctrlHeight
  x1 := 0
  x2 := wndWidth
  y1 := 0
  y2 := (Bar_ctrlHeight - Bar_textHeight) / 2
  h2 := Bar_textHeight

  ;; Create the GUI window
  wndTitle := "bug.n_BAR_" m
  GuiN := (m - 1) + 1
  Debug_logMessage("DEBUG[6] Bar_init(): Gui, " . GuiN . ": Default", 6)
  Gui, %GuiN%: Default
  Gui, Destroy
  Gui, +AlwaysOnTop -Caption +LabelBar_Gui +LastFound +ToolWindow
  Gui, Color, %Config_backColor_#1_#3%
  Gui, Font, c%Config_fontColor_#1_#3% s%Config_fontSize%, %Config_fontName%

  ;; Views
  Loop, % Config_viewCount {
    w := Bar_getTextWidth(" " Config_viewNames_#%A_Index% " ")
    Bar_addElement(m, "view_#" A_Index, " " Config_viewNames_#%A_Index% " ", x1, y1, w, Config_backColor_#1_#1, Config_foreColor_#1_#1, Config_fontColor_#1_#1)
    titleWidth -= w
    x1 += w
  }
  ;; Layout
  w := Bar_getTextWidth(" ?????? ")
  Bar_addElement(m, "layout", " ?????? ", x1, y1, w, Config_backColor_#1_#2, Config_foreColor_#1_#2, Config_fontColor_#1_#2)
  titleWidth -= w
  x1 += w

  ;; The x-position and width of the sub-windows right of the window title are set from the right.
  ;; <view>;<layout>;<title>;<shebang>;<time>;<date>;<anyText>;<batteryStatus>;<volumeLevel>
  color := "4"
  id    := "shebang"
  text  := " #! "
  If Config_readinTime {
    color .= ";5"
    id    .= ";time"
    text  .= "; " . Config_readinTimeFormat . " "
  }
  If Config_readinDate {
    color .= ";6"
    id    .= ";date"
    text  .= "; " . Config_readinDateFormat . " "
  }
  If Config_readinVolume {
    color .= ";9"
    id    .= ";volume"
    text  .= "; VOL: ???% "
  }
  anyText := Config_readinAny()
  If anyText {
    color .= ";7"
    id    .= ";anyText"
    text  .= ";" anyText
  }
  If Config_readinBat {
    color .= ";8"
    id    .= ";batteryStatus"
    text  .= "; BAT: ???% "
  }
  StringSplit, color, color, `;
  StringSplit, id, id, `;
  StringSplit, text, text, `;
  Loop, % id0 {
    If (id%A_Index% = "shebang")
      Gui, -Disabled
    w := Bar_getTextWidth(text%A_Index%)
    x2 -= w
    titleWidth -= w
    i := color%A_Index%
    Bar_addElement(m, id%A_Index%, text%A_Index%, x2, y1, w, Config_backColor_#1_#%i%, Config_foreColor_#1_#%i%, Config_fontColor_#1_#%i%)
  }

  ;; Window title (remaining space)
  If Not Config_singleRowBar {
    titleWidth := wndWidth
    x1 := 0
    y1 += h1
    y2 += h1
  }
  Bar_addElement(m, "title", "", x1, y1, titleWidth, Config_backColor_#1_#3, Config_foreColor_#1_#3, Config_fontColor_#1_#3)

  If (Config_horizontalBarPos = "left")
    x1 := 0
  Else If (Config_horizontalBarPos = "right")
    x1 := Monitor_#%m%_width - wndWidth / Config_scalingFactor
  Else If (Config_horizontalBarPos = "center")
    x1 := (Monitor_#%m%_width - wndWidth / Config_scalingFactor) / 2
  Else If (Config_horizontalBarPos >= 0)
    x1 := Config_horizontalBarPos
  Else If (Config_horizontalBarPos < 0)
    x1 := Monitor_#%m%_width - wndWidth / Config_scalingFactor + Config_horizontalBarPos
  If Not (Config_verticalBarPos = "tray" And Monitor_#%m%_taskBarClass)
    x1 += Monitor_#%m%_x
  x1 := Round(x1)

  Bar_#%m%_titleWidth := titleWidth
  Monitor_#%m%_barX := x1
  y1 := Monitor_#%m%_barY

  If Monitor_#%m%_showBar
    Gui, Show, NoActivate x%x1% y%y1% w%wndWidth% h%Bar_height%, %wndTitle%
  Else
    Gui, Show, NoActivate Hide x%x1% y%y1% w%wndWidth% h%Bar_height%, %wndTitle%
  WinSet, Transparent, %Config_barTransparency%, %wndTitle%
  wndId := WinExist(wndTitle)
  Bar_appBarData := ""
  If (Config_verticalBarPos = "tray" And Monitor_#%m%_taskBarClass) {
    trayWndId := WinExist("ahk_class " Monitor_#%m%_taskBarClass)
    DllCall("SetParent", "UInt", wndId, "UInt", trayWndId)
  } Else {
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
  Global Bar_#0_#0, Bar_#0_#0H, Bar_#0_#0W, Bar_#0_#1, Bar_cmdGuiIsVisible, Config_barCommands, Config_fontName, Config_fontSize
  Global Config_backColor_#1_#3, Config_fontColor_#1_#3, Config_foreColor_#1_#3

  Bar_#0_#0 := ""
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
  Gui, Add, ComboBox, x10 y10 r%cmd0% w300 Background%Config_backColor_#1_#3% c%Config_fontColor_#1_#3% Simple vBar_#0_#0 gBar_cmdGuiEnter, % Config_barCommands
  Gui, Add, Edit, Y0 w300 Hidden vBar_#0_#1 gBar_cmdGuiEnter
  Gui, Add, Button, Y0 Hidden Default gBar_cmdGuiEnter, OK
  GuiControlGet, Bar_#0_#0, Pos
  Bar_#0_#0H += 20
  Bar_#0_#0W += 20
  Gui, Show, Hide w%Bar_#0_#0W% h%Bar_#0_#0H%, %wndTitle%
}

Bar_addElement(m, id, text, x, y1, width, backColor, foreColor, fontColor) {
  Local y2

  y2 := y1 + (Bar_ctrlHeight - Bar_textHeight) / 2
  Gui, Add, Text, x%x% y%y1% w%width% h%Bar_ctrlHeight% BackgroundTrans vBar_#%m%_%id%_event gBar_GuiClick,
  Gui, Add, Progress, x%x% y%y1% w%width% h%Bar_ctrlHeight% Background%backColor% c%foreColor% vBar_#%m%_%id%_highlighted
  GuiControl, , Bar_#%m%_%id%_highlighted, 100
  Gui, Font, c%fontColor%
  Gui, Add, Text, x%x% y%y2% w%width% h%Bar_textHeight% BackgroundTrans Center vBar_#%m%_%id%, %text%
}

Bar_cmdGuiEnter:
  If (A_GuiControl = "OK") Or (A_GuiControl = "Bar_#0_#0" And A_GuiControlEvent = "DoubleClick") {
    Gui, Submit, NoHide
    Bar_cmdGuiIsVisible := False
    Gui, Cancel
    WinActivate, ahk_id %Bar_aWndId%
    Main_evalCommand(Bar_#0_#0)
    Bar_#0_#0 := ""
  } Else If (A_GuiControl = "Bar_#0_#1") {
    Gui, Submit, NoHide
    Debug_logMessage("DEBUG[6] Bar_cmdGuiEnter; command: " . Bar_#0_#1, 6)
    Loop, Parse, Bar_#0_#1, `n, `r
      Main_evalCommand(A_LoopField)
  }
Return

Bar_cmdGuiEscape:
  Bar_cmdGuiIsVisible := False
  Gui, Cancel
  WinActivate, ahk_id %Bar_aWndId%
Return

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
  If (A_GuiEvent = "Normal") {
    If (SubStr(A_GuiControl, -13) = "_shebang_event") {
      If Not Bar_cmdGuiIsVisible
        If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6) = Manager_aMonitor)
          Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6))
      Bar_toggleCommandGui()
    } Else {
      If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6) = Manager_aMonitor)
        Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6))
      If (SubStr(A_GuiControl, -12) = "_layout_event")
        View_setLayout(-1)
      Else If InStr(A_GuiControl, "_view_#") And (SubStr(A_GuiControl, -5) = "_event")
        Monitor_activateView(SubStr(A_GuiControl, InStr(A_GuiControl, "_view_#", False, 0) + 7, 1))
    }
  }
Return

Bar_GuiContextMenu:
  Manager_winActivate(Bar_aWndId)
  If (A_GuiEvent = "RightClick") {
    If (SubStr(A_GuiControl, -12) = "_layout_event") {
      If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6) = Manager_aMonitor)
        Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6))
      View_setLayout(0, +1)
    } Else If InStr(A_GuiControl, "_view_#") And (SubStr(A_GuiControl, -5) = "_event") {
      If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6) = Manager_aMonitor)
        Manager_setWindowMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_", False, 6) - 6))
      Monitor_setWindowTag(SubStr(A_GuiControl, InStr(A_GuiControl, "_view_#", False, 0) + 7, 1))
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

Bar_toggleCommandGui() {
  Local wndId, x, y

  Gui, 99: Default
  If Bar_cmdGuiIsVisible {
    Bar_cmdGuiIsVisible := False
    Gui, Cancel
    Manager_winActivate(Bar_aWndId)
  } Else {
    Bar_cmdGuiIsVisible := True
    
    If (Config_verticalBarPos = "tray")
      x := Monitor_#%Manager_aMonitor%_x + Monitor_#%Manager_aMonitor%_barX + Monitor_#%Manager_aMonitor%_barWidth - Bar_#0_#0W
    Else
      x := Monitor_#%Manager_aMonitor%_barX + Monitor_#%Manager_aMonitor%_barWidth - Bar_#0_#0W   ;; x := mX + (mBarX - mX) + mBarW - w
    
    If (Config_verticalBarPos = "top") Or (Config_verticalBarPos = "tray") And (Monitor_#%Manager_aMonitor%_taskBarPos = "top" Or Not Monitor_#%Manager_aMonitor%_taskBarClass)
      y := Monitor_#%Manager_aMonitor%_y
    Else
      y := Monitor_#%Manager_aMonitor%_y + Monitor_#%Manager_aMonitor%_height - Bar_#0_#0H
    
    Gui, Show
    WinGet, wndId, ID, bug.n_BAR_0
    WinMove, ahk_id %wndId%, , %x%, %y%
    Window_set(wndId, "AlwaysOnTop", "On")
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

Bar_updateLayout(m) {
  Local aView, GuiN

  aView := Monitor_#%m%_aView_#1
  GuiN := (m - 1) + 1
  GuiControl, %GuiN%: , Bar_#%m%_layout, % View_#%m%_#%aView%_layoutSymbol
}

Bar_updateStatic(m) {
  Local GuiN

  GuiN := (m - 1) + 1
  GuiControl, %GuiN%: , Bar_#%m%_shebang, #!
}

Bar_updateStatus() {
  Local anyText, bat1, bat2, bat3, GuiN, m, mute, time, vol

  anyText := Config_readinAny()
  If Config_readinBat {
    ResourceMonitor_getBatteryStatus(bat1, bat2)
    bat3 := SubStr("  " bat1, -2)
  }
  If Config_readinVolume {
    SoundGet, vol, MASTER, VOLUME
    SoundGet, mute, MASTER, MUTE
    vol := Round(vol)
  }

  Loop, % Manager_monitorCount {
    m := A_Index
    GuiN := (m - 1) + 1
    Debug_logMessage("DEBUG[6] Bar_updateStatus(): Gui, " . GuiN . ": Default", 6)
    Gui, %GuiN%: Default
    If Config_readinBat {
      If (bat1 < 10) And (bat2 = "off") {
        ;; Change the color, if the battery level is below 10%
        GuiControl, +Background%Config_backColor_#3_#8% +c%Config_foreColor_#3_#8%, Bar_#%m%_batteryStatus_highlighted
        GuiControl, +c%Config_fontColor_#3_#8%, Bar_#%m%_batteryStatus
      } Else If (bat2 = "off") {
        ;; Change the color, if the pc is not plugged in
        GuiControl, +Background%Config_backColor_#2_#8% +c%Config_foreColor_#2_#8%, Bar_#%m%_batteryStatus_highlighted
        GuiControl, +c%Config_fontColor_#2_#8%, Bar_#%m%_batteryStatus
      } Else {
        GuiControl, +Background%Config_backColor_#1_#8% +c%Config_foreColor_#1_#8%, Bar_#%m%_batteryStatus_highlighted
        GuiControl, +c%Config_fontColor_#1_#8%, Bar_#%m%_batteryStatus
      }
      GuiControl, , Bar_#%m%_batteryStatus_highlighted, %bat3%
      GuiControl, , Bar_#%m%_batteryStatus, % " BAT: " bat3 "% "
    }
    If anyText
      GuiControl, , Bar_#%m%_anyText, % anyText
    If Config_readinVolume {
      If (mute = "On") {
        ;; Change the color, if the mute is on
        GuiControl, +Background%Config_backColor_#1_#9% +c%Config_foreColor_#1_#9%, Bar_#%m%_volume_highlighted
        GuiControl, +c%Config_fontColor_#1_#9%, Bar_#%m%_volume
      } Else {
        GuiControl, +Background%Config_backColor_#2_#9% +c%Config_foreColor_#2_#9%, Bar_#%m%_volume_highlighted
        GuiControl, +c%Config_fontColor_#2_#9%, Bar_#%m%_volume
      }
      GuiControl, , Bar_#%m%_volume_highlighted, %vol%
      GuiControl, , Bar_#%m%_volume, % " VOL: " SubStr("  " vol, -2) "% "
    }
    If Config_readinDate {
      FormatTime, time, , % Config_readinDateFormat
      GuiControl, , Bar_#%m%_date, % time 
    }
    If Config_readinTime {
      FormatTime, time, , % Config_readinTimeFormat
      GuiControl, , Bar_#%m%_time, % time
    }
  }
}

Bar_updateTitle() {
  Local aWndId, aWndTitle, content, GuiN, i, title

  WinGet, aWndId, ID, A
  WinGetTitle, aWndTitle, ahk_id %aWndId%
  If InStr(Bar_hideTitleWndIds, aWndId ";") Or (aWndTitle = "bug.n_BAR_0")
    aWndTitle := ""
  If aWndId And InStr(Manager_managedWndIds, aWndId . ";") And Window_#%aWndId%_isFloating
    aWndTitle := "~ " aWndTitle
  If (Manager_monitorCount > 1)
    aWndTitle := "[" Manager_aMonitor "] " aWndTitle
  title := " " . aWndTitle . " "

  If (Bar_getTextWidth(title) > Bar_#%Manager_aMonitor%_titleWidth) {
    ;; Shorten the window title if its length exceeds the width of the bar
    i := Bar_getTextWidth(Bar_#%Manager_aMonitor%_titleWidth, True) - 6
    StringLeft, title, aWndTitle, i
    title := " " . title . " ... "
  }
  StringReplace, title, title, &, &&, All     ;; Special character '&', which would underline the next letter.

  Loop, % Manager_monitorCount {
    GuiN := (A_Index - 1) + 1
    Debug_logMessage("DEBUG[6] Bar_updateTitle(): Gui, " . GuiN . ": Default", 6)
    Gui, %GuiN%: Default
    GuiControlGet, content, , Bar_#%A_Index%_title
    If (A_Index = Manager_aMonitor) {
      If Not (content = title)
        GuiControl, , Bar_#%A_Index%_title, % title
    } Else If Not (content = "")
      GuiControl, , Bar_#%A_Index%_title,
  }
  Bar_aWndId := aWndId
}

Bar_updateView(m, v) {
  Local managedWndId0, wndId0, wndIds

  GuiN := (m - 1) + 1
  Gui, %GuiN%: Default
  Debug_logMessage("DEBUG[6] Bar_updateView(): m: " . m . "; Gui, " . GuiN . ": Default", 6)

  StringTrimRight, wndIds, Manager_managedWndIds, 1
  StringSplit, managedWndId, wndIds, `;

  If (v = Monitor_#%m%_aView_#1) {
    ;; Set foreground/background colors if the view is the current view.
    GuiControl, +Background%Config_backColor_#2_#1% +c%Config_foreColor_#2_#1%, Bar_#%m%_view_#%v%_highlighted
    GuiControl, +c%Config_fontColor_#2_#1%, Bar_#%m%_view_#%v%
  } Else {
    ;; Set foreground/background colors.
    GuiControl, +Background%Config_backColor_#1_#1% +c%Config_foreColor_#1_#1%, Bar_#%m%_view_#%v%_highlighted
    GuiControl, +c%Config_fontColor_#1_#1%, Bar_#%m%_view_#%v%
  }

  Loop, % Config_viewCount {
    StringTrimRight, wndIds, View_#%m%_#%A_Index%_wndIds, 1
    StringSplit, wndId, wndIds, `;
    GuiControl, , Bar_#%m%_view_#%A_Index%_highlighted, % wndId0 / managedWndId0 * 100    ;; Update the percentage fill for the view.
    GuiControl, , Bar_#%m%_view_#%A_Index%, % Config_viewNames_#%A_Index%                 ;; Refresh the number on the bar.
  }
}
