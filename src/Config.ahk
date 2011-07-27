/**
 *	bug.n - tiling window management
 *	Copyright (c) 2010-2011 joten
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *	@version 8.2.0.03 (27.07.2011)
 */

Config_init() {
	Local i, key, layout0, layout1, layout2, layout_#1, layout_#2, layout_#3
	
	; status bar
	Config_showBar			:= True							; If false, the bar is hidden. It can be made visible or hidden by hotkey (see below).
	Config_horizontalBarPos := "left"						; The horizontal position of the bar: "center", "left" or "right" side of the monitor or an offset in pixel (px) from the left (>= 0) or right (< 0).
	Config_verticalBarPos   := "top"						; The vertical position of the bar: "top" or "bottom" of the monitor, "tray" = sub-window of the task bar.
	Config_barWidth         := "100%"						; The width of the bar in pixel (px) or with a per cent sign (%) as a percentage.
	Config_singleRowBar     := True							; If false, the bar will have to rows, one for the window title and one for all other GUI controls.
	Config_spaciousBar      := False						; If true, the height of the bar will be set to a value equal to the height of an edit control, else it will be set to the text height.
	Config_fontName			:= "Lucida Console"				; A monospace font is preferable for bug.n to calculate the correct width of the bar and its elements (sub-windows).
	Config_readinBat		:= False						; If true, the system battery status is read in and displayed in the status bar. This only makes sense, if you have a system battery (notebook).
	Config_readinCpu		:= False						; If true, the current CPU load is read in and displayed in the status bar.
	Config_readinDate		:= True							; If true, the current date is read in (format: "WW, DD. MMM. YYYY") and displayed in the status bar.
	Config_readinTime		:= True							; If true, the current time is read in (format: "HH:MM") and displayed in the status bar.
	Config_readinInterval	:= 30000						; Time in milliseconds after which the above status values are refreshed.
	
	; Windows ui elements
	Config_bbCompatibility	:= False						; If true, bug.n looks for BlackBox components (bbLeanBar, bbSlit and SystemBarEx) when calculating the work area. It is assumed that the virtual desktop functionality of BlackBox and NOT bug.n is used (=> Hiding and showing windows is detected and acted upon).
	Config_borderWidth		:= 0							; If > 0, the window border width is set to the integer value Config_borderWidth.
	Config_borderPadding	:= -1							; If >= 0, the window border padding is set to the integer value Config_borderPadding (only for Windows >= Vista).
	Config_showTaskBar		:= False						; If false, the task bar is hidden. It can be made visible or hidden by hotkey (see below).
	Config_showBorder		:= True							; If false, the window borders are hidden; therefor windows cannot be resized manually by dragging the border, even if using the according hotkey.
	Config_selBorderColor	:= ""							; Border colour of the active window; format: 0x00BBGGRR (e. g. "0x006A240A", if = "", the system's window border colour is not changed).
															; Config_borderWidth, Config_borderPadding and Config_selBorderColor are especially usefull, if you are not allowed to set the design in the system settings.	
	; window arrangement
	Config_viewCount			:= 9						; The total number of views. This has effects on the displayed groups in the bar, and should not be exceeded in the hotkeys below.
	layout_#1					:= "[]=;tile"				; The layout symbol and arrange function (the first entry is set as the default layout, no layout function means floating behavior)
	layout_#2					:= "[M];monocle"
	layout_#3					:= "><>;"
	Config_layoutCount			:= 3						; Total number of layouts defined above.
	Config_layoutAxis_#1		:= 1						; The layout axis: 1 = x, 2 = y; negative values mirror the layout, setting the master area to the right / bottom instead of left / top.
	Config_layoutAxis_#2		:= 2						; The master axis: 1 = x (from left to right), 2 = y (from top to bottom), 3 = z (monocle).
	Config_layoutAxis_#3		:= 2						; The stack axis:  1 = x (from left to right), 2 = y (from top to bottom), 3 = z (monocle).
	Config_layoutMFactor		:= 0.6						; The factor for the size of the master area, which is multiplied by the monitor size.
	Config_monitorFollowsMouse  := False					; If true, the active monitor is determined by the position of the mouse pointer, if a window is opened; therefor the newly opened window will be moved there by default.
	Config_mouseFollowsFocus	:= True						; If true, the mouse pointer is set over the focused window, if a window is activated by bug.n.
	Config_shellMsgDelay		:= 350						; The time bug.n waits after a shell message (a window is opened, closed or the focus has been changed); if there are any problems recognizing, when windows are opened or closed, try to increase this number.
	Config_viewFollowsTagged	:= False					; If true, the view is set to, if a window is tagged with a single tag.
	
	; Config_rules_#i	:= "<class (regular expression string)>;<title (regular expression string)>;<window style (hexadecimal number or blank)>;<is managed (1 = True or 0 = False)>;<monitor (0 <= integer <= total number of monitors, 0 means the currently active monitor)>;<tags (binary mask as integer >= 0, e. g. 17 for 1 and 5, 0 means the currently active tag)>;<is floating (1 = True or 0 = False)>;<is decorated (1 = True or 0 = False)>;<hide title (1 = True or 0 = False)>" (";" is not allowed as a character)
	Config_rules_#1		:= ".*;.*;;1;0;0;0;0;0"				; At first you may set a default rule (.*;.*;) for a default monitor, view and / or showing window title bars.
	Config_rules_#2		:= ".*;.*;0x80000000;0;0;0;1;1;1"	; Pop-up windows (style WS_POPUP=0x80000000) will not be managed, are floating and the titles are hidden.
	Config_rules_#3		:= "SWT_Window0;.*;;1;0;0;0;0;0"	; Windows created by Java (SWT) e. g. Eclipse have the style WS_POPUP, but should excluded from the above rule.
	Config_rules_#4		:= "Xming;.*;;1;0;0;0;0;0"			; Xming windows have the style WS_POPUP, but should be excluded from the above rule.
	Config_rules_#5		:= "_sp;_sp;;1;0;0;1;0;1"
	Config_rules_#6		:= "MozillaDialogClass;.*;;1;0;0;1;1;0"
	Config_rules_#7		:= "MsiDialog(No)?CloseClass;.*;;1;0;0;1;1;0"
	Config_rules_#8		:= "gdkWindowToplevel;GIMP-Start;;1;0;0;1;1;0"
	Config_rules_#9		:= "gdkWindowToplevel;GNU Image Manipulation Program;;1;0;0;1;1;0"
	Config_rules_#10	:= "gdkWindowToplevel;Werkzeugkasten;;1;0;0;1;1;0"
	Config_rules_#11	:= "gdkWindowToplevel;Ebenen, .* - Pinsel, Muster, .*;;1;0;0;1;1;0"
	Config_rules_#12	:= "gdkWindowToplevel;Toolbox;;1;0;0;1;1;0"
	Config_rules_#13	:= "gdkWindowToplevel;Layers, Channels, Paths, .*;;1;0;0;1;1;0"
	Config_rules_#14	:= "CalcFrame;.*;;1;0;0;1;1;0"
	Config_rulesCount	:= 14								; This variable has to be set to the total number of active rules above.
	
	; session management
	Config_autoSaveSession := False							; Automatically save the current state of monitors, views, layouts (active view, layout, axes, mfact and msplit) to te session file (set below) when quitting bug.n.
	If Not Config_sessionFilePath							; The file path, to which the session is saved. This target directory must be writable by the user (%A_ScriptDir% is the diretory, in which "Main.ahk" or the executable of bug.n is saved).
		Config_sessionFilePath := A_ScriptDir "\Session.ini"
	
	Session_restore("Config")
	Config_getSystemSettings()
	Config_initColors()
	Loop, % Config_hotkeyCount {
		i := InStr(Config_hotkey_#%A_Index%, "::")
		Config_hotkey_#%A_index%_key := SubStr(Config_hotkey_#%A_Index%, 1, i - 1)
		Config_hotkey_#%A_index%_command := SubStr(Config_hotkey_#%A_Index%, i + 2)
		key := Config_hotkey_#%A_index%_key
		If Not Config_hotkey_#%A_index%_command
			Hotkey, %key%, Off
		Else
			Hotkey, %key%, Config_hotkeyLabel
	}
	Loop, % Config_layoutCount {
		StringSplit, layout, layout_#%A_Index%, `;
		Config_layoutFunction_#%A_Index% := layout2
		Config_layoutSymbol_#%A_Index%   := layout1
	}
	If (Config_viewCount > 9)
		Config_viewCount := 9
}

Config_initColors() {
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

Config_convertSystemColor(systemColor) {	; systemColor format: 0xBBGGRR
	rr := SubStr(systemColor, 7, 2)
	gg := SubStr(systemColor, 5, 2)
	bb := SubStr(systemColor, 3, 2)
	
	Return, rr gg bb
}

Config_getSystemSettings() {
	Global Config_fontName, Config_fontSize, Config_normBgColor, Config_normFgColor, Config_selBgColor, Config_selFgColor
	
	If Not Config_fontName {
		ncmSize := VarSetCapacity(ncm, 44 + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), 0)
		NumPut(ncmSize, ncm, 0, "UInt")
		DllCall("SystemParametersInfo", "UInt", 0x0029, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
		
		VarSetCapacity(lf, 28 + 32 * (A_IsUnicode ? 2 : 1), 0)
		DllCall("RtlMoveMemory", "Str", lf, "UInt", &ncm + 24, "UInt", 28 + 32 * (A_IsUnicode ? 2 : 1))
		VarSetCapacity(Config_fontName, 32 * (A_IsUnicode ? 2 : 1), 0)
		DllCall("RtlMoveMemory", "Str", Config_fontName, "UInt", &lf + 28, "UInt", 32 * (A_IsUnicode ? 2 : 1))
		; maestrith: Script Writer (http://www.autohotkey.net/~maestrith/Script Writer/)
	}
	If Not Config_fontSize {
		ncmSize := VarSetCapacity(ncm, 44 + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), 0)
		NumPut(ncmSize, ncm, 0, "UInt")
		DllCall("SystemParametersInfo", "UInt", 0x0029, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
		
		lfSize := VarSetCapacity(lf, 28 + 32 * (A_IsUnicode ? 2 : 1), 0)
		NumPut(lfSize, lf, 0, "UInt")
		DllCall("RtlMoveMemory", "Str", lf, "UInt", &ncm + 24, "UInt", 28 + 32 * (A_IsUnicode ? 2 : 1))
		
		lfHeightSize := VarSetCapacity(lfHeight, 4, 0)
		NumPut(lfHeightSize, lfHeight, 0, "Int")
		lfHeight := NumGet(lf, 0, "Int")
		
		lfPixelsY := DllCall("GetDeviceCaps", "UInt", DllCall("GetDC", "UInt", 0), "UInt", 90)	; LOGPIXELSY
		Config_fontSize := -DllCall("MulDiv", "Int", lfHeight, "Int", 72, "Int", lfPixelsY)
		; maestrith: Script Writer (http://www.autohotkey.net/~maestrith/Script Writer/)
	}
	SetFormat, Integer, hex
	If Not Config_normBgColor {
		Config_normBgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 4))		; COLOR_MENU
		Config_normBgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 3))	; COLOR_INACTIVECAPTION
		Config_normBgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 28))	; COLOR_GRADIENTINACTIVECAPTION
		Config_normBgColor .= ";Red"
		Config_normBgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 28))	; COLOR_GRADIENTINACTIVECAPTION
	}
	If Not Config_normFgColor {
		Config_normFgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 7))		; COLOR_MENUTEXT
		Config_normFgColor .= ";Default"
		Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 3))	; COLOR_INACTIVECAPTION
		Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 19))	; COLOR_INACTIVECAPTIONTEXT
		Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 13))	; COLOR_HIGHLIGHT
		Config_normFgColor .= ";White"
		Config_normFgColor .= ";Default"
		Config_normFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 3))	; COLOR_INACTIVECAPTION
	}
	If Not Config_selBgColor {
		Config_selBgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 27))		; COLOR_GRADIENTACTIVECAPTION
	}
	If Not Config_selFgColor {
		Config_selFgColor := Config_convertSystemColor(DllCall("GetSysColor", "Int", 9))		; COLOR_CAPTIONTEXT
		Config_selFgColor .= ";" Config_convertSystemColor(DllCall("GetSysColor", "Int", 2))	; COLOR_ACTIVECAPTION
	}
	SetFormat, Integer, d
}

