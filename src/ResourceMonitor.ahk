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
  
  @version 8.3.0
*/

ResourceMonitor_getText() 
{
  Global Config_readinCpu, Config_readinDate, Config_readinDiskLoad, Config_readinMemoryUsage, Config_readinNetworkLoad
  
  text := ""
  If Config_readinCpu
    text .= " CPU: " Bar_getSystemTimes() "% "
  If Config_readinMemoryUsage 
  {
    If Config_readinCpu
      text .= "|"
    text .= " RAM: " Bar_getMemoryUsage() "% "
  }
  If Config_readinDiskLoad 
  {
    If (Config_readinCpu Or Config_readinMemoryUsage)
      text .= "|"
    Bar_getDiskLoad(rLoad, wLoad)
    text .= " Dr: " rLoad "% | Dw: " wLoad "% "
  }
  If Config_readinNetworkLoad 
  {
    If (Config_readinCpu Or Config_readinMemoryUsage Or Config_readinDiskLoad)
      text .= "|"
    Bar_getNetworkLoad(upLoad, dnLoad)
    text .= " UP: " upLoad " KB/s | dn: " dnLoad " KB/s "
  }
  If Config_readinDate And (Config_readinCpu Or Config_readinMemoryUsage Or Config_readinDiskLoad Or Config_readinNetworkLoad)
    text .= "|"
  
  Return, text
}
