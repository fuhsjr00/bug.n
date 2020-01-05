/*
:title:     bug.n/desktop-manager
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class DesktopManager {
  __New(funcObject_1, funcObject_2) {
    ;; `funcObject_1` is the function object for "_onTaskbarCreated", `funcObject_2` for "_onDesktopChange".
    Global app, logger
    
    ;; Ciantic: VirtualDesktopAccessor (https://github.com/Ciantic/VirtualDesktopAccessor)
    hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\lib\virtual-desktop-accessor.dll", "Ptr")
    this.registerPostMessageHookProc        := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
    this.restartVirtualDesktopAccessorProc  := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RestartVirtualDesktopAccessor", "Ptr")
    this.unregisterPostMessageHookProc      := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")
    
    this.getDesktopCountProc                := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
    this.getCurrentDesktopNumberProc        := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
    this.getWindowDesktopNumberProc         := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetWindowDesktopNumber", "Ptr")
    this.goToDesktopNumberProc              := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
    this.moveWindowToDesktopNumberProc      := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
    
    this.isPinnedWindowProc                 := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
    this.pinWindowProc                      := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinWindow", "Ptr")
    this.unPinWindowProc                    := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinWindow", "Ptr")
    
    ;; Restart the virtual desktop accessor, when Explorer.exe crashes or restarts (e.g. when coming from a fullscreen game).
    OnMessage(DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated"), funcObject_1)
    logger.info("Window message <b>TaskbarCreated</b> registered.", "DesktopManager.__New")
    
    DllCall(this.registerPostMessageHookProc, "Int", app.windowId, "Int", 0x1400 + 30)
    OnMessage(0x1400 + 30, funcObject_2)
    logger.info("Post message hook registered to window with id <mark>" . app.windowId . "</mark>: desktop switched.", "DesktopManager.__New")
  }
  
  __Delete() {
    Global app, logger
    DllCall(this.unregisterPostMessageHookProc, "Int", app.windowId)
    logger.info("Post message hook unregistered from window with id <mark>" . app.windowId . "</mark>: desktop switched.", "DesktopManager.__Delete")
  }
  
  createDesktop() {
    SendInput, #^d
  }
  
  getCurrentDesktopIndex() {
    ;; The desktop indices returned from virtual desktop accessor start at 0.
    ;; According to the AutoHotkey conventions these are shifted therewith starting at 1.
    Return, DllCall(this.getCurrentDesktopNumberProc, "UInt") + 1
  }
  
  getDesktopCount() {
    Return, DllCall(this.getDesktopCountProc, "UInt")
  }
  
  getWindowDesktopIndex(winId) {
    Return, DllCall(this.getWindowDesktopNumberProc, "UInt", winId) + 1
  }
  
  isPinnedWindow(winId) {
    Global logger
    
    ;; Returns 1 if pinned, 0 if not pinned, -1 if not valid.
    result := DllCall(this.isPinnedWindowProc, "UInt", winId)
    If (result == -1) {
      logger.warning("Result invalid: neither pinned, nor not pinned.", "DesktopManager.isPinnedWindow")
    }
    
    Return, result
  }
  
  moveWindowToDesktop(winId, index) {
    DllCall(this.moveWindowToDesktopNumberProc, "UInt", winId, "UInt", index - 1)
  }
  
  pinWindow(winId) {
    DllCall(this.pinWindowProc, "UInt", winId)
  }
  
  removeDesktop() {
    SendInput, #^{F4}
  }
  
  restartVirtualDesktopAccessor() {
    result := ""
    DllCall(this.restartVirtualDesktopAccessorProc, "UInt", result)
    Return, result
  }
  
  goToDesktop(index) {
    DllCall(this.goToDesktopNumberProc, "Int", index - 1)
  }
  
  unPinWindow(winId) {
    DllCall(this.unPinWindowProc, "UInt", winId)
  }
}
