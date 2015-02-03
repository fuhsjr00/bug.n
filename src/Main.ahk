/*
  bug.n -- tiling window management
  Copyright (c) 2010-2015 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.0
*/

NAME  := "bug.n"
VERSION := "9.0.0"

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
    Main_appDir = %1%

  Main_setup()

  Debug_initLog(Main_logFile, 0, False)

  Debug_logMessage("====== Initializing ======", 0)
  Config_filePath := Main_appDir "\Config.ini"
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
  Server_init()

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
      If (functionArgument0 < 2)
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

Main_reload()
{
  Local i, ncm, ncmSize

  ;; Restore border color, padding and witdh.
  If Config_selBorderColor
    DllCall("SetSysColors", "Int", 1, "Int*", 10, "UInt*", Manager_normBorderColor)
  If (Config_borderWidth > 0) Or (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
  {
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
  ;; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)

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
  Loop, % Manager_monitorCount
  {
    Monitor_getWorkArea(A_Index)
    Bar_init(A_Index)
    If Monitor_%A_Index%_taskBarClass And Not (Monitor_%A_Index%_showTaskBar = Config_showTaskBar)
      Monitor_toggleTaskBar()
  }
  Bar_initCmdGui()
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
#Include Server.ahk
#Include Tiler.ahk
#Include View.ahk
#Include Window.ahk
