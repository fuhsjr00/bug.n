/**
 *	bug.n - tiling window management
 *	Copyright (c) 2010-2011 joten
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *	@version 8.2.0.03 (24.07.2011)
 */

Session_restore(section, m=0) {
	Local i, type, var, var0, var1, var2
	
	If FileExist(Config_sessionFilePath) {
		If (section = "Config") {
			Loop, READ, %Config_sessionFilePath%
				If (SubStr(A_LoopReadLine, 1, 7) = "Config_") {
					StringSplit, var, A_LoopReadLine, =
					type := SubStr(var1, 1, 13)
					If (type = "Config_hotkey")
						Config_hotkeyCount += 1
					Else If (type = "Config_rules_") {
						i := SubStr(var1, 14)
						If (i > Config_rulesCount) {
							Config_rulesCount += 1
							i := Config_rulesCount
							var1 := "Config_rules_#" i
						}
					}
					%var1% := var2
				}
		} Else If (section = "Monitor") {
			Loop, READ, %Config_sessionFilePath%
				If (SubStr(A_LoopReadLine, 1, 10+StrLen(m)) = "Monitor_#" m "_" Or SubStr(A_LoopReadLine, 1, 8+StrLen(m)) = "View_#" m "_#") {
					StringSplit, var, A_LoopReadLine, =
					%var1% := var2
				}
		}
	}
}

Session_save() {
	Local m, text
	
	text := "; bug.n - tiling window management`n; @version " VERSION " (" A_DD "." A_MM "." A_YYYY ")`n`n"
	If FileExist(Config_sessionFilePath) {
		Loop, READ, %Config_sessionFilePath%
			If (SubStr(A_LoopReadLine, 1, 7) = "Config_")
				text .= A_LoopReadLine "`n"
		text .= "`n"
	}
	FileDelete, %Config_sessionFilePath%
	
	Loop, % Manager_monitorCount {
		m := A_Index
		If Not (Monitor_#%m%_aView_#1 = 1)
			text .= "Monitor_#" m "_aView_#1=" Monitor_#%m%_aView_#1 "`n"
		If Not (Monitor_#%m%_aView_#2 = 1)
			text .= "Monitor_#" m "_aView_#2=" Monitor_#%m%_aView_#2 "`n"
		If Not (Monitor_#%m%_showBar = Config_showBar)
			text .= "Monitor_#" m "_showBar=" Monitor_#%m%_showBar "`n"
		Loop, % Config_viewCount {
			If Not (View_#%m%_#%A_Index%_layout_#1 = 1)
				text .= "View_#" m "_#" A_Index "_layout_#1=" View_#%m%_#%A_Index%_layout_#1 "`n"
			If Not (View_#%m%_#%A_Index%_layout_#2 = 1)
				text .= "View_#" m "_#" A_Index "_layout_#2=" View_#%m%_#%A_Index%_layout_#2 "`n"
			If Not (View_#%m%_#%A_Index%_layoutAxis_#1 = Config_layoutAxis_#1)
				text .= "View_#" m "_#" A_Index "_layoutAxis_#1=" View_#%m%_#%A_Index%_layoutAxis_#1 "`n"
			If Not (View_#%m%_#%A_Index%_layoutAxis_#2 = Config_layoutAxis_#2)
				text .= "View_#" m "_#" A_Index "_layoutAxis_#2=" View_#%m%_#%A_Index%_layoutAxis_#2 "`n"
			If Not (View_#%m%_#%A_Index%_layoutAxis_#3 = Config_layoutAxis_#3)
				text .= "View_#" m "_#" A_Index "_layoutAxis_#3=" View_#%m%_#%A_Index%_layoutAxis_#3 "`n"
			If Not (View_#%m%_#%A_Index%_layoutMFact = Config_layoutMFactor)
				text .= "View_#" m "_#" A_Index "_layoutMFact=" View_#%m%_#%A_Index%_layoutMFact "`n"
			If Not (View_#%m%_#%A_Index%_layoutMSplit = 1)
				text .= "View_#" m "_#" A_Index "_layoutMSplit=" View_#%m%_#%A_Index%_layoutMSplit "`n"
		}
	}
	
	FileAppend, %text%, %Config_sessionFilePath%
}
