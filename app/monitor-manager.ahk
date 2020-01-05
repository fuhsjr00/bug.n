/*
:title:     bug.n/monitor-manager
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class MonitorManager {
  __New(funcObject) {
    Global const, logger
    
    this.monitors := []
    this.monitorIndices := {}
    this.primaryMonitor := 0
    
    ;; Set DPI awareness.
    result := DllCall("User32\SetProcessDpiAwarenessContext", "UInt" , const.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
    ;; pneumatic: -DPIScale not working properly (https://www.autohotkey.com/boards/viewtopic.php?p=241869&sid=abb2db983d2b3966bc040c3614c0971e#p241869)
    ;; InnI: Get per-monitor DPI scaling factor (https://www.autoitscript.com/forum/topic/189341-get-per-monitor-dpi-scaling-factor/?tab=comments#comment-1359832)
    ;; Evaluating `DllCall("SHcore\SetProcessDpiAwareness", "UInt", const.PROCESS_PER_MONITOR_DPI_AWARE)` resulted in an access violation.
    ;; Setting `DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE` did work without errors, but does it have an effect?
    logger.debug("Dll <i>User32\SetProcessDpiAwarenessContext</i> called with result <mark>" . result . "</mark>.", "MonitorManager.__New")
    
    ;; Enumerate and synchronizing display/ AutoHotkey monitors.
    ptr := A_PtrSize ? "Ptr" : "UInt"
    DllCall("EnumDisplayMonitors", ptr, 0, ptr, 0, ptr, RegisterCallback("MonitorEnumProc", "", 4, &this), "UInt", 0)
    ;; Solar: SysGet incorrectly identifies monitors (https://autohotkey.com/board/topic/66536-sysget-incorrectly-identifies-monitors/)
    logger.info(this.monitors.Length() . " display monitor" . (this.monitors.Length() == 1 ? "" : "s") . " found.", "MonitorManager.__New")
    this.enumAutoHotkeyMonitors()
    
    OnMessage(const.WM_DISPLAYCHANGE, funcObject)
    logger.info("Window message <b>WM_DISPLAYCHANGE</b> registered.", "MonitorManager.__New")
  }
  
  enumAutoHotkeyMonitors() {
    ;; Enumerate the monitors as found by AutoHotkey, appending additional monitors not previously found,
    ;; synchronizing indices and supplementing information to monitor objects.
    Global logger
    
    SysGet, n, MonitorCount
    logger.info(n . " monitor" . (n == 1 ? "" : "s") . " found by <i>AutoHotkey</i>.", "MonitorManager.enumAutoHotkeyMonitors")
    Loop, % n {
      SysGet, name, MonitorName, % A_Index
      SysGet, rect, Monitor, % A_Index
      
      ;; Synchronizing indices.
      key := rectLeft . "-" . rectTop . "-" . rectRight . "-" . rectBottom
      If (this.monitorIndices.HasKey(key)) {
        i := this.monitorIndices[key]
        logger.debug("Monitor with key <mark>" . key . "</mark> found by <i>AutoHotkey</i> already at index <mark>" . i . "</mark>.", "MonitorManager.enumAutoHotkeyMonitors")
      } Else {
        i := this.monitors.Length() + 1
        
        ;; Appending additional monitors not previously found.
        logger.debug("Additional monitor with key <mark>" . key . "</mark> found by <i>AutoHotkey</i>.", "MonitorManager.enumAutoHotkeyMonitors")
        this.monitors[i] := New this.Monitor(i, 0, rectLeft, rectTop, rectRight, rectBottom)
        this.monitorIndices[key]  := i
      }
      ;; Supplementing information.
      this.monitors[i].aIndex     := A_Index
      this.monitors[i].name       := name
      
      SysGet, rect, MonitorWorkArea, % i
      this.monitors[i].monitorWorkArea := New Rectangle(rectLeft, rectTop, rectRight - rectLeft, rectBottom - rectTop)
    }
    SysGet, i, MonitorPrimary
    this.monitors[i].isPrimary    := True
    this.primaryMonitor := i
    logger.info("Monitor <b>" . i . "</b> found to be the <b>primary monitor</b>.", "MonitorManager.enumAutoHotkeyMonitors")
  }
  
  class Monitor extends Rectangle {
    __New(index, handle, rectLeft, rectTop, rectRight, rectBottom) {
      Global logger
      
      this.handle      := handle
      this.index       := index
      this.aIndex      := 0
      this.isPrimary   := False
      this.key         := rectLeft . "-" . rectTop . "-" . rectRight . "-" . rectBottom
      this.name        := ""
      this.trayWnd     := ""
      this.monitorWorkArea := ""
      
      this.x := rectLeft
      this.y := rectTop
      this.w := rectRight - rectLeft
      this.h := rectBottom - rectTop
      
      dpi := this.getDpiForMonitor()
      this.dpiX := dpi.x
      this.dpiY := dpi.y
      this.scaleX := this.dpiX / 96
      this.scaleY := this.dpiY / 96
      
      logger.info("Monitor with key <mark>" . this.key . "</mark> added at index <mark>" . this.index . "</mark>.", "Monitor.__New")
    }
    
    getDpiForMonitor() {
      Global const
      
      dpiX := dpiY := 0
      If (this.handle != 0) {
        ptr := A_PtrSize ? "Ptr" : "UInt"
        DllCall("SHcore\GetDpiForMonitor", ptr, this.handle, "Int", const.MDT_DEFAULT, "UInt*", dpiX, "UInt*", dpiY)
      }
      
      Return, {x: dpiX, y: dpiY}
    }
    ;; InnI: Get per-monitor DPI scaling factor (https://www.autoitscript.com/forum/topic/189341-get-per-monitor-dpi-scaling-factor/?tab=comments#comment-1359832)
  
    setMonitorWorkArea() {
      Global const
      
      VarSetCapacity(area, 16)
      NumPut(this.monitorWorkArea.x,                          area,  0)
      NumPut(this.monitorWorkArea.y,                          area,  4)
      NumPut(this.monitorWorkArea.x + this.monitorWorkArea.w, area,  8)
      NumPut(this.monitorWorkArea.y + this.monitorWorkArea.h, area, 12)
      DllCall("SystemParametersInfo", "UInt", const.SPI_SETWORKAREA, "UInt", 0, "UInt", &area, "UInt", 0)
    }
    ;; flashkid: Send SetWorkArea to second Monitor (http://www.autohotkey.com/board/topic/42564-send-setworkarea-to-second-monitor/)
  }
}

;; The function `MonitorEnumProc` could not be integrated into the `MonitorManager` class.
;; Using an `ObjBindMethod` as the function reference in `RegisterCallback` did not work.
;; The object reference could be passed via `A_EventInfo`.
MonitorEnumProc(hMonitor, hdcMonitor, lprcMonitor, dwData) {
  rectLeft    := NumGet(lprcMonitor + 0,  0, "UInt")
  rectTop     := NumGet(lprcMonitor + 0,  4, "UInt")
  rectRight   := NumGet(lprcMonitor + 0,  8, "UInt")
  rectBottom  := NumGet(lprcMonitor + 0, 12, "UInt")
  
  this := Object(A_EventInfo)
  ;; Helgef: Allow RegisterCallback with BoundFunc objects (https://www.autohotkey.com/boards/viewtopic.php?p=235243#p235243)
  i := this.monitors.Length() + 1
  this.monitors[i] := New this.Monitor(i, hMonitor, rectLeft, rectTop, rectRight, rectBottom)
  this.monitorIndices[this.monitors[i].key] := i
  
	Return, 1
}
