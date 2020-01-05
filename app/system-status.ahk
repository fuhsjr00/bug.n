/*
:title:     bug.n/system-status
:copyright: (c) 2018-2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class SystemStatus {
  __New(networkInterfaces := "") {
    ;; physicalDrives and networkInterfaces should be arrays of device names; e.g. physicalDrives may be ["PhysicalDrive0"].
    Global logger
    
    logger.debug("Retrieving COM object for WMI service.", "SystemStatus.__New")
    this.objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
    this.networkInterfaces := []
    logger.debug("Querying WMI service for network interfaces.", "SystemStatus.__New")
    For i, item in networkInterfaces {
      WQLQuery := "SELECT * FROM Win32_PerfFormattedData_Tcpip_NetworkInterface WHERE Name LIKE '%" . item . "%'"
      this.networkInterfaces[i] := this.objWMIService.ExecQuery(WQLQuery).ItemIndex(0)
      logger.info("Win32_PerfFormattedData_Tcpip_NetworkInterface quieried for <b>" . item . "</b>.", "SystemStatus.__New")
    }
  }
  
  battery[] {
    get {
      Global logger
      
      VarSetCapacity(powerStatus, (1 + 1 + 1 + 1 + 4 + 4))
      If (DllCall("GetSystemPowerStatus", "UInt", &powerStatus) && ErrorLevel == 0) {
        acLineStatus := NumGet(powerStatus, 0, "Char")
        batteryLevel := NumGet(powerStatus, 2, "Char")
      } Else {
        logger.error("Could not get power status.", "SystemStatus.battery.get")
        acLineStatus := batteryLevel := 255
      }
      acLineStatus := (acLineStatus = 0) ? "off" : (acLineStatus = 1) ? "on" : "?"
      batteryLevel := (batteryLevel = 255) ? "???" : batteryLevel
      
      Return, {value: batteryLevel, unit: "%", status: acLineStatus}
    }
  }
  ;; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)
  
  disk[] {
    get {
      data := []
      r := 0, w := 0
      For item in this.objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfDisk_PhysicalDisk") {
        r += item.DiskWriteBytesPersec
        w += item.DiskReadBytesPersec
    	}
      r := this.formatBytes(r)
      w := this.formatBytes(w)
      r.unit .= "/s"
      w.unit .= "/s"
      data.push({read: r, write: w})
      Return, data
    }
    ;; TLM: Accessing PerfMon counters (https://www.autohotkey.com/boards/viewtopic.php?p=103227&sid=7b13f0bbd27b9ab88ce05870f44545b8#p103227)
  }
  
  memory[] {
    get {
      VarSetCapacity(memoryStatus, 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4)
      DllCall("kernel32.dll\GlobalMemoryStatus", "UInt", &memoryStatus)
      Return, {value: Round(*(&memoryStatus + 4)), unit: "%"}   ;; LS byte is enough, 0..100
    }
    ;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
  }
  
  network[] {
    get {
      data := []
      r := 0, w := 0
      For i, item in this.networkInterfaces {
        item.Refresh_
        r += item.BytesReceivedPerSec
        w += item.BytesSentPerSec
    	}
      r := this.formatBytes(r)
      w := this.formatBytes(w)
      r.unit .= "/s"
      w.unit .= "/s"
      data.push({read: r, write: w})
      Return, data
    }
    ;; TLM: Accessing PerfMon counters (https://www.autohotkey.com/boards/viewtopic.php?p=103227&sid=7b13f0bbd27b9ab88ce05870f44545b8#p103227)
    ;; Pillus: System monitor (HDD/Wired/Wireless) using keyboard LEDs (http://www.autohotkey.com/board/topic/65308-system-monitor-hddwiredwireless-using-keyboard-leds/)
  }
  
  processor[] {
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
  
  volume[] {
    get {
      SoundGet, volumeLevel, MASTER, VOLUME
      SoundGet, muteStatus, MASTER, MUTE
      
      Return, {value: Round(volumeLevel), unit: "%", status: muteStatus}
    }
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
    value := Format("{:.3f}", value)
  
    Return, {value: value, unit: unit}
  }
}
