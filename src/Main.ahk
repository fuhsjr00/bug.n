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
  
  @version 8.3.0
*/

NAME  := "bug.n"
VERSION := "8.3.0"

;; Script settings
OnExit, Main_cleanup
SetBatchLines, -1
SetTitleMatchMode, 3
SetTitleMatchMode, fast
SetWinDelay, 10
#NoEnv
#SingleInstance force
#WinActivateForce

;; Pseudo main function
  If 0 = 1
    Main_dataDir = %1%
  Else
    Main_dataDir = %A_ScriptDir%
  Debug_initLog(Main_dataDir "\log.txt", 0, False)
  Config_filePath := Main_dataDir "\config.ini"
  Config_init()
  
  Menu, Tray, Tip, %NAME% %VERSION%
  IfExist %A_ScriptDir%\logo.ico
    Menu, Tray, Icon, %A_ScriptDir%\logo.ico
  Menu, Tray, NoStandard
  Menu, Tray, Add, Toggle bar, Main_toggleBar
  Menu, Tray, Add, Help, Main_help
  Menu, Tray, Add, 
  Menu, Tray, Add, Exit, Main_quit
  
  Manager_init()
Return          ;; end of the auto-execute section

;; Function & label definitions
Main_cleanup:
  Debug_logMessage("Cleaning up", 0)
  If Config_autoSaveSession
    Config_saveSession()
  Manager_cleanup()
  DllCall("CloseHandle", "UInt", Bar_hDrive)    ;; used in Bar_getDiskLoad
  Debug_logMessage("Exiting bug.n", 0)
ExitApp

Main_help:
  Run, explore %A_ScriptDir%\docs
Return

Main_quit:
  ExitApp
Return

Main_reload() 
{
  Local i
  
  Manager_resetWindowBorder()
  
  DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_REMOVE := 0x1), "UInt", &Bar_appBarData)
  ;; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)

  Config_init()
  Manager_setWindowBorder()
  Bar_getHeight()
  Loop, % Manager_monitorCount 
  {
    Monitor_getWorkArea(A_Index)
    Bar_init(A_Index)
  }
  Bar_initCmdGui()
  If Not (Manager_showTaskBar = Config_showTaskBar)
    Monitor_toggleTaskBar()
  Bar_updateStatus()
  Bar_updateTitle()
  Loop, % Manager_monitorCount 
  {
    i := A_Index
    Loop, % Config_viewCount 
    {
      Bar_updateView(i, A_Index)
    }
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
#Include Debug.ahk
#Include Manager.ahk
#Include Monitor.ahk
#Include View.ahk
