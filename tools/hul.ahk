/**
 *	hul! - Find and restore (hidden) windows
 *	Copyright (c) 2011 joten
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
 *	@version 0.1.0.01 (02.10.2011)
 */

NAME := "hul!"
VERSION := "0.1.0"
HELP := 
(Join 
"USAGE`n
`n
Specify one, two or all of the following search criteria:`n
- Type a regular expression in the field next to 'Partial title'.`n
- Type a class name (exact match) in the field next to 'Class name'.`n
- Type a process name (e. g. the name of an exeutable, exact match) in the field next to 'Process name'.`n
`n
The search will be done on typing the search criteria.`n
`n
You may navigate between the input fields by pressing Tab (forward) or Shift+Tab (back).`n
Press Enter to go to the list box, which contains the search results.`n
Select an entry and press Enter again to restore the selected window.`n
`n
Press the Escape (Esc) key to clear all fields and go back to entering the search criteria.`n"
)

/**
 * Script settings
 */
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon
#SingleInstance force
SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
; DetectHiddenWindows, On
; SetFormat, Integer, h

/**
 * Pseudo main function
 */
	WinGet, Main_aWndId, ID, A
	
	; BEGIN: Init GUI
	IfWinExist, %NAME%
		Gui, Destroy
	Gui, +LastFound +0xCF0000 -0x80000000
	
	Gui, Add, Text, yp+11, Partial Title: 
	Gui, Add, Edit, xp+82 yp-3 w700 gButtonSearch vGui_title, 
	
	Gui, Add, Text, xm, Class Name: 
	Gui, Add, Edit, xp+82 yp-3 w700 gButtonSearch vGui_class, 
	
	Gui, Add, Text, xm, Process Name: 
	Gui, Add, Edit, xp+82 yp-3 w700 gButtonSearch vGui_pName, 
	
	; Gui, Add, Button, xm w800 vGui_search, Search
	
	Gui, Add, ListBox, +0x100 t36 xm w800 vGui_wnds, 
	Gui, Add, Button, Default Hidden w800 vGui_restore, Restore
	
	Gui, Show, AutoSize, %NAME%
	Gui_wndId := WinExist()
	Main_resize()
	; END: Init GUI
Return 							; end of the auto-execute section

/**
 *	Hotkeys, function & label definitions
 */
#IfWinActive hul! ahk_class AutoHotkeyGUI
{
	^h::MsgBox %HELP%
}

ButtonRestore:
	Main_restore()
Return

ButtonSearch:
	Main_search()
Return

GuiClose:
	ExitApp
Return

GuiEscape:
	GuiControl, , Gui_title, 
	GuiControl, , Gui_class, 
	GuiControl, , Gui_pName, 
	GuiControl, , Gui_wnds, |
	GuiControl, Focus, Gui_title
Return

GuiSize:
	Main_resize(A_GuiWidth, A_GuiHeight)
Return

Main_resize(w = 0, h = 0) {
	Global Gui_wndId
	
	If (w = 0 Or h = 0) {
		Sleep, 250
		WinGetPos, x, y, w, h, ahk_id %Gui_wndId%
		h += 1
		WinMove, ahk_id %Gui_wndId%, , x, y, w, h
	} Else {
		w -= 2 * 10
		w1 := w - (72 + 10)
		h -= 3 * 30
		; y := 8 + (3 * 30) + h + 8
		GuiControl, Move, Gui_title, w%w1%
		GuiControl, Move, Gui_class, w%w1%
		GuiControl, Move, Gui_pName, w%w1%
		; GuiControl, Move, Gui_search, w%w%
		GuiControl, Move, Gui_wnds, w%w% h%h%
		; GuiControl, Move, Gui_restore, y%y% w%w%
	}
}

Main_restore() {
	Global Gui_wnds
	
	GuiControlGet, wnd, , Gui_wnds
	If wnd {
		wndId := SubStr(wnd, 1, InStr(wnd, ": ") - 1)
		WinShow, ahk_id %wndId%
		WinRestore, ahk_id %wndId%
		WinSet, AlwaysOnTop, On, ahk_id %wndId%
		WinSet, AlwaysOnTop, Off, ahk_id %wndId%
		WinMove, ahk_id %wndId%, , 0, 0, 800, 600
	} Else
		GuiControl, Focus, Gui_wnds
}

Main_search() {
	Global Gui_class, Gui_pName, Gui_title, Gui_wndId, Gui_wnds
	
	GuiControl, , Gui_wnds, |
	
	GuiControlGet, title, , Gui_title
	
	GuiControlGet, class, , Gui_class
	If class
		criteria .= " ahk_class " class
	
	GuiControlGet, pName, , Gui_pName
	If pName {
		Process, Exist, %pName%
		If ErrorLevel
			criteria .= " ahk_pid " ErrorLevel
	}
	
	If Not (criteria Or title)
		criteria := "A"
	
	wndListString := ""
	DetectHiddenWindows, On
	WinGet, wndId, List, % criteria
	Loop, % wndId {
		WinGetTitle, wndTitle, % "ahk_id " wndId%A_Index%
		If Not (wndId%A_Index% = Gui_wndId) And (Not title Or RegExmatch(wndTitle, title)) {
			WinGetClass, wndClass, % "ahk_id " wndId%A_Index%
			WinGet, wndPName, ProcessName, % "ahk_id " wndId%A_Index%
			WinGet, wndStyle, Style, % "ahk_id " wndId%A_Index%
			WinGetPos, wndPosX, wndPosY, wndPosW, wndPosH, % "ahk_id " wndId%A_Index%
			wndListString .= "|" wndId%A_Index% ": `t" wndTitle " (" wndClass ", " wndPName ", " wndStyle ", " wndPosX ", " wndPosY ", " wndPosW ", " wndPosH ")"
		}
	}
	DetectHiddenWindows, Off
	GuiControl, , Gui_wnds, % wndListString
}
