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

Debug_initLog(filename, level = 0, truncateFile = True) 
{
  Global Debug_logFilename, Debug_logLevel
  
  Debug_logFilename := filename
  Debug_logLevel := level
  If truncateFile
    If FileExist(Debug_logFilename)
      FileDelete, %Debug_logFilename%
  Debug_logMessage("Log initialized.", 0)
}

Debug_logMessage(text, level = 1, includeTimestamp = True) 
{
  Global Debug_logFilename, Debug_logLevel
  
  If Debug_logLevel >= level 
  {
    If includeTimestamp 
    {
      FormatTime, time, , yyyy-MM-dd HH:mm:ss
      text := time " " text
    }
    Else
      text := "                    " text
    FileAppend, %text%`r`n, %Debug_logFilename%
  }
}

Debug_setLogLevel(d) 
{
  Global Debug_logLevel
  
  i := Debug_logLevel + d
  If i >= 0
  {
    Debug_logLevel := i
    If i = 0
      Debug_logMessage("Logging disabled.")
    Else
      Debug_logMessage("Log level set to " i ".")
  }
}
