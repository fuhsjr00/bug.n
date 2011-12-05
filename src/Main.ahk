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
 *	@version 8.2.1.02 (24.09.2011)
 */

NAME	:= "bug.n"
VERSION := "8.2.1"

; script settings
OnExit, Main_cleanup
SetBatchLines, -1
SetTitleMatchMode, 3
SetTitleMatchMode, fast
SetWinDelay, 10
#NoEnv
#SingleInstance force
#WinActivateForce

; pseudo main function
	If 0 = 1
		Config_filePath = %1%
	Config_init()
	
	Menu, Tray, Tip, %NAME% %VERSION%
	IfExist %A_ScriptDir%\images\kfm.ico
		Menu, Tray, Icon, %A_ScriptDir%\images\kfm.ico
	Menu, Tray, NoStandard
	Menu, Tray, Add, Toggle bar, Main_toggleBar
	Menu, Tray, Add, Help, Main_help
	Menu, Tray, Add, 
	Menu, Tray, Add, Exit, Main_quit
	
	Manager_init()
Return					; end of the auto-execute section

/**
 *	function & label definitions
 */
Main_cleanup:			; The labels with "ExitApp" or "Return" at the end and hotkeys have to be after the auto-execute section.
	If Config_autoSaveSession
		Config_saveSession()
	Manager_cleanup()
ExitApp

Main_help:
	Run, explore %A_ScriptDir%\docs
Return

Main_quit:
	ExitApp
Return

Main_reload() {
	Local i, ncm, ncmSize
	
	; Reset border color, padding and witdh.
	If Config_selBorderColor
		DllCall("SetSysColors", "Int", 1, "Int*", 10, "UInt*", Manager_normBorderColor)
	If (Config_borderWidth > 0) Or (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA) {
		ncmSize := VarSetCapacity(ncm, 4 * (A_OSVersion = WIN_VISTA ? 11 : 10) + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), 0)
		NumPut(ncmSize, ncm, 0, "UInt")
		DllCall("SystemParametersInfo", "UInt", 0x0029, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
		If (Config_borderWidth > 0)
			NumPut(Manager_borderWidth, ncm, 4, "Int")
		If (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
			NumPut(Manager_borderPadding, ncm, 40 + 5 * (28 + 32 * (A_IsUnicode ? 2 : 1)), "Int")
		DllCall("SystemParametersInfo", "UInt", 0x002a, "UInt", ncmSize, "UInt", &ncm, "UInt", 0)
	}
	DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_REMOVE := 0x1), "UInt", &Bar_appBarData)
	; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)

	Config_init()	
	; Windows UI
	If Config_selBorderColor {
		SetFormat, Integer, hex
		Manager_normBorderColor := DllCall("GetSysColor", "Int", 10)
		SetFormat, Integer, d
		DllCall("SetSysColors", "Int", 1, "Int*", 10, "UInt*", Config_selBorderColor)
	}
	If (Config_borderWidth > 0) Or (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA) {
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
	Bar_getHeight()
	Loop, % Manager_monitorCount {
		Monitor_getWorkArea(A_Index)
		Bar_init(A_Index)
	}
	Bar_initCmdGui()
	If Not (Manager_showTaskBar = Config_showTaskBar)
		Monitor_toggleTaskBar()
	Bar_updateStatus()
	Bar_updateTitle()
	Loop, % Manager_monitorCount {
		i := A_Index
		Loop, % Config_viewCount
			Bar_updateView(i, A_Index)
		View_arrange(i, Monitor_#%i%_aView_#1)
	}
	Manager_registerShellHook()
	SetTimer, Bar_loop, %Config_readinInterval%
}

Main_toggleBar:
	Monitor_toggleBar()
Return

#Include Bar.ahk
#Include Config.ahk
#Include Manager.ahk
#Include Monitor.ahk
#Include View.ahk