Config_hotkeyLabel:
	Config_redirectHotkey(A_ThisHotkey)
Return

Config_readinAny() {										; Add information to the variable "text" in this function to display it in the status bar.
	Global Config_readinCpu, Config_readinDate
	
	text := ""
	If Config_readinCpu
		text .= " CPU: " Bar_getSystemTimes() "% "
	If Config_readinDate And Config_readinCpu
		text .= "|"
	If Config_readinDate
		text .= " " A_DDD ", " A_DD ". " A_MMM ". " A_YYYY " "
	
	Return, text
}

Config_redirectHotkey(key) {
	Local functionArgument0, functionArgument1, functionArgument2, functionArguments, functionName, i, j, parameter0, parameter1, parameter2, parameter3, parameters, type
	
	Loop, % Config_hotkeyCount
		If (key = Config_hotkey_#%A_index%_key) {
			type := SubStr(Config_hotkey_#%A_index%_command, 1, 5)
			If (type = "Run, ") {
				parameters := SubStr(Config_hotkey_#%A_index%_command, 6)
				If InStr(parameters, ", ") {
					StringSplit, parameter, parameters, `,
					If (parameter0 = 2) {
						StringTrimLeft, parameter2, parameter2, 1
						Run, %parameter1%, %parameter2%
					} Else If (parameter0 > 2) {
						StringTrimLeft, parameter2, parameter2, 1
						StringTrimLeft, parameter3, parameter3, 1
						Run, %parameter1%, %parameter2%, %parameter3%
					}
				} Else
					Run, %parameters%
			} Else If (type = "Send ")
				Send % SubStr(Config_hotkey_#%A_index%_command, 6)
			Else {
				i := InStr(Config_hotkey_#%A_index%_command, "(")
				j := InStr(Config_hotkey_#%A_index%_command, ")", False, i)
				If i And j {
					functionName := SubStr(Config_hotkey_#%A_index%_command, 1, i - 1)
					functionArguments := SubStr(Config_hotkey_#%A_index%_command, i + 1, j - (i + 1))
					StringSplit, functionArgument, functionArguments, `,
					If (functionArgument0 < 2)
						%functionName%(functionArguments)
					Else If (functionArgument0 = 2) {
						StringTrimLeft, functionArgument2, functionArgument2, 1
						%functionName%(functionArgument1, functionArgument2)
					}
				}
			}
			Break
		}
}

/**
 *	key definitions
 *
 *	format: <modifier><key>::<function>(<argument>)
 *	modifier: ! = Alt (Mod1Mask), ^ = Ctrl (ControlMask), + = Shift (ShiftMask), # = LWin (Mod4Mask)
 */

#Down::View_activateWindow(+1)				; Activate the next window in the active view.
#Up::View_activateWindow(-1)				; Activate the previous window in the active view.
#+Down::View_shuffleWindow(+1)				; Move the active window to the next position in the window list of the view.
#+Up::View_shuffleWindow(-1)				; Move the active window to the previous position in the window list of the view.
#+Enter::View_shuffleWindow(0)				; Move the active window to the first position in the window list of the view.
#c::Manager_closeWindow()					; Close the active window.
#+d::Manager_toggleDecor()					; Show / Hide the title bar of the active window.
#+f::View_toggleFloating()					; Toggle the floating status of the active window (i. e. dis- / regard it when tiling).
#+m::Manager_moveWindow()					; Move the active window by key (only floating windows).
#+s::Manager_sizeWindow()					; Resize the active window by key (only floating windows).
#+x::Manager_maximizeWindow()				; Move and resize the active window to the size of the work area (only floating windows).
#i::Manager_getWindowInfo()					; Get information for the active window (id, title, class, process name, style, geometry, tags and floating state).
#+i::Manager_getWindowList()				; Get a window list for the active view (id, title and class).

#Tab::View_setLayout(-1)					; Set the previously set layout. You may also use View_setLayout(">") for setting the next layout in the layout array.
#f::View_setLayout(3)						; Set the 3rd defined layout (i. e. floating layout in the default configuration).
#m::View_setLayout(2)						; Set the 2nd defined layout (i. e. monocle layout in the default configuration).
#t::View_setLayout(1)						; Set the 1st defined layout (i. e. tile layout in the default configuration).
#Left::View_setMFactor(-0.05)				; Reduce the size of the master area in the active view (only for the "tile" layout).
#Right::View_setMFactor(+0.05)				; Enlarge the size of the master area in the active view (only for the "tile" layout).
#^t::View_rotateLayoutAxis(1, +1)			; Rotate the layout axis (i. e. 2 -> 1 = vertical layout, 1 -> 2 = horizontal layout, only for the "tile" layout).
#^Enter::View_rotateLayoutAxis(1, +2)		; Mirror the layout axis (i. e. -1 -> 1 / 1 -> -1 = master on the left / right side, -2 -> 2 / 2 -> -2 = master at top / bottom, only for the "tile" layout).
#^Tab::View_rotateLayoutAxis(2, +1)			; Rotate the master axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).
#^+Tab::View_rotateLayoutAxis(3, +1)		; Rotate the stack axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).
#^Left::View_setMSplit(+1)					; Move the master splitter, i. e. decrease the number of windows in the master area (only for the "tile" layout).
#^Right::View_setMSplit(-1)					; Move the master splitter, i. e. increase the number of windows in the master area (only for the "tile" layout).

#BackSpace::Monitor_activateView(-1)		; Activate the previously activated view. You may also use Monitor_activateView("<") or Monitor_activateView(">") for activating the previous or next adjacent view.
#+0::Monitor_setWindowTag(0)				; Tag the active window with all tags (1 ... Config_viewCount). You may also use Monitor_setWindowTag("<") or Monitor_setWindowTag(">") for setting the tag of the previous or next adjacent to the current view.
#1::Monitor_activateView(1)					; Activate the view (choose one out of 1 ... Config_viewCount).
#+1::Monitor_setWindowTag(1)				; Tag the active window (choose one tag out of 1 ... Config_viewCount).
#^1::Monitor_toggleWindowTag(1)				; Add / Remove the tag (1 ... Config_viewCount) for the active window, if it is not / is already set.
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

#.::Manager_activateMonitor(+1)				; Activate the next monitor in a multi-monitor environment.
#,::Manager_activateMonitor(-1)				; Activate the previous monitor in a multi-monitor environment.
#+.::Manager_setWindowMonitor(+1)			; Set the active window to the active view on the next monitor in a multi-monitor environment.
#+,::Manager_setWindowMonitor(-1)			; Set the active window to the active view on the previous monitor in a multi-monitor environment.
#^+.::Manager_setViewMonitor(+1)			; Set all windows of the active view on the active view of the next monitor in a multi-monitor environment.
#^+,::Manager_setViewMonitor(-1)			; Set all windows of the active view on the active view of the previous monitor in a multi-monitor environment.

#+Space::Monitor_toggleBar()				; Hide / Show the bar (bug.n status bar) on the active monitor.
#Space::Monitor_toggleTaskBar()				; Hide / Show the task bar.
#y::Bar_toggleCommandGui()					; Open the command GUI for executing programmes or bug.n functions.
#^e::Run, edit, %Config_sessionFilePath%	; Open the session file in the standard text editor.
#^s::Session_save()							; Save the current state of monitors, views, layouts.
#^r::Reload									; For resetting the confguration, if running bug.n as an Autohotkey script.
#^q::ExitApp								; Quit bug.n, restore the default Windows UI and show all windows.
