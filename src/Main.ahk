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

NAME  := "bug.n"
VERSION := "9.0.2-a"

;; Script settings
OnExit, Main_cleanup
SetBatchLines, -1
SetTitleMatchMode, 3
SetTitleMatchMode, fast
SetWinDelay, 10
#NoEnv
#SingleInstance force
;#Warn                         ; Enable warnings to assist with detecting common errors.
#WinActivateForce

;; Pseudo main function
  Main_appDir := ""
  If 0 = 1
    Main_appDir = %1%

  Main_setup()

  Debug_initLog(Main_logFile, 0, False)

  Debug_logMessage("====== Initializing ======", 0)
  Config_filePath := Main_appDir "\Config.ini"
  Config_init()

  Menu, Tray, Tip, %NAME% %VERSION%
  If A_IsCompiled
    Menu, Tray, Icon, %A_ScriptFullPath%, -159
  If FileExist(A_ScriptDir . "\logo.ico")
    Menu, Tray, Icon, % A_ScriptDir . "\logo.ico"
  Menu, Tray, NoStandard
  Menu, Tray, Add, Toggle bar, Main_toggleBar
  Menu, Tray, Add, Help, Main_help
  Menu, Tray, Add,
  Menu, Tray, Add, Exit, Main_quit

  ResourceMonitor_init()
  Manager_init()
  Debug_logMessage("====== Running ======", 0)
Return          ;; end of the auto-execute section

;; Function & label definitions
Main_cleanup:
  Debug_logMessage("====== Cleaning up ======", 0)
  ;; Config_autoSaveSession as False is deprecated.
  If Not (Config_autoSaveSession = "off") And Not (Config_autoSaveSession = "False")
    Manager_saveState()
  Manager_cleanup()
  ResourceMonitor_cleanup()
  Debug_logMessage("====== Exiting bug.n ======", 0)
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
      StringReplace, functionArguments, functionArguments, %A_SPACE%, , All
      StringSplit, functionArgument, functionArguments, `,
      Debug_logMessage("DEBUG[1] Main_evalCommand: " functionName "(" functionArguments ")", 1)
      If (functionArgument0 = 0)
        %functionName%()
      Else If (functionArgument0 = 1)
        %functionName%(functionArguments)
      Else If (functionArgument0 = 2)
        %functionName%(functionArgument1, functionArgument2)
      Else If (functionArgument0 = 3)
        %functionName%(functionArgument1, functionArgument2, functionArgument3)
      Else If (functionArgument0 = 4)
        %functionName%(functionArgument1, functionArgument2, functionArgument3, functionArgument4)
    }
  }
}

Main_help:
  Run, explore %Main_docDir%
Return

;; Create bug.n-specific directories.
Main_makeDir(dirName) {
  IfNotExist, %dirName%
  {
    FileCreateDir, %dirName%
    If ErrorLevel
    {
      MsgBox, Error (%ErrorLevel%) when creating '%dirName%'. Aborting.
      ExitApp
    }
  }
  Else
  {
    FileGetAttrib, attrib, %dirName%
    IfNotInString, attrib, D
    {
      MsgBox, The file path '%dirName%' already exists and is not a directory. Aborting.
      ExitApp
    }
  }
}

Main_quit:
  ExitApp
Return

Main_setup() {
  Local winAppDir

  Main_docDir := A_ScriptDir
  If (SubStr(A_ScriptDir, -3) = "\src")
    Main_docDir .= "\.."
  Main_docDir .= "\doc"

  Main_logFile := ""
  Main_dataDir := ""
  Main_autoLayout := ""
  Main_autoWindowState := ""

  EnvGet, winAppDir, APPDATA

  If (Main_appDir = "")
    Main_appDir := winAppDir . "\bug.n"
  Main_logFile := Main_appDir . "\log.txt"
  Main_dataDir := Main_appDir . "\data"
  Main_autoLayout := Main_dataDir . "\_Layout.ini"
  Main_autoWindowState := Main_dataDir . "\_WindowState.ini"

  Main_makeDir(Main_appDir)
  Main_makeDir(Main_dataDir)
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
#Include Tiler.ahk
#Include View.ahk
#Include Window.ahk
