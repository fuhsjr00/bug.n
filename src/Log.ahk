/**
 *	AHK Debug log implementation
 *	Copyright (c) 2012 Joshua Fuhs
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
 *	@version 8.3.0
 */

Log_debug_level := 0

Log_init(name, truncate) {
	Global
	If truncate 
		IfExist, %name%
			FileDelete, %name%
	Log_name := name
}

Log_msg( message ) {
	Local CurrentTime
	If Not Log_name 
		Return
	FormatTime, CurrentTime, , yyyyMMddHHmmss
	FileAppend, %CurrentTime%  %message%`r`n, %Log_name%
}

Log_bare( message ) {
	Local padded_message
	If Not Log_name 
		Return
	padded_message := "    " . message . "`r`n"
	FileAppend, %padded_message% , %Log_name%
}

Log_incDebugLevel() {
	Global
	If Not Log_name 
		Return
	If ( Log_debug_level < 9 )
	{
		Log_debug_level += 1
		Log_msg("Debug logging level incremented to " . Log_debug_level )
	}
}

Log_decDebugLevel() {
	Global
	If Not Log_name 
		Return
	If ( Log_debug_level > 0 ) {
		Log_debug_level -= 1
		If ( Log_debug_level = 0 )
			Log_msg("Debug logging is disabled")
		Else
			Log_msg("Debug logging level decremented to " . Log_debug_level)
	}
}


Log_dbg_msg( level, message ) {
	Global
	If (level > 0 And Log_debug_level >= level)
		Log_msg( "DBG " . level . ":  " . message )
}

Log_dbg_bare( level, message ) {
	Global
	If (level > 0 And Log_debug_level >= level)
		Log_bare( "DBG " . level . ":  " . message )
}