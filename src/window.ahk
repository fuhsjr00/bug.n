/*
:title:     bug.n/window
:copyright: (c) 2018-2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Window extends Rectangle {
  __New(winId) {
    Global logger, sys
    
    this.id := Format("0x{:x}", winId)
    this.view := 0
    this.wFactor := 1.0
    this.hFactor := 1.0
    
    DetectHiddenWindows, On
    WinGetClass, winClass, % "ahk_id " . this.id
    While (winId != 0 && WinExist(winId) && winClass == "") {
      Sleep, 10
    }
    WinGetClass, winClass, % "ahk_id " . this.id
    WinGetTitle, winTitle, % "ahk_id " . this.id
    WinGet, winPID, PID, % "ahk_id " . this.id
    WinGet, winPName, ProcessName, % "ahk_id " . this.id
    WinGet, winPPath, ProcessPath, % "ahk_id " . this.id
    WinGet, winStyle, Style, % "ahk_id " . this.id
    WinGet, winExStyle, ExStyle, % "ahk_id " . this.id
    WinGet, winMinMax, MinMax, % "ahk_id " . this.id
    DetectHiddenWindows, Off
    
    this.class := winClass
    this.title := winTitle
    this.pName := winPName
    this.pPath := winPPath
    this.style := winStyle
    this.exStyle := winExStyle
    this.minMax  := winMinMax
    this.getPosEx()
    
    WinGetClass, winClass, % "ahk_id " . this.id
    this.isHidden    := (this.class != "" && this.class != winClass)
    this.hasCaption  := (this.style & sys.WS_CAPTION)
    isBugNDisplay    := (this.class == "AutoHotkeyGUI" && RegExMatch(this.title, "bug.n Display \d+") && !this.hasCaption && this.exStyle & sys.WS_EX_TOOLWINDOW)
    this.isAppWindow := (!isBugNDisplay && !this.isCloaked && this.w > 0 && this.h > 0)
    ;; this.isHidden is not significant for a window being an app window; notepad for example first creates a hidden window, which later becomes fully visible.
    this.isChild     := (this.style & sys.WS_CHILD)
    this.isElevated  := (!A_IsAdmin && !DllCall("OpenProcess", UInt, 0x400, Int, 0, UInt, winPID, Ptr))
    ;; jeeswg: How would I mimic the windows Alt+Esc hotkey in AHK? (https://autohotkey.com/boards/viewtopic.php?p=134910&sid=192dd8fcd7839b6222826561491fcd57#p134910)
  	this.isPopup := (this.style & sys.WS_POPUP)
    this.isGhost := (this.pPath == "C:\Windows\System32\dwm.exe" && this.class == "Ghost")
    this.isResponding := DllCall("SendMessageTimeout", "UInt", this.id, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", 0)
    ;; 150 = timeout in milliseconds
    
    this.ownerId  := Format("0x{:x}", DllCall("GetWindow", "UInt", this.id, "UInt", sys.GW_OWNER))
    this.parentId := Format("0x{:x}", DllCall("GetParent", "UInt", this.id))
    
    logger.debug("New window with id <mark>" . this.id . "</mark> and class '<mark>" . this.class . "</mark>' (<mark>" . winClass . "</mark>) added.", "Window.__New")
  }
  
  getPosEx() {
    Global sys
    Static dummy5693, rectPlus
    
    S_OK := 0x0
    ptrType := (A_PtrSize = 8) ? "Ptr" : "UInt"         ;-- Workaround for AutoHotkey Basic
    
    ;-- Get the window's dimensions
    ;   Note: Only the first 16 bytes of the RECTPlus structure are used by the
    ;   DwmGetWindowAttribute and GetWindowRect functions.
    VarSetCapacity(rectPlus, 24,0)
    DWMRC := DllCall("dwmapi\DwmGetWindowAttribute"
        , ptrType, this.id                            ;-- hwnd
        , "UInt",  sys.DWMWA_EXTENDED_FRAME_BOUNDS    ;-- dwAttribute
        , ptrType, &rectPlus                          ;-- pvAttribute
        , "UInt",  16)                                ;-- cbAttribute

    If (DWMRC <> S_OK) {
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
    If (DWMRC <> S_OK) {
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
  
  isCloaked[] {
    get {
      Global sys
      
      result := False
      VarSetCapacity(var, A_PtrSize)
      If !DllCall("DwmApi\DwmGetWindowAttribute", "Ptr", this.id, "UInt", sys.DWMWA_CLOAKED, "Ptr", &var, "UInt", A_PtrSize)
        ;; returns S_OK (which is zero) on success, otherwise, it returns an HRESULT error code
        result := NumGet(var)    ;; omitting the "&" performs better
      /* DWMWA_CLOAKED: If the window is cloaked, the following values explain why:
        1  The window was cloaked by its owner application (DWM_CLOAKED_APP)
        2  The window was cloaked by the Shell (DWM_CLOAKED_SHELL)
        4  The cloak value was inherited from its owner window (DWM_CLOAKED_INHERITED)
      */
      Return, result
    }
  }
  ;; ophthalmos: Get last active window resp. all windows in the Alt+Tab list (https://autohotkey.com/boards/viewtopic.php?p=68194&sid=427a7811da17f81ad31bac20af9835d6#p68194)

  isUnresponsive(funcName := "") {
    Global logger, sys
    
    DetectHiddenWindows, On
    SendMessage, sys.WM_NULL,,,, % "ahk_id " . this.id
    err := ErrorLevel
    DetectHiddenWindows, Off
    If (err && funcName) {
      logger.warning("Window with id " . this.id . " seems unresponsive.", funcName)
    }

    Return, err
  }
  
  move(x, y, w, h) {
    Global logger, sys
    
    logger.debug("Moving window with id " . this.id . ", x: " . this.x . " -> " . x . ", y: " . this.y . " -> " . y . ", width: " . this.w . " -> " . w . ", height: " . this.h . " -> " . h . ".", "Window.move")
    If this.isUnresponsive("Window.move") {
      Return, 1
    } Else If (this.getPosEx() && this.match(new Rectangle(x, y, w, h))) {
      Return, 0
    }
    
    SendMessage, sys.WM_ENTERSIZEMOVE,,,, % "ahk_id " . this.id
    WinMove, % "ahk_id " . this.id,, %x%, %y%, %w%, %h%
    WinGet, winMinMax, MinMax, % "ahk_id " . this.id
    this.minMax := winMinMax
    If (this.minMax != 1) {
      If (this.getPosEx() && !this.match(new Rectangle(x, y, w, h))) {
        x -= this.x - x
        y -= this.y - y
        w += w - this.w - 1
        h += h - this.h - 1
        WinMove, % "ahk_id " . this.id,, %x%, %y%, %w%, %h%
      }
    }
    SendMessage, sys.WM_EXITSIZEMOVE,,,, % "ahk_id " . this.id
    
    Return, 0
  }
  
  runCommand(str) {
    Global logger, sys
    
    logger.debug("Running command " . str . " on window with id " . this.id . ".", "Window.runCommand")
    If this.isUnresponsive("Window." . str) {
      Return, 1
    } Else If (str = "activate") {
      WinActivate, % "ahk_id " this.id
    } Else If (str = "bottom") {
      WinSet, Bottom,, % "ahk_id " this.id
    } Else If (str = "close") {
      WinClose, % "ahk_id " this.id
    } Else If (str = "hide") {
      WinHide, % "ahk_id " this.id
    } Else If (str = "maximize") {
      If (!this.caption) {
        WinSet, Style, % "+" . sys.WS_CAPTION, % "ahk_id " this.id
      }
      If (this.minMax = 1) {
        WinRestore, % "ahk_id " this.id
      }
      WinMaximize, % "ahk_id " this.id
      If (!this.caption) {
        WinSet, Style, % "-" . sys.WS_CAPTION, % "ahk_id " this.id
      }
      this.minMax := 1
    } Else If (str = "minimize") {
      WinMinimize, % "ahk_id " this.id
      this.minMax := -1
    } Else If (str = "restore") {
      WinRestore, % "ahk_id " this.id
      this.minMax := 0
    } Else If (str = "setAlwaysOnTop") {
      WinSet, AlwaysOnTop, On, % "ahk_id " this.id
    } Else If (str = "setCaption") {
      WinSet, Style, % "+" . sys.WS_CAPTION, % "ahk_id " this.id
      this.caption := True
    } Else If (str = "show") {
      WinShow, % "ahk_id " this.id
    } Else If (str = "toggleAlwaysOnTop") {
      WinSet, AlwaysOnTop, Toggle, % "ahk_id " this.id
    } Else If (str = "top") {
      WinSet, Top,, % "ahk_id " this.id
    } Else If (str = "unsetCaption") {
      WinSet, Style, % "-" . sys.WS_CAPTION, % "ahk_id " this.id
      this.caption := False
    }
    Return, 0
  }
  
  setProperty(query) {
    Global sys
    
    parts := StrSplit(query, "=")
    If (this.isUnresponsive("Window.setProperty(" . query . ")")) {
      Return, 1
    } Else If (query == "active=True") {
      WinActivate, % "ahk_id " this.id
    } Else If (parts[1] == "alwaysOnTop") {
      WinSet, AlwaysOnTop, % parts[2], % "ahk_id " this.id
    } Else If (parts[1] == "caption") {
      WinSet, Style, % (parts[2] == "Off" ? "-" : "+") . sys.WS_CAPTION, % "ahk_id " this.id
    } Else If (query == "closed=True") {
      WinClose, % "ahk_id " this.id
    } Else If (parts[1] == "hidden") {
      If (parts[2] == True) {
        WinHide, % "ahk_id " this.id
      } Else {
        WinShow, % "ahk_id " this.id
      }
    } Else If (parts[1] == "minMax") {
      If (parts[2] == -1) {
        WinMinimize, % "ahk_id " this.id
      } Else If (parts[2] == 1) {
        WinMaximize, % "ahk_id " this.id
      } Else {
        WinRestore, % "ahk_id " this.id
      }
    } Else If (parts[1] == "stackPosition") {
      WinSet, % parts[2],, % "ahk_id " this.id
    } Else If (parts[1] == "view") {
      this.view := parts[2]
    }
    this.update()
  }
  
  testProperty(query) {
    Global logger
    
    parts := StrSplit(query, "=")
    logger.debug("Testing query <mark>" . query . "</mark> against window with id <mark>" . this.id . "</mark> and property value <mark>" . this[parts[1]] . "</mark>.", "Window.testProperty")
    If (RegExMatch(parts[1], "(class|title|pName|pPath)")) {
      Return, RegExMatch(this[parts[1]], parts[2])
    } Else If (RegExMatch(parts[1], "(style|exStyle)")) {
      Return, (this[parts[1]] & parts[2])
    } Else If (RegExMatch(parts[1], "(isAppWindow|isChild|isElevated|isPopup)")) {
      Return, (this[parts[1]] && parts[2] == "True" || !this[parts[1]] && parts[2] == "False")
    } Else {
      Return, (this[parts[1]] == parts[2])
    }
  }
  
  update() {
    Global sys
    
    DetectHiddenWindows, On
    WinGetTitle, winTitle, % "ahk_id " . this.id
    WinGet, winStyle, Style, % "ahk_id " . this.id
    WinGet, winExStyle, ExStyle, % "ahk_id " . this.id
    WinGet, winMinMax, MinMax, % "ahk_id " . this.id
    DetectHiddenWindows, Off
    
    this.title := winTitle
    this.style := winStyle
    this.exStyle := winExStyle
    this.getPosEx()
    this.minMax := winMinMax
    
    this.hasCaption := (this.style & sys.WS_CAPTION)
    this.isResponding := DllCall("SendMessageTimeout", "UInt", this.id, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", 0)
  }
}
