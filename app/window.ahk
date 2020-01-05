/*
:title:     bug.n/window
:copyright: (c) 2018-2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class Window extends Rectangle {
  __New(winId) {
    Global app, const, logger
    
    this.id := Format("0x{:x}", winId)
    
    ;; Attributes
    this.desktop := ""
    this.isFloating := True
    this.workArea := ""
    
    DetectHiddenWindows, On
    WinGetClass, winClass, % "ahk_id " . this.id
    logger.debug("Retrieving the window class name (possible infinite loop).", "Window.__New")
    While (winId != 0 && WinExist(winId) && winClass == "") {
      Sleep, 10
    }
    logger.debug("Window class name retrieved.", "Window.__New")
    DetectHiddenWindows, Off
    
    this.getProperties(True)    ;; `comprehensive := True`
    ;; more properties defined below: hasCaption, isCloaked, isPopup, minMax
    
    this.isAppWindow := (this.pId != app.processId && !this.isCloaked && this.w > 0 && this.h > 0)
    this.isChild     := (this.style & const.WS_CHILD)
    this.isElevated  := (!A_IsAdmin && !DllCall("OpenProcess", "UInt", 0x400, "Int", 0, "UInt", this.pId, "Ptr"))
    this.isGhost     := (this.pPath == "C:\Windows\System32\dwm.exe" && this.class == "Ghost")
    this.ownerId     := Format("0x{:x}", DllCall("GetWindow", "UInt", this.id, "UInt", const.GW_OWNER))
    this.parentId    := Format("0x{:x}", DllCall("GetParent", "UInt", this.id))
    ;; `isElevated` <- jeeswg: How would I mimic the windows Alt+Esc hotkey in AHK? (https://autohotkey.com/boards/viewtopic.php?p=134910&sid=192dd8fcd7839b6222826561491fcd57#p134910)
    
    logger.debug("New window with id <mark>" . this.id . "</mark> and class <mark>" . this.class . "</mark> (<mark>" . winClass . "</mark>) added.", "Window.__New")
  }
  
  getPosEx() {
    Global const
    Static dummy5693, rectPlus
    
    ptrType := (A_PtrSize = 8) ? "Ptr" : "UInt"       ;-- Workaround for AutoHotkey Basic
    
    ;-- Get the window's dimensions
    ;   Note: Only the first 16 bytes of the RECTPlus structure are used by the
    ;   DwmGetWindowAttribute and GetWindowRect functions.
    VarSetCapacity(rectPlus, 24,0)
    DWMRC := DllCall("dwmapi\DwmGetWindowAttribute"
        , ptrType, this.id                            ;-- hwnd
        , "UInt",  const.DWMWA_EXTENDED_FRAME_BOUNDS  ;-- dwAttribute
        , ptrType, &rectPlus                          ;-- pvAttribute
        , "UInt",  16)                                ;-- cbAttribute

    If (DWMRC <> const.S_OK) {
      If ErrorLevel in -3, -4                         ;-- Dll or function not found (older than Vista)
      {                                               ;-- Do nothing else (for now)
      } Else {
        outputdebug,
          (LTrim Join`s
           Function: %A_ThisFunc% -
           Unknown error calling "dwmapi\DwmGetWindowAttribute".
           RC = %DWMRC%,
           ErrorLevel = %ErrorLevel%,
           A_LastError = %A_LastError%.
           "GetWindowRect" used instead.
          )
      }

      ;-- Collect the position and size from "GetWindowRect"
      DllCall("GetWindowRect", ptrType, this.id, ptrType, &rectPlus)
    }

    ;-- Populate the output variables
    this.x := rectLeft := NumGet(rectPlus,  0, "Int")
    this.y := rectTop  := NumGet(rectPlus,  4, "Int")
    rectRight          := NumGet(rectPlus,  8, "Int")
    rectBottom         := NumGet(rectPlus, 12, "Int")
    this.w             := rectRight - rectLeft
    this.h             := rectBottom - rectTop
    this.offsetX       := 0
    this.offsetY       := 0

    ;-- If DWM is not used (older than Vista or DWM not enabled), we're done
    If (DWMRC <> const.S_OK) {
      Return, &rectPlus
    }

    ;-- Collect dimensions via GetWindowRect
    VarSetCapacity(rect, 16, 0)
    DllCall("GetWindowRect", ptrType, this.id, ptrType, &rect)
    gwrW := NumGet(rect,  8, "Int") - NumGet(rect, 0, "Int")    ;-- Right minus Left
    gwrH := NumGet(rect, 12, "Int") - NumGet(rect, 4, "Int")    ;-- Bottom minus Top

    ;-- Calculate offsets and update output variables
    NumPut(this.offsetX := (this.w - gwrW) // 2, rectPlus, 16, "Int")
    NumPut(this.offsetY := (this.h - gwrH) // 2, rectPlus, 20, "Int")
    
    Return, &rectPlus
  }
  ;; jballi: [Function] WinGetPosEx v0.1 (Preview) - Get the real position and size of a window (https://autohotkey.com/boards/viewtopic.php?t=3392)
  
  getProperties(comprehensive := False) {
    DetectHiddenWindows, On
    
    WinGetTitle, winTitle, % "ahk_id " . this.id
    WinGet, winStyle, Style, % "ahk_id " . this.id
    WinGet, winExStyle, ExStyle, % "ahk_id " . this.id
    this.isResponding := DllCall("SendMessageTimeout", "UInt", this.id, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", 0)
    ;; 150 = timeout in milliseconds  
    this.title   := winTitle
    this.style   := winStyle
    this.exStyle := winExStyle
    
    If (comprehensive) {
      WinGetClass, winClass, % "ahk_id " . this.id
      WinGet, winPId, PID, % "ahk_id " . this.id
      WinGet, winPName, ProcessName, % "ahk_id " . this.id
      WinGet, winPPath, ProcessPath, % "ahk_id " . this.id
      this.class := winClass
      this.pId   := winPId
      this.pName := winPName
      this.pPath := winPPath
    }
    
    this.getPosEx()
    
    DetectHiddenWindows, Off
  }
  
  hasCaption[] {
    get {
      Global const
      Return, (this.style & const.WS_CAPTION)
    }
  }
  
  information[] {
    get {
      Return, "Id:    `t" . this.id
        . "`nTitle:   `t" . SubStr(this.title, 1, 51) . (StrLen(this.title) > 51 ? "..." : "")
        . "`nClass:   `t" . this.class
        . "`nStyle:   `t" . this.style
        . "`nExStyle: `t" . this.exStyle
        . "`n"
        . "`nProcess Id:   `t" . this.pId
        . "`nProcess Name: `t" . this.pName
        . "`nProcess Path: `t" . SubStr(this.pPath, 1, 46) . (StrLen(this.pPath) > 46 ? "..." : "")
        . "`n"
        . "`nHas Caption:      `t" . (this.hasCaption ? "yes" : "no")
        . "`nIs App Window:    `t" . (this.isAppWindow ? "yes" : "no")
        . "`nIs Child:         `t" . (this.isChild ? "yes" : "no")
        . "`nIs Cloaked:       `t" . (this.isCloaked ? "yes" : "no")
        . "`nIs Elevated:      `t" . (this.isElevated ? "yes" : "no")
        . "`nIs Ghost:         `t" . (this.isGhost ? "yes" : "no")
        . "`nIs Popup:         `t" . (this.isPopup ? "yes" : "no")
        . "`nIs Min/Maximized: `t" . (this.minMax == -1 ? "min" : this.minMax == 1 ? "max" : "no")
        . "`n"
        . "`nIs Floating:      `t" . (this.isFloating ? "yes" : "no")
        . "`nWork Area Index:  `t" . (IsObject(this.workArea) ? this.workArea.index : 0)
    }
  }
  
  isCloaked[] {
    get {
      Global const
      
      result := False
      VarSetCapacity(var, A_PtrSize)
      If (!DllCall("DwmApi\DwmGetWindowAttribute", "Ptr", this.id, "UInt", const.DWMWA_CLOAKED, "Ptr", &var, "UInt", A_PtrSize)) {
        ;; returns const.S_OK (which is zero) on success, otherwise, it returns an HRESULT error code
        result := NumGet(var)    ;; omitting the "&" performs better
        ;; DWMWA_CLOAKED: If the window is cloaked, the following values explain why:
        ;; 1  The window was cloaked by its owner application (DWM_CLOAKED_APP)
        ;; 2  The window was cloaked by the Shell (DWM_CLOAKED_SHELL)
        ;; 4  The cloak value was inherited from its owner window (DWM_CLOAKED_INHERITED)
      }
      
      Return, result
    }
  }
  ;; ophthalmos: Get last active window resp. all windows in the Alt+Tab list (https://autohotkey.com/boards/viewtopic.php?p=68194&sid=427a7811da17f81ad31bac20af9835d6#p68194)
  
  isPopup[] {
    get {
      Global const
      Return, (this.style & const.WS_POPUP)
    }
  }
  
  isUnresponsive(funcName := "") {
    Global const, logger
    
    DetectHiddenWindows, On
    SendMessage, const.WM_NULL,,,, % "ahk_id " . this.id
    DetectHiddenWindows, Off
    If (ErrorLevel == "FAIL" && funcName != "") {
      logger.warning("Window with id <mark>" . this.id . "</mark> seems unresponsive.", funcName)
    }

    Return, (ErrorLevel == "FAIL")
  }
  
  minMax[] {
    get {
      DetectHiddenWindows, On
      WinGet, winMinMax, MinMax, % "ahk_id " . this.id
      DetectHiddenWindows, Off
      Return, winMinMax
    }
  }
  
  move(x, y, w, h) {
    Global const, logger
    logger.debug("Moving window with id <mark>" . this.id . "</mark>, x: " . this.x . " -> " . x . ", y: " . this.y . " -> " . y . ", width: " . this.w . " -> " . w . ", height: " . this.h . " -> " . h . ".", "Window.move")
    If (this.isUnresponsive("Window.move")) {
      Return, 1
    } Else If (this.getPosEx() && this.match(new Rectangle(x, y, w, h), True)) {
      Return, 0
    }
    
    SendMessage, const.WM_ENTERSIZEMOVE,,,, % "ahk_id " . this.id
    WinMove, % "ahk_id " . this.id,, %x%, %y%, %w%, %h%
    ; If (this.minMax != 1) {
      If (this.getPosEx() && !this.match(new Rectangle(x, y, w, h), True)) {
        x -= this.x - x
        y -= this.y - y
        w += w - this.w - 1
        h += h - this.h - 1
        WinMove, % "ahk_id " . this.id,, %x%, %y%, %w%, %h%
      }
    ; }
    SendMessage, const.WM_EXITSIZEMOVE,,,, % "ahk_id " . this.id
    
    Return, 0
  }
  
  runCommand(str) {
    Global const, logger
    
    logger.debug("Running command <b>" . str . "</b> on window with id <mark>" . this.id . "</mark>.", "Window.runCommand")
    If (this.isUnresponsive("Window." . str)) {
      Return, 1
    } Else If (str == "activate") {
      WinActivate, % "ahk_id " this.id
    } Else If (str == "bottom") {
      WinSet, Bottom,, % "ahk_id " this.id
    } Else If (str == "close") {
      WinClose, % "ahk_id " this.id
    } Else If (str == "hide") {
      WinHide, % "ahk_id " this.id
    } Else If (str == "maximize") {
      WinMaximize, % "ahk_id " this.id
    } Else If (str == "minimize") {
      WinMinimize, % "ahk_id " this.id
    } Else If (str == "restore") {
      WinRestore, % "ahk_id " this.id
    } Else If (str == "setAlwaysOnTop") {
      WinSet, AlwaysOnTop, On, % "ahk_id " this.id
    } Else If (str == "setCaption") {
      WinSet, Style, % "+" . const.WS_CAPTION, % "ahk_id " this.id
    } Else If (str == "show") {
      WinShow, % "ahk_id " this.id
    } Else If (str == "toggleAlwaysOnTop") {
      WinSet, AlwaysOnTop, Toggle, % "ahk_id " this.id
    } Else If (str == "toggleCaption") {
      WinSet, Style, % (this.hasCaption ? "-" : "+") . const.WS_CAPTION, % "ahk_id " this.id
    } Else If (str == "top") {
      WinSet, Top,, % "ahk_id " this.id
    } Else If (str == "unsetCaption") {
      WinSet, Style, % "-" . const.WS_CAPTION, % "ahk_id " this.id
    }
    
    Return, 0
  }
}
