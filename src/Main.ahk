/*
:title:     bug.n -- Tiling Window Management
:copyright: (c) 2016 by Joshua Fuhs & joten <https://github.com/fuhsjr00/bug.n>
:license:   GNU General Public License version 3;
              LICENSE.md or at <http://www.gnu.org/licenses/>

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

VERSION := "10.0.0"

;; script settings
#NoEnv
OnExit, Main_cleanup
SendMode Input
SetBatchLines, -1
SetTitleMatchMode, 3
SetTitleMatchMode, fast
SetWinDelay, 10
SetWorkingDir %A_ScriptDir%   ; Ensures a consistent starting directory.
#SingleInstance force
#Warn                         ; Enable warnings to assist with detecting common errors.
#WinActivateForce

;; Pseudo main function
  Main_appDir := ""
  Log_level   := ""
  If 0 = 1
    Main_appDir = %1%

  Main_setup()

  Debug_initLog(Main_logFile, 0, False)
  Log_init()

  Debug_logMessage("====== Initializing ======", 0)
  Config_filePath := Main_appDir "\Config.ini"
  Config_init()

  Menu, Tray, Tip, bug.n %VERSION%
  IfExist %A_ScriptDir%\logo.ico
    Menu, Tray, Icon, %A_ScriptDir%\logo.ico
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

Main_help:
  Run, explore %Main_docDir%
Return

Main_makeDir(name) {
  q := FileExist(name)
  If Not q {
    FileCreateDir, %name%
    If ErrorLevel {
      MsgBox, Error (%ErrorLevel%) creating '%name%'. Aborting.
      ExitApp
    }
  } Else If Not InStr(q, "D") {
    MsgBox, The filepath '%name%' already exists and is not a directory. Aborting.
    ExitApp
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

  EnvGet, winAppDir, APPDATA
  If (Main_appDir = "")
    Main_appDir := winAppDir . "\bug.n"
  
  Main_logFile := Main_appDir . "\log.txt"
  Log_file := Main_appDir . "\log.md"
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
#Include Lib.ahk
#Include Log.ahk
#Include Manager.ahk
#Include Monitor.ahk
#Include ResourceMonitor.ahk
#Include Tiler.ahk
#Include View.ahk
#Include Window.ahk
