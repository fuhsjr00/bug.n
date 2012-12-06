/*
  bug.n -- tiling window management
  Copyright (c) 2010-2012 Joshua Fuhs, joten

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.

  @version 8.4.0
*/

ResourceMonitor_init()
{
  ResourceMonitor_hDrive := DllCall("CreateFile", "Str", "\\.\PhysicalDrive0", "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
  ResourceMonitor_getNetworkInterface()
}

ResourceMonitor_cleanup()
{
  DllCall("CloseHandle", "UInt", ResourceMonitor_hDrive)    ;; used in ResourceMonitor_getDiskLoad
}

ResourceMonitor_getText()
{
  Global Config_readinCpu, Config_readinDate, Config_readinDiskLoad, Config_readinMemoryUsage, Config_readinNetworkLoad

  text := ""
  If Config_readinCpu
    text .= " CPU: " ResourceMonitor_getSystemTimes() "% "
  If Config_readinMemoryUsage
  {
    If Config_readinCpu
      text .= "|"
    text .= " RAM: " ResourceMonitor_getMemoryUsage() "% "
  }
  If Config_readinDiskLoad
  {
    If (Config_readinCpu Or Config_readinMemoryUsage)
      text .= "|"
    ResourceMonitor_getDiskLoad(rLoad, wLoad)
    text .= " Dr: " rLoad "% | Dw: " wLoad "% "
  }
  If Config_readinNetworkLoad
  {
    If (Config_readinCpu Or Config_readinMemoryUsage Or Config_readinDiskLoad)
      text .= "|"
    ResourceMonitor_getNetworkLoad(upLoad, dnLoad)
    text .= " UP: " upLoad " KB/s | dn: " dnLoad " KB/s "
  }
  If Config_readinDate And (Config_readinCpu Or Config_readinMemoryUsage Or Config_readinDiskLoad Or Config_readinNetworkLoad)
    text .= "|"

  Return, text
}

ResourceMonitor_getDiskLoad(ByRef readLoad, ByRef writeLoad)
{
  Global ResourceMonitor_hDrive
  Static oldReadCount, oldWriteCount

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

ResourceMonitor_getMemoryUsage()
{
  VarSetCapacity(memoryStatus, 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4)
  DllCall("kernel32.dll\GlobalMemoryStatus", "UInt", &memoryStatus)
  Return, SubStr("  " Round(*(&memoryStatus + 4)), -2)    ;; LS byte is enough, 0..100
}
;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)

ResourceMonitor_getNetworkInterface()
{
  Global ResourceMonitor_networkInterface, ResourceMonitor_networkInterfaceTable

  DllCall("iphlpapi\GetNumberOfInterfaces", "UIntP", n)
  nSize := 4 + 860 * n + 8
  VarSetCapacity(ResourceMonitor_networkInterfaceTable, nSize)
  If Not DllCall("iphlpapi\GetIfTable", "UInt", &ResourceMonitor_networkInterfaceTable, "UIntP", nSize, "Int", False)
  {
    Loop, 2
    {
      i := 0
      j := A_Index
      Loop, % NumGet(ResourceMonitor_networkInterfaceTable)
      {
        If NumGet(ResourceMonitor_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 544) < 4
        || NumGet(ResourceMonitor_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 516) = 24
          Continue
        i += 1
        dn_#%i%_#%j% := NumGet(ResourceMonitor_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 552)
        up_#%i%_#%j% := NumGet(ResourceMonitor_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 576)
      }
      If (A_Index < 2)
        RunWait, %Comspec% /c ping -n 1 127.0.0.1, , hide
    }

    Loop, % i
    {
      If (dn_#%i%_#2 > dn_#%i%_1)
      {
        ResourceMonitor_networkInterface := i
        Break
      }
    }
  }
}
;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)

ResourceMonitor_getNetworkLoad(ByRef upLoad, ByRef dnLoad)
{
  Global ResourceMonitor_networkInterface, ResourceMonitor_networkInterfaceTable
  Static dn_#0, t_#0, up_#0

  DllCall("iphlpapi\GetIfEntry", "UInt", &ResourceMonitor_networkInterfaceTable + 4 + 860 * (ResourceMonitor_networkInterface - 1))
  dn_#1 := NumGet(ResourceMonitor_networkInterfaceTable, 4 + 860 * (ResourceMonitor_networkInterface - 1) + 552)    ;; Total Incoming Bytes
  up_#1 := NumGet(ResourceMonitor_networkInterfaceTable, 4 + 860 * (ResourceMonitor_networkInterface - 1) + 576)    ;; Total Outgoing Bytes
  tDiff := (A_TickCount - t_#0) / 1000
  t_#0  := A_TickCount

  dnLoad := SubStr("   " Round((dn_#1 - dn_#0) / 1024 / tDiff), -3)
  upLoad := SubStr("   " Round((up_#1 - up_#0) / 1024 / tDiff), -3)

  dn_#0 := dn_#1
  up_#0 := up_#1
}
;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
;; Sean: Network Download/Upload Meter (http://www.autohotkey.com/community/viewtopic.php?t=18033)

ResourceMonitor_getSystemTimes()
{    ;; Total CPU Load
  Static oldIdleTime, oldKrnlTime, oldUserTime
  Static newIdleTime, newKrnlTime, newUserTime

  oldIdleTime := newIdleTime
  oldKrnlTime := newKrnlTime
  oldUserTime := newUserTime

  DllCall("GetSystemTimes", "Int64P", newIdleTime, "Int64P", newKrnlTime, "Int64P", newUserTime)
  sysTime := SubStr("  " . Round((1 - (newIdleTime - oldIdleTime) / (newKrnlTime - oldKrnlTime+newUserTime - oldUserTime)) * 100), -2)
  Return, sysTime    ;; system time in percent
}
;; Sean: CPU LoadTimes (http://www.autohotkey.com/forum/topic18913.html)
