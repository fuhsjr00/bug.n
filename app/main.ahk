/*
:title:     bug.n/main
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

;; script settings
#NoEnv                        ;; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                         ;; Enable warnings to assist with detecting common errors.
SendMode Input                ;; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%   ;; Ensures a consistent starting directory.
#Persistent
#SingleInstance Force
#WinActivateForce
DetectHiddenText, Off
DetectHiddenWindows, Off
OnExit("exitApp")
SetBatchLines,    -1
SetControlDelay,   0
SetMouseDelay,     0
SetTitleMatchMode, 3          ;; `TitleMatchMode` may be set to `RegEx` to enable a wider search, but should be reset afterwards.
SetWinDelay,       0          ;; `WinDelay` may be set to a different value e.g. 10, if necessary to prevent timing issues, but should be reset afterwards.

;; pseudo main function
  logger := New Logging()     ;; Primarily the cache will be written to a web interface
                              ;; allowing text formatting with HTML tags: bold = <b>text</b>
                              ;; , highlight = <mark>text</mark>, italic = <i>text</i>
                              ;; , strikethrough = <s>text</s>, underline = <u>text</u>
  const := New Constants()
  app := New Application("bug.n", "10.0.0")
  cfg := New Configuration()
  custom := New Customizations()
  
  sys := New SystemStatus(cfg.networkInterfaces)
  mgr := New GeneralManager()
  custom._init()
  
  logger.log(app.name . " started.")
Return
;; end of the auto-execute section

;; function, label & object definitions
class Application {
  __New(name, version) {
    Global logger
    
    this.name := name
    this.version := version
    this.logo := A_ScriptDir . "\assets\logo.ico"
    Menu, Tray, NoIcon
    this.uifaces := []
    
    this.processId := DllCall("GetCurrentProcessId", "UInt")
    DetectHiddenWindows, On
    this.windowId  := Format("0x{:x}", WinExist("ahk_pid " . this.processId))
    DetectHiddenWindows, Off
    logger.info("Window with id <mark>" . this.windowId . "</mark> identified as the one of " . this.name . "'s process.", "Application.__New")
  }
}

exitApp() {
  Global app, cfg, logger, mgr
  
  ;; Reset the main objects triggering their __Delete function.
  cfg := ""
  mgr := ""
  
  logger.warning("Exiting " . app.name . ".", "exitApp")
}

#Include, %A_ScriptDir%\constants.ahk
#Include, %A_ScriptDir%\desktop-manager.ahk
#Include, %A_ScriptDir%\general-manager.ahk
#Include, %A_ScriptDir%\logging.ahk
#Include, %A_ScriptDir%\monitor-manager.ahk
#Include, %A_ScriptDir%\system-status.ahk
#Include, %A_ScriptDir%\window.ahk
#Include, %A_ScriptDir%\work-area.ahk
#Include, %A_ScriptDir%\modules\user-interfaces\work-area-user-interface.ahk
#Include, %A_ScriptDir%\..\etc\custom.ahk
