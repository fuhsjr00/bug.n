/*
:title:     bug.n/monitormanager
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class MonitorManager {
  __New() {
    Global logger, sys
    
    ;; enum _PROCESS_DPI_AWARENESS
    ; DllCall("SHcore\SetProcessDpiAwareness", "UInt", sys.PROCESS_PER_MONITOR_DPI_AWARE)
    ;; InnI: Get per-monitor DPI scaling factor (https://www.autoitscript.com/forum/topic/189341-get-per-monitor-dpi-scaling-factor/?tab=comments#comment-1359832)
    ;; Setting `PROCESS_PER_MONITOR_DPI_AWARE` resulted in an access violation.
    ;; Setting `DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE` did work without errors, but does it have an effect?
    result := DllCall("User32\SetProcessDpiAwarenessContext", "UInt" , sys.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
    ;; pneumatic: -DPIScale not working properly (https://www.autohotkey.com/boards/viewtopic.php?p=241869&sid=abb2db983d2b3966bc040c3614c0971e#p241869)
    logger.debug("Dll 'User32\SetProcessDpiAwarenessContext' called with result <mark>" . result . "</mark>.", "MonitorManager.__New")
    
    ptr := A_PtrSize ? "Ptr" : "UInt"
    this.monitors := []
    this.monitorIndices := {}
    this.primaryMonitor := 0
    DllCall("EnumDisplayMonitors", ptr, 0, ptr, 0, ptr, RegisterCallback("MonitorEnumProc", "", 4, &this), "UInt", 0)
    ;; Solar: SysGet incorrectly identifies monitors (https://autohotkey.com/board/topic/66536-sysget-incorrectly-identifies-monitors/)
    logger.info(this.monitors.Length() . " display monitor" . (this.monitors.Length() == 1 ? "" : "s") . " found.", "MonitorManager.__New")
    this.enumAutoHotkeyMonitors()
  }
  
  enumAutoHotkeyMonitors() {
    Global logger
    
    SysGet, n, MonitorCount
    logger.info(n . " monitor" . (n == 1 ? "" : "s") . " found by AutoHotkey.", "MonitorManager.enumAutoHotkeyMonitors")
    Loop, % n {
      SysGet, name, MonitorName, % A_Index
      SysGet, rect, Monitor, % A_Index
      
      key := rectLeft . "-" . rectTop . "-" . rectRight . "-" . rectBottom
      If (this.monitorIndices.HasKey(key)) {
        i := this.monitorIndices[key]
      } Else {
        logger.debug("Additional monitor with key <mark>" . key . "</mark> found by AutoHotkey.", "MonitorManager.enumAutoHotkeyMonitors")
        i := this.monitors.Length() + 1
        this.monitors[i] := New this.Monitor(0, 0, rectLeft, rectTop, rectRight, rectBottom)
        this.monitorIndices[key]  := i
      }
      this.monitors[i].aIndex     := A_Index
      this.monitors[i].name       := name
      this.monitors[i].workArea   := New this.WorkArea(i)
    }
    SysGet, i, MonitorPrimary
    this.monitors[i].isPrimary    := True
    this.primaryMonitor := i
    logger.info("Monitor " . i . " found to be the primary monitor.", "MonitorManager.enumAutoHotkeyMonitors")
  }
  
  class Monitor {
    __New(index, handle, rectLeft, rectTop, rectRight, rectBottom) {
      Global logger
      
      this.handle     := handle
      this.index      := index
      this.aIndex     := 0
      this.isPrimary  := False
      this.key        := rectLeft . "-" . rectTop . "-" . rectRight . "-" . rectBottom
      this.name       := ""
      this.workArea   := ""
      
      this.left   := rectLeft
      this.top    := rectTop
      this.right  := rectRight
      this.bottom := rectBottom
      
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
      Global sys
      
      ptr := A_PtrSize ? "Ptr" : "UInt"
      dpiX := dpiY := 0
      If (this.handle != 0) {
        DllCall("SHcore\GetDpiForMonitor", ptr, this.handle, "Int", sys.MDT_DEFAULT, "UInt*", dpiX, "UInt*", dpiY)
      }
      
      Return, {x: dpiX, y: dpiY}
    }
    ;; InnI: Get per-monitor DPI scaling factor (https://www.autoitscript.com/forum/topic/189341-get-per-monitor-dpi-scaling-factor/?tab=comments#comment-1359832)
  }
  
  class WorkArea {
    __New(i) {
      this.index := i
      
      SysGet, rect, MonitorWorkArea, % i
      this.left   := rectLeft
      this.top    := rectTop
      this.right  := rectRight
      this.bottom := rectBottom
      
      this.x := rectLeft
      this.y := rectTop
      this.w := rectRight - rectLeft
      this.h := rectBottom - rectTop
    }
  }
}

;; The function `MonitorEnumProc` could not be integrated into the `MonitorManager` class.
;; Using an `ObjBindMethod` as the function reference in `RegisterCallback` did not work.
;; The object reference could be passed via `A_EventInfo`.
MonitorEnumProc(hMonitor, hdcMonitor, lprcMonitor, dwData) {
  l := NumGet(lprcMonitor + 0,  0, "UInt")
  t := NumGet(lprcMonitor + 0,  4, "UInt")
  r := NumGet(lprcMonitor + 0,  8, "UInt")
  b := NumGet(lprcMonitor + 0, 12, "UInt")
  
  this := Object(A_EventInfo)
  ;; Helgef: Allow RegisterCallback with BoundFunc objects (https://www.autohotkey.com/boards/viewtopic.php?p=235243#p235243)
  i := this.monitors.Length() + 1
  this.monitors[i] := New this.Monitor(i, hMonitor, l, t, r, b)
  this.monitorIndices[l . "-" . t . "-" . r . "-" . b] := i
  
	Return, 1
}
