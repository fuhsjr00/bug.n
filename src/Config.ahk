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

Config_init()
{
  Local i, key, layout0, layout1, layout2, vNames0, vNames1, vNames2, vNames3, vNames4, vNames5, vNames6, vNames7, vNames8, vNames9

  ;; Status bar
  Config_showBar           := True
  Config_horizontalBarPos  := "left"
  Config_verticalBarPos    := "top"
  Config_barWidth          := "100%"
  Config_singleRowBar      := True
  Config_spaciousBar       := False
  Config_fontName          := "Lucida Console"
  Config_fontSize          :=
  Config_normBgColor       :=
  Config_normFgColor       :=
  Config_selBgColor        :=
  Config_selFgColor        :=
  Config_barCommands       := "Run, explore doc;Monitor_toggleBar();Main_reload();Reload;ExitApp"
  Config_readinBat         := False
  Config_readinCpu         := False
  Config_readinDate        := True
  Config_readinDiskLoad    := False
  Config_readinMemoryUsage := False
  Config_readinNetworkLoad := False
  Config_readinTime        := True
  Config_readinInterval    := 30000

  ;; Windows ui elements
  Config_bbCompatibility := False
  Config_borderWidth     := 0
  Config_borderPadding   := -1
  Config_showTaskBar     := False
  Config_showBorder      := True
  Config_selBorderColor  := ""

  ;; Window arrangement
  Config_viewNames          := "1;2;3;4;5;6;7;8;9"
  Config_layout_#1          := "[]=;tile"
  Config_layout_#2          := "[M];monocle"
  Config_layout_#3          := "><>;"
  Config_layoutCount        := 3
  Config_layoutAxis_#1      := 1
  Config_layoutAxis_#2      := 2
  Config_layoutAxis_#3      := 2
  Config_layoutGapWidth     := 0
  Config_layoutMFactor      := 0.6
  Config_ghostWndSubString  := " (Not Responding)"
  Config_mouseFollowsFocus  := True
  Config_viewMargins        := "0;0;0;0"
  Config_newWndPosition     := "top"
  Config_onActiveHiddenWnds := "view"
  Config_shellMsgDelay      := 350
  Config_syncMonitorViews   := 0
  Config_viewFollowsTagged  := False

  ;; Config_rule_#<i> := '<class>;<title>;<style>;<is managed>;<m>;<tags>;<is floating>;<is decorated>;<hide title>;<action>'
  Config_rule_#1   := ".*;.*;;1;0;0;0;0;0;"            ;; default rule
  Config_rule_#2   := ".*;.*;0x80000000;0;0;0;1;1;1;"  ;; Pop-up windows (style WS_POPUP=0x80000000) will not be managed, are floating and the titles are hidden.
  Config_rule_#3   := "SWT_Window0;.*;;1;0;0;0;0;0;"   ;; Windows created by Java (SWT) e. g. Eclipse have the style WS_POPUP, but should be excluded from the second rule.
  Config_rule_#4   := "QWidget;.*;;1;0;0;0;0;0;"       ;; ... also windows created by QT (QWidget)
  Config_rule_#5   := "Xming;.*;;1;0;0;0;0;0;"         ;; ... and Xming windows
  Config_rule_#6   := "MsiDialog(No)?CloseClass;.*;;1;0;0;1;1;0;"
  Config_rule_#7   := "AdobeFlashPlayerInstaller;.*;;1;0;0;1;0;1;"
  Config_rule_#8   := "CalcFrame;.*;;1;0;0;1;1;0;"
  Config_rule_#9   := "MozillaDialogClass;.*;;1;0;0;1;1;0;"
  Config_rule_#10  := "_sp;_sp;;1;0;0;1;0;1;"
  Config_rule_#11  := "MozillaWindowClass;.* - Mozilla Firefox;;1;0;0;0;1;0;Maximize"
  Config_rule_#12  := "Chrome_WidgetWin_1;.*;;1;0;0;0;1;0;Maximize"
  Config_ruleCount := 12                              ;; This variable has to be set to the total number of active rules above.

  ;; Configuration management
  Config_autoSaveSession := "auto"    ;; "off" | "auto" | "ask"
  ; @todo: To be removed?
  If Not Config_filePath                  ; The file path, to which the configuration and session is saved. This target directory must be writable by the user (%A_ScriptDir% is the diretory, in which "Main.ahk" or the executable of bug.n is saved).
    Config_filePath := A_ScriptDir "\Config.ini"
  Config_maintenanceInterval := 5000

  Config_restoreConfig(Config_filePath)
  Config_getSystemSettings()
  Config_initColors()
  Loop, % Config_layoutCount
  {
    StringSplit, layout, Config_layout_#%A_Index%, `;
    Config_layoutFunction_#%A_Index% := layout2
    Config_layoutSymbol_#%A_Index%   := layout1
  }
  StringSplit, vNames, Config_viewNames, `;
  If vNames0 > 9
    Config_viewCount := 9
  Else
    Config_viewCount := vNames0
  Loop, % Config_viewCount
  {
    Config_viewNames_#%A_Index% := vNames%A_Index%
  }
}

Config_initColors()
{
  Global

  StringReplace, Config_normBgColor, Config_normBgColor, `;0`;, `;000000`;, All
  Config_normBgColor := RegExReplace(Config_normBgColor, "^0;", "000000;")
  Config_normBgColor := RegExReplace(Config_normBgColor, ";0$", ";000000")
  StringSplit, Config_normBgColor, Config_normBgColor, `;

  StringReplace, Config_normFgColor, Config_normFgColor, `;0`;, `;000000`;, All
  Config_normFgColor := RegExReplace(Config_normFgColor, "^0;", "000000;")
  Config_normFgColor := RegExReplace(Config_normFgColor, ";0$", ";000000")
  StringSplit, Config_normFgColor, Config_normFgColor, `;

  StringReplace, Config_selBgColor, Config_selBgColor, `;0`;, `;000000`;, All
  Config_selBgColor := RegExReplace(Config_selBgColor, "^0;", "000000;")
  Config_selBgColor := RegExReplace(Config_selBgColor, ";0$", ";000000")
  StringSplit, Config_selBgColor, Config_selBgColor, `;

  StringReplace, Config_selFgColor, Config_selFgColor, `;0`;, `;000000`;, All
  Config_selFgColor := RegExReplace(Config_selFgColor, "^0;", "000000;")
  Config_selFgColor := RegExReplace(Config_selFgColor, ";0$", ";000000")
  StringSplit, Config_selFgColor, Config_selFgColor, `;
}

Config_convertSystemColor(systemColor)
{ ;; systemColor format: 0xBBGGRR
  rr := SubStr(systemColor, 7, 2)
  gg := SubStr(systemColor, 5, 2)
  bb := SubStr(systemColor, 3, 2)

  Return, rr gg bb
}

Config_getSystemSettings()
{
  Global Config_fontName, Config_fontSize, Config_normBgColor, Config_normFgColor, Config_selBgColor, Config_selFgColor

  If Not Config_fontName
  {
    ncmSize := VarSetCapacity(ncm, 4 * (A_OSVersion = WIN_VISTA ? 11 : 10) + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), 0)
    NumPut(ncmSize, ncm, 0, "UInt")
    DllCall("SystemParametersInfo", "UInt", 0x0029, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)

    VarSetCapacity(lf, 28 + 32 * (A_IsUnicode ? 2 : 1), 0)
    DllCall("RtlMoveMemory", "Str", lf, "UInt", &ncm + 24, "UInt", 28 + 32 * (A_IsUnicode ? 2 : 1))
    VarSetCapacity(Config_fontName, 32 * (A_IsUnicode ? 2 : 1), 0)
    DllCall("RtlMoveMemory", "Str", Config_fontName, "UInt", &lf + 28, "UInt", 32 * (A_IsUnicode ? 2 : 1))
    ;; maestrith: Script Writer (http://www.autohotkey.net/~maestrith/Script Writer/)
  }
  If Not Config_fontSize
  {
    ncmSize := VarSetCapacity(ncm, 4 * (A_OSVersion = WIN_VISTA ? 11 : 10) + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), 0)
    NumPut(ncmSize, ncm, 0, "UInt")
    DllCall("SystemParametersInfo", "UInt", 0x0029, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)

    lfSize := VarSetCapacity(lf, 28 + 32 * (A_IsUnicode ? 2 : 1), 0)
    NumPut(lfSize, lf, 0, "UInt")
    DllCall("RtlMoveMemory", "Str", lf, "UInt", &ncm + 24, "UInt", 28 + 32 * (A_IsUnicode ? 2 : 1))

    lfHeightSize := VarSetCapacity(lfHeight, 4, 0)
    NumPut(lfHeightSize, lfHeight, 0, "Int")
    lfHeight := NumGet(lf, 0, "Int")

    lfPixelsY := DllCall("GetDeviceCaps", "UInt", DllCall("GetDC", "UInt", 0), "UInt", 90)  ;; LOGPIXELSY
    Config_fontSize := -DllCall("MulDiv", "Int", lfHeight, "Int", 72, "Int", lfPixelsY)
    ;; maestrith: Script Writer (http://www.autohotkey.net/~maestrith/Script Writer/)
  }
  SetFormat, Integer, hex
  If Not Config_normBgColor
  {
    Config_normBgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 4))       ;; COLOR_MENU
    Config_normBgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 3))   ;; COLOR_INACTIVECAPTION
    Config_normBgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 28))  ;; COLOR_GRADIENTINACTIVECAPTION
    Config_normBgColor .= ";Red"
    Config_normBgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 28))  ;; COLOR_GRADIENTINACTIVECAPTION
  }
  If Not Config_normFgColor
  {
    Config_normFgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 7))       ;; COLOR_MENUTEXT
    Config_normFgColor .= ";Default"
    Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 3))   ;; COLOR_INACTIVECAPTION
    Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 19))  ;; COLOR_INACTIVECAPTIONTEXT
    Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 13))  ;; COLOR_HIGHLIGHT
    Config_normFgColor .= ";White"
    Config_normFgColor .= ";Default"
    Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 3))   ;; COLOR_INACTIVECAPTION
  }
  If Not Config_selBgColor
  {
    Config_selBgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 27))       ;; COLOR_GRADIENTACTIVECAPTION
  }
  If Not Config_selFgColor
  {
    Config_selFgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 9))        ;; COLOR_CAPTIONTEXT
    Config_selFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 2))    ;; COLOR_ACTIVECAPTION
  }
  SetFormat, Integer, d
}

Config_hotkeyLabel:
  Config_redirectHotkey(A_ThisHotkey)
Return

Config_readinAny()
{ ;; Add information to the variable 'text' in this function to display it in the status bar.
  Global Config_readinDate

  text := ""
  text .= ResourceMonitor_getText()
  If Config_readinDate
    text .= " " A_DDD ", " A_DD ". " A_MMM ". " A_YYYY " "

  Return, text
}

Config_redirectHotkey(key)
{
  Global

  Loop, % Config_hotkeyCount
  {
    If (key = Config_hotkey_#%A_index%_key)
    {
      Main_evalCommand(Config_hotkey_#%A_index%_command)
      Break
    }
  }
}

Config_restoreLayout(filename, m)
{
  Local i, var, val

  If Not FileExist(filename)
    Return

  Loop, READ, %filename%
    If (SubStr(A_LoopReadLine, 1, 10 + StrLen(m)) = "Monitor_#" m "_" Or SubStr(A_LoopReadLine, 1, 8 + StrLen(m)) = "View_#" m "_#") {
      i := InStr(A_LoopReadLine, "=")
      var := SubStr(A_LoopReadLine, 1, i - 1)
      val := SubStr(A_LoopReadLine, i + 1)
      %var% := val
    }
}

Config_restoreConfig(filename)
{
  Local cmd, i, key, type, val, var

  If Not FileExist(filename)
    Return

  Loop, READ, %filename%
    If (SubStr(A_LoopReadLine, 1, 7) = "Config_")
    {
      ;Log_msg("Processing line: " . A_LoopReadLine)
      i := InStr(A_LoopReadLine, "=")
      var := SubStr(A_LoopReadLine, 1, i - 1)
      val := SubStr(A_LoopReadLine, i + 1)
      type := SubStr(var, 1, 13)
      If (type = "Config_hotkey")
      {
        Debug_logMessage("Processing configured hotkey: " . A_LoopReadLine, 0)
        i := InStr(val, "::")
        key := SubStr(val, 1, i - 1)
        cmd := SubStr(val, i + 2)
        If Not cmd
          Hotkey, %key%, Off
        Else
        {
          Debug_logMessage("  Hotkey: " . key . " -> " . cmd, 0)
          Config_hotkeyCount += 1
          Config_hotkey_#%Config_hotkeyCount%_key := key
          Config_hotkey_#%Config_hotkeyCount%_command := cmd
          Hotkey, %key%, Config_hotkeyLabel
        }
      }
      Else If (type = "Config_rule")
      {
        i := 0
        If InStr(var, "Config_rule_#")
          i := SubStr(var, 14)
        If (i = 0 Or i > Config_ruleCount)
        {
          Config_ruleCount += 1
          i := Config_ruleCount
        }
        var := "Config_rule_#" i
      }
      %var% := val
    }
}

Config_UI_saveSession()
{
  Config_saveSession(Config_filePath, Config_filePath)
}

Config_saveSession(original, target)
{
  Local m, text, tmpfilename

  tmpfilename := target . ".tmp"
  FileDelete, %tmpfilename%

  text := "; bug.n - tiling window management`n; @version " VERSION "`n`n"
  If FileExist(original)
  {
    Loop, READ, %original%
    {
      If (SubStr(A_LoopReadLine, 1, 7) = "Config_")
        text .= A_LoopReadLine "`n"
    }
    text .= "`n"
  }

  Loop, % Manager_monitorCount
  {
    m := A_Index
    If Not (Monitor_#%m%_aView_#1 = 1)
      text .= "Monitor_#" m "_aView_#1=" Monitor_#%m%_aView_#1 "`n"
    If Not (Monitor_#%m%_aView_#2 = 1)
      text .= "Monitor_#" m "_aView_#2=" Monitor_#%m%_aView_#2 "`n"
    If Not (Monitor_#%m%_showBar = Config_showBar)
      text .= "Monitor_#" m "_showBar=" Monitor_#%m%_showBar "`n"
    Loop, % Config_viewCount
    {
      If Not (View_#%m%_#%A_Index%_layout_#1 = 1)
        text .= "View_#" m "_#" A_Index "_layout_#1=" View_#%m%_#%A_Index%_layout_#1 "`n"
      If Not (View_#%m%_#%A_Index%_layout_#2 = 1)
        text .= "View_#" m "_#" A_Index "_layout_#2=" View_#%m%_#%A_Index%_layout_#2 "`n"
      If Not (View_#%m%_#%A_Index%_layoutAxis_#1 = Config_layoutAxis_#1)
        text .= "View_#" m "_#" A_Index "_layoutAxis_#1=" View_#%m%_#%A_Index%_layoutAxis_#1 "`n"
      If Not (View_#%m%_#%A_Index%_layoutAxis_#2 = Config_layoutAxis_#2)
        text .= "View_#" m "_#" A_Index "_layoutAxis_#2=" View_#%m%_#%A_Index%_layoutAxis_#2 "`n"
      If Not (View_#%m%_#%A_Index%_layoutAxis_#3 = Config_layoutAxis_#3)
        text .= "View_#" m "_#" A_Index "_layoutAxis_#3=" View_#%m%_#%A_Index%_layoutAxis_#3 "`n"
      If Not (View_#%m%_#%A_Index%_layoutGapWidth = Config_layoutGapWidth)
        text .= "View_#" m "_#" A_Index "_layoutGapWidth=" View_#%m%_#%A_Index%_layoutGapWidth "`n"
      If Not (View_#%m%_#%A_Index%_layoutMFact = Config_layoutMFactor)
        text .= "View_#" m "_#" A_Index "_layoutMFact=" View_#%m%_#%A_Index%_layoutMFact "`n"
      If Not (View_#%m%_#%A_Index%_layoutMX = 1)
        text .= "View_#" m "_#" A_Index "_layoutMX=" View_#%m%_#%A_Index%_layoutMX "`n"
      If Not (View_#%m%_#%A_Index%_layoutMY = 1)
        text .= "View_#" m "_#" A_Index "_layoutMY=" View_#%m%_#%A_Index%_layoutMY "`n"
    }
  }

  ;; The FileMove below is an all-or-nothing replacement of the file.
  ;; We don't want to leave this half-finished.
  FileAppend, %text%, %tmpfilename%
  If ErrorLevel
  {
    If FileExist(tmpfilename)
      FileDelete, %tmpfilename%
  }
  Else
    FileMove, %tmpfilename%, %target%, 1
}

;; Key definitions
;; Window management
#Down::View_activateWindow(+1)
#Up::View_activateWindow(-1)
#+Down::View_shuffleWindow(+1)
#+Up::View_shuffleWindow(-1)
#+Enter::View_shuffleWindow(0)
#c::Manager_closeWindow()
#+d::Manager_toggleDecor()
#+f::View_toggleFloating()
#+m::Manager_moveWindow()
#+s::Manager_sizeWindow()
#+x::Manager_maximizeWindow()
#i::Manager_getWindowInfo()
#+i::Manager_getWindowList()

;; Window debugging
#^i::Debug_logViewWindowList()
#+^i::Debug_logManagedWindowList()
#^h::Debug_logHelp()
#^d::Debug_setLogLevel(-1)
#^+d::Debug_setLogLevel(+1)

;; Layout management
#Tab::View_setLayout(-1)
#f::View_setLayout(3)
#m::View_setLayout(2)
#t::View_setLayout(1)
#Left::View_setMFactor(-0.05)
#Right::View_setMFactor(+0.05)
#^t::View_rotateLayoutAxis(1, +1)
#^Enter::View_rotateLayoutAxis(1, +2)
#^Tab::View_rotateLayoutAxis(2, +1)
#^+Tab::View_rotateLayoutAxis(3, +1)
#^Up::View_setMY(+1)
#^Down::View_setMY(-1)
#^Right::View_setMX(+1)
#^Left::View_setMX(-1)
#+Left::View_setGapWidth(-2)
#+Right::View_setGapWidth(+2)

;; View/Tag management
#+n::View_toggleMargins()
#BackSpace::Monitor_activateView(-1)
#+0::Monitor_setWindowTag(0)
#1::Monitor_activateView(1)
#+1::Monitor_setWindowTag(1)
#^1::Monitor_toggleWindowTag(1)
#2::Monitor_activateView(2)
#+2::Monitor_setWindowTag(2)
#^2::Monitor_toggleWindowTag(2)
#3::Monitor_activateView(3)
#+3::Monitor_setWindowTag(3)
#^3::Monitor_toggleWindowTag(3)
#4::Monitor_activateView(4)
#+4::Monitor_setWindowTag(4)
#^4::Monitor_toggleWindowTag(4)
#5::Monitor_activateView(5)
#+5::Monitor_setWindowTag(5)
#^5::Monitor_toggleWindowTag(5)
#6::Monitor_activateView(6)
#+6::Monitor_setWindowTag(6)
#^6::Monitor_toggleWindowTag(6)
#7::Monitor_activateView(7)
#+7::Monitor_setWindowTag(7)
#^7::Monitor_toggleWindowTag(7)
#8::Monitor_activateView(8)
#+8::Monitor_setWindowTag(8)
#^8::Monitor_toggleWindowTag(8)
#9::Monitor_activateView(9)
#+9::Monitor_setWindowTag(9)
#^9::Monitor_toggleWindowTag(9)

;; Monitor management
#.::Manager_activateMonitor(+1)
#,::Manager_activateMonitor(-1)
#+.::Manager_setWindowMonitor(+1)
#+,::Manager_setWindowMonitor(-1)
#^+.::Manager_setViewMonitor(+1)
#^+,::Manager_setViewMonitor(-1)

;; GUI management
#+Space::Monitor_toggleBar()
#Space::Monitor_toggleTaskBar()
#y::Bar_toggleCommandGui()
#+y::Monitor_toggleNotifyIconOverflowWindow()

;; Administration
#^e::Run, edit %Config_filePath%
#^s::Config_UI_saveSession()
#^r::Main_reload()
#^+r::Reload
#^q::ExitApp
