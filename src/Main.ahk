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
  
  ResourceMonitor_init()
  Manager_init()
Return          ;; end of the auto-execute section

;; Function & label definitions
Main_cleanup:
  Debug_logMessage("Cleaning up", 0)
  If Config_autoSaveSession
    Config_saveSession()
  Manager_cleanup()
  ResourceMonitor_cleanup()
  Debug_logMessage("Exiting bug.n", 0)
ExitApp
  
Main_evalCommand(command) 
{
  type := SubStr(command, 1, 5)
  If (type = "Run, ") 
  {
    parameters := SubStr(command, 6)
    If InStr(parameters, ", ") 
    {
      StringSplit, parameter, parameters, `,
      If (parameter0 = 2) 
      {
        StringTrimLeft, parameter2, parameter2, 1
        Run, %parameter1%, %parameter2%
      } 
      Else If (parameter0 > 2) 
      {
        StringTrimLeft, parameter2, parameter2, 1
        StringTrimLeft, parameter3, parameter3, 1
        Run, %parameter1%, %parameter2%, %parameter3%
      }
    } 
    Else
      Run, %parameters%
  } 
  Else If (type = "Send ")
    Send % SubStr(command, 6)
  Else If (command = "Reload")
    Reload
  Else If (command = "ExitApp")
    ExitApp
  Else 
  {
    i := InStr(command, "(")
    j := InStr(command, ")", False, i)
    If i And j 
    {
      functionName := SubStr(command, 1, i - 1)
      functionArguments := SubStr(command, i + 1, j - (i + 1))
      StringSplit, functionArgument, functionArguments, `,
      If (functionArgument0 < 2)
        %functionName%(functionArguments)
      Else If (functionArgument0 = 2) 
      {
        StringTrimLeft, functionArgument2, functionArgument2, 1
        %functionName%(functionArgument1, functionArgument2)
      }
    }
  }
}

Main_help:
  Run, explore %A_ScriptDir%\docs
Return

Main_quit:
  ExitApp
Return

Main_reload() 
{
  Local i, m
  
  Manager_resetWindowBorder()
  
  DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_REMOVE := 0x1), "UInt", &Bar_appBarData)
  ;; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)
  
  Config_init()
  Manager_setWindowBorder()
  Bar_getHeight()
  SysGet, m, MonitorCount
  If Not (m = Manager_monitorCount)
  {
    MsgBox, 48, bug.n: Reload, The number of monitors changed. You should restart bug.n (by default with the hotkey Win+Ctrl+Shift+R).
    If (m < Manager_monitorCount)
    {
      Manager_monitorCount := m
      Manager_aMonitor := 1
    }
  }
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
#Include ResourceMonitor.ahk
#Include View.ahk
