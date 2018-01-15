/*
  bug.n -- tiling window management
  Copyright (c) 2010-2018 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.2
*/

ResourceMonitor_init() {
  Global Config_readinDiskLoad, Config_readinNetworkLoad, ResourceMonitor_hDrive

  If Config_readinDiskLoad
    ResourceMonitor_hDrive := DllCall("CreateFile", "Str", "\\.\PhysicalDrive0", "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
  ;; This call may lead to bug.n hanging (bug 019005).
  If Config_readinNetworkLoad
    ResourceMonitor_getNetworkInterface()
}

ResourceMonitor_cleanup() {
  Global Config_readinDiskLoad, ResourceMonitor_hDrive

  If Config_readinDiskLoad
    DllCall("CloseHandle", "UInt", ResourceMonitor_hDrive)    ;; used in ResourceMonitor_getDiskLoad
}

ResourceMonitor_bytesToString(b) {
  If (b > 1047527424) {
    b /= 1024 * 1024 * 1024
    unit := "GB"
  } Else If (b > 1022976) {
    b /= 1024 * 1024
    unit := "MB"
  } Else If (b > 999) {
    b /= 1024
    unit := "kB"
  } Else {
    unit := " B"
  }
  b := Round(b, 1)
  If (b > 99.9 Or unit = " B")
    b := Round(b, 0)
  Return, SubStr("    " b, -3) . unit
}

ResourceMonitor_getBatteryStatus(ByRef batteryLifePercent, ByRef acLineStatus) {
  VarSetCapacity(powerStatus, (1 + 1 + 1 + 1 + 4 + 4))
  success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
  If (ErrorLevel != 0 Or success = 0) {
    MsgBox 16, Power Status, Can't get the power status...
    Return
  }
  acLineStatus       := NumGet(powerStatus, 0, "Char")
  batteryLifePercent := NumGet(powerStatus, 2, "Char")

  If acLineStatus = 0
    acLineStatus = off
  Else If acLineStatus = 1
    acLineStatus = on
  Else If acLineStatus = 255
    acLineStatus = ?

  If batteryLifePercent = 255
    batteryLifePercent = ???
}
;; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)

ResourceMonitor_getDiskLoad(ByRef readLoad, ByRef writeLoad) {
  Global ResourceMonitor_hDrive
  Static oldReadCount, oldWriteCount

  nReturn := oldReadCount := oldWriteCount := 0
  dpSize := 5 * 8 + 4 + 4 + 4 + 4 + 8 + 4 + 8 * (A_IsUnicode ? 2 : 1) + 12    ;; 88?
  VarSetCapacity(dp, dpSize)
  DllCall("DeviceIoControl", "UInt", ResourceMonitor_hDrive, "UInt", 0x00070020, "UInt", 0, "UInt", 0, "UInt", &dp, "UInt", dpSize, "UIntP", nReturn, "UInt", 0)    ;; IOCTL_DISK_PERFORMANCE

  newReadCount  := NumGet(dp, 40)
  newWriteCount := NumGet(dp, 44)
  readLoad  := SubStr("  " Round((1 - 1 / (1 +  newReadCount -  oldReadCount)) * 100), -2)
  writeLoad := SubStr("  " Round((1 - 1 / (1 + newWriteCount - oldWriteCount)) * 100), -2)
  oldReadCount  := newReadCount
  oldWriteCount := newWriteCount
}
;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
;; SKAN: HDD Activity Monitoring LED (http://www.autohotkey.com/community/viewtopic.php?p=113890&sid=64d9824fdf252697ff4d5026faba91f8#p113890)

ResourceMonitor_getMemoryUsage() {
  VarSetCapacity(memoryStatus, 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4)
  DllCall("kernel32.dll\GlobalMemoryStatus", "UInt", &memoryStatus)
  Return, SubStr("  " Round(*(&memoryStatus + 4)), -2)    ;; LS byte is enough, 0..100
}
;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)

ResourceMonitor_getNetworkInterface() {
  Global Config_readinNetworkLoad, ResourceMonitor_networkInterface

  objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
  WQLQuery := "SELECT * FROM Win32_PerfFormattedData_Tcpip_NetworkInterface WHERE Name LIKE '%" . Config_readinNetworkLoad . "%'"
  ResourceMonitor_networkInterface := objWMIService.ExecQuery(WQLQuery).ItemIndex(0)
}
;; Pillus: System monitor (HDD/Wired/Wireless) using keyboard LEDs (http://www.autohotkey.com/board/topic/65308-system-monitor-hddwiredwireless-using-keyboard-leds/)

ResourceMonitor_getNetworkLoad(ByRef upLoad, ByRef dnLoad) {
  Global ResourceMonitor_networkInterface

  ResourceMonitor_networkInterface.Refresh_
  dnLoad := ResourceMonitor_bytesToString(ResourceMonitor_networkInterface.BytesReceivedPerSec) . "/s"
  upLoad := ResourceMonitor_bytesToString(ResourceMonitor_networkInterface.BytesSentPerSec) . "/s"
}
;; Pillus: System monitor (HDD/Wired/Wireless) using keyboard LEDs (http://www.autohotkey.com/board/topic/65308-system-monitor-hddwiredwireless-using-keyboard-leds/)

ResourceMonitor_getSystemTimes() {
  ;; Total CPU Load
  Static oldIdleTime, oldKrnlTime, oldUserTime
  Static newIdleTime, newKrnlTime, newUserTime

  newIdleTime := newKrnlTime := newUserTime := 0
  oldIdleTime := newIdleTime
  oldKrnlTime := newKrnlTime
  oldUserTime := newUserTime

  DllCall("GetSystemTimes", "Int64P", newIdleTime, "Int64P", newKrnlTime, "Int64P", newUserTime)
  sysTime := SubStr("  " . Round((1 - (newIdleTime - oldIdleTime) / (newKrnlTime - oldKrnlTime+newUserTime - oldUserTime)) * 100), -2)
  Return, sysTime    ;; system time in percent
}
;; Sean: CPU LoadTimes (http://www.autohotkey.com/forum/topic18913.html)

ResourceMonitor_getText() {
  Global Config_readinCpu, Config_readinDiskLoad, Config_readinMemoryUsage, Config_readinNetworkLoad

  text := ""
  If Config_readinCpu
    text .= " CPU: " ResourceMonitor_getSystemTimes() "% "
  If Config_readinMemoryUsage {
    If (Config_readinCpu)
      text .= "|"
    text .= " RAM: " ResourceMonitor_getMemoryUsage() "% "
  }
  If Config_readinDiskLoad {
    If (Config_readinCpu Or Config_readinMemoryUsage)
      text .= "|"
    ResourceMonitor_getDiskLoad(rLoad, wLoad)
    text .= " Dr: " rLoad "% | Dw: " wLoad "% "
  }
  If Config_readinNetworkLoad {
    If (Config_readinCpu Or Config_readinMemoryUsage Or Config_readinDiskLoad)
      text .= "|"
    ResourceMonitor_getNetworkLoad(upLoad, dnLoad)
    text .= " UP: " upLoad " | dn: " dnLoad " "
  }

  Return, text
}
