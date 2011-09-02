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
 *	@version 8.2.0.03 (21.08.2011)
 */

NAME	:= "bug.n"
VERSION := "8.2.0"

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

Main_toggleBar:
	Monitor_toggleBar()
Return

#Include Bar.ahk
#Include Config.ahk
#Include Manager.ahk
#Include Monitor.ahk
#Include View.ahk
