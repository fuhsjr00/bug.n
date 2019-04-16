/*
:title:     bug.n/system
:copyright: (c) 2018-2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class System {
  __New(networkInterfaces := "") {
    ;; physicalDrives and networkInterfaces should be arrays of device names; e.g. physicalDrives may be ["PhysicalDrive0"].
    Global logger
    
    /*
      Windows CONSTANTS
      Monitor
    */
    ;; enum _PROCESS_DPI_AWARENESS
    this.PROCESS_DPI_UNAWARE                        :=  0
    this.PROCESS_SYSTEM_DPI_AWARE                   :=  1
    this.PROCESS_PER_MONITOR_DPI_AWARE              :=  2
    this.DPI_AWARENESS_CONTEXT_UNAWARE              := -1
    this.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE         := -2
    this.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE    := -3
    this.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 := -4
    ;; enum _MONITOR_DPI_TYPE
    this.MDT_EFFECTIVE_DPI  := 0
    this.MDT_ANGULAR_DPI    := 1
    this.MDT_RAW_DPI        := 2
    this.MDT_DEFAULT        := this.MDT_EFFECTIVE_DPI
    
    this.SPI_SETWORKAREA    := 0x2F
    
    /*
      Windows CONSTANTS
      GUI
    */
    this.FEATURE_DISABLE_NAVIGATION_SOUNDS := 21
    this.SET_FEATURE_ON_PROCESS            := 0x00000002
    
    /*
      Windows CONSTANTS
      ShellHook
    */
    this.HSHELL_WINDOWCREATED        :=  1
    this.HSHELL_WINDOWDESTROYED      :=  2
    ;; this.HSHELL_ACTIVATESHELLWINDOW  :=  3
    this.HSHELL_WINDOWACTIVATED      :=  4
    ;; this.HSHELL_GETMINRECT           :=  5
    this.HSHELL_REDRAW               :=  6
    ;; this.HSHELL_TASKMAN              :=  7
    ;; this.HSHELL_LANGUAGE             :=  8
    ;; this.HSHELL_SYSMENU              :=  9
    ;; this.HSHELL_ENDTASK              := 10
    ;; this.HSHELL_ACCESSIBILITYSTATE   := 11
    ;; this.HSHELL_APPCOMMAND           := 12
    ;; this.HSHELL_WINDOWREPLACED       := 13
    ;; this.HSHELL_WINDOWREPLACING      := 14
    ;; this.HSHELL_HIGHBIT              := 15?
    ;; this.HSHELL_FLASH                := 16?
    ;; this.HSHELL_RUDEAPPACTIVATED     := 17?
    ;; this.HSHELL_HIGHBIT              := 32768    ;; 0x8000
    ;; this.HSHELL_FLASH                := 32774    ;; (HSHELL_REDRAW|HSHELL_HIGHBIT)
    this.HSHELL_RUDEAPPACTIVATED     := 32772    ;; (HSHELL_WINDOWACTIVATED|HSHELL_HIGHBIT)
    this.HSHELL_messages := []
    this.HSHELL_messages[1]     := "WINDOWCREATED"
    this.HSHELL_messages[2]     := "WINDOWDESTROYED"
    ;; this.HSHELL_messages[3]     := "ACTIVATESHELLWINDOW"
    this.HSHELL_messages[4]     := "WINDOWACTIVATED"
    ;; this.HSHELL_messages[5]     := "GETMINRECT"
    this.HSHELL_messages[6]     := "REDRAW"
    ;; this.HSHELL_messages[7]     := "TASKMAN"
    ;; this.HSHELL_messages[8]     := "LANGUAGE"
    ;; this.HSHELL_messages[9]     := "SYSMENU"
    ;; this.HSHELL_messages[10]    := "ENDTASK"
    ;; this.HSHELL_messages[11]    := "ACCESSIBILITYSTATE"
    ;; this.HSHELL_messages[12]    := "APPCOMMAND"
    ;; this.HSHELL_messages[13]    := "WINDOWREPLACED"
    ;; this.HSHELL_messages[14]    := "WINDOWREPLACING"
    ;; this.HSHELL_messages[15]    := "HIGHBIT"
    ;; this.HSHELL_messages[16]    := "FLASH"
    ;; this.HSHELL_messages[17]    := "RUDEAPPACTIVATED"
    ;; this.HSHELL_messages[32768] := "HIGHBIT"
    ;; this.HSHELL_messages[32774] := "FLASH"
    this.HSHELL_messages[32772] := "RUDEAPPACTIVATED"
    
    /*
      Windows CONSTANTS
      Window
    */
    ;; this.DWMWA_CLOAK         :=  13
    this.DWMWA_CLOAKED       :=  14
    this.DWMWA_EXTENDED_FRAME_BOUNDS := 9
    this.GW_OWNER            :=   4
    this.WM_DISPLAYCHANGE    := 126              ;; This message is sent when the display resolution has changed.
    this.WM_ENTERSIZEMOVE    := 0x00000231
    this.WM_EXITSIZEMOVE     := 0x00000232
    this.WM_NULL             := 0
    this.WS_CAPTION          := 0x00C00000
    this.WS_CHILD            := 0x40000000
    ;; this.WS_CLIPCHILDREN     := 0x2000000
    ;; this.WS_DISABLED         := 0x8000000
    this.WS_EX_APPWINDOW     := 0x0040000
    ;; this.WS_EX_CONTROLPARENT := 0x0010000
    ;; this.WS_EX_DLGMODALFRAME := 0x0000001
    this.WS_EX_TOOLWINDOW    := 0x00000080
    this.WS_EX_TOPMOST       := 0x00000008
    this.WS_POPUP            := 0x80000000
    ;; this.WS_VSCROLL          := 0x200000
    
    this.objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
    this.networkInterfaces := []
    For i, item in networkInterfaces {
      WQLQuery := "SELECT * FROM Win32_PerfFormattedData_Tcpip_NetworkInterface WHERE Name LIKE '%" . item . "%'"
      this.networkInterfaces[i] := this.objWMIService.ExecQuery(WQLQuery).ItemIndex(0)
      logger.info("Queried Win32_PerfFormattedData_Tcpip_NetworkInterface for " . item . ".", "System.__New")
    }
  }
  
  __Delete() {
    DllCall("DeregisterShellHookWindow", "UInt", this.shellHookWinId)
  }
  
  registerShellHookWindow(funcObject, winId := 0) {
    ;; functionObject should be a function object (not a function name), for the callback function, which can receive the two arguments, wParam (message number) and lParam (window id).
    Global logger
    
    this.shellHookWinId := winId ? winId : WinExist()
    DllCall("RegisterShellHookWindow", "UInt", this.shellHookWinId)
    msgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
    OnMessage(msgNum, funcObject)
    logger.info("ShellHook registered to window (id = " . this.winId . ")", "System.registerShellHookWindow")
  }
  ;; SKAN: How to Hook on to Shell to receive its messages? (http://www.autohotkey.com/forum/viewtopic.php?p=123323#123323)
  
  ;; System information and helper functions
  
  battery[] {
    get {
      Global logger
      
      VarSetCapacity(powerStatus, (1 + 1 + 1 + 1 + 4 + 4))
      If (DllCall("GetSystemPowerStatus", "UInt", &powerStatus) && ErrorLevel = 0) {
        acLineStatus := NumGet(powerStatus, 0, "Char")
        batteryLevel := NumGet(powerStatus, 2, "Char")
      } Else {
        logger.error("Could not get the power status.", "System.battery.get")
        acLineStatus := batteryLevel := 255
      }
      acLineStatus := (acLineStatus = 0) ? "off" : (acLineStatus = 1) ? "on" : "?"
      batteryLevel := (batteryLevel = 255) ? "???" : batteryLevel

      Return, {level: {value: batteryLevel, unit: "%"}, acLineStatus: acLineStatus}
    }
  }
  ;; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)
  
  cpuUsage[] {
    get {
      n := 0, p := 0
      For item in this.objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfOS_Processor") {
        n += 1
    		p += item.PercentProcessorTime
    	}
      Return, {value: Round(p / n, 0), unit: "%"}
    }
    ;; TLM: Accessing PerfMon counters (https://www.autohotkey.com/boards/viewtopic.php?p=103227&sid=7b13f0bbd27b9ab88ce05870f44545b8#p103227)
  }
  
  formatBytes(value) {
    If (value > 1047527424) {
      value /= 1024 * 1024 * 1024
      unit := "GB"
    } Else If (value > 1022976) {
      value /= 1024 * 1024
      unit := "MB"
    } Else If (value > 999) {
      value /= 1024
      unit := "kB"
    } Else {
      unit := " B"
    }
    value := Round(value, 1)
    If (value > 99.9 || unit = " B") {
      value := Round(value, 0)
    }
  
    Return, {value: value, unit: unit}
  }
  
  memoryUsage[] {
    get {
      VarSetCapacity(memoryStatus, 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4)
      DllCall("kernel32.dll\GlobalMemoryStatus", "UInt", &memoryStatus)
      Return, {value: Round(*(&memoryStatus + 4)), unit: "%"}   ;; LS byte is enough, 0..100
    }
    ;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
  }
  
  network[] {
    get {
      usage := []
      r := 0, s := 0
      For i, item in this.networkInterfaces {
        item.Refresh_
        r += item.BytesReceivedPerSec
        s += item.BytesSentPerSec
    	}
      r := this.formatBytes(r)
      s := this.formatBytes(s)
      r.unit   .= "/s"
      s.unit .= "/s"
      usage.push({received: r, sent: s})
      Return, usage
    }
    ;; TLM: Accessing PerfMon counters (https://www.autohotkey.com/boards/viewtopic.php?p=103227&sid=7b13f0bbd27b9ab88ce05870f44545b8#p103227)
    ;; Pillus: System monitor (HDD/Wired/Wireless) using keyboard LEDs (http://www.autohotkey.com/board/topic/65308-system-monitor-hddwiredwireless-using-keyboard-leds/)
  }
  
  storage[] {
    get {
      usage := []
      r := 0, w := 0
      For item in this.objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfDisk_PhysicalDisk") {
        r += item.DiskWriteBytesPersec
        w += item.DiskReadBytesPersec
    	}
      r := this.formatBytes(r)
      w := this.formatBytes(w)
      r.unit   .= "/s"
      w.unit .= "/s"
      usage.push({read: r, write: w})
      Return, usage
    }
    ;; TLM: Accessing PerfMon counters (https://www.autohotkey.com/boards/viewtopic.php?p=103227&sid=7b13f0bbd27b9ab88ce05870f44545b8#p103227)
  }
  
  volume[] {
    get {
      SoundGet, volumeLevel, MASTER, VOLUME
      SoundGet, muteStatus, MASTER, MUTE
      
      Return, {level: {value: Round(volumeLevel), unit: "%"}, muteStatus: muteStatus}
    }
  }
}
