/*
  bug.n -- tiling window management
  Copyright (c) 2010-2014 Joshua Fuhs, joten

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

Server_init()
{
    ; Create a hidden GUI with an edit control.
    gui, 1:add, edit, w50 h20 vcommand gOnCommandReceived
    ;gui, show, NA, scriptcomwin_1
}

; Whenever the text in the edit control is changed this subroutine is launched.
OnCommandReceived:
{
    gui, 1:submit, NoHide
;     MsgBox % command
    if (RegExMatch(command, "^\s*\w+\s*\(\s*\)\s*$")) ; no args
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
;         MsgBox % function
        %function%()
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 1 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
;         MsgBox % function
;         MsgBox % arg1
        %function%(arg1)
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 2 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg2 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
;         MsgBox % function
;         MsgBox % arg1
;         MsgBox % arg2
        %function%(arg1, arg2)
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 3 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg2 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg3 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
;         MsgBox % function
;         MsgBox % arg1
;         MsgBox % arg2
;         MsgBox % arg3
        %function%(arg1, arg2, arg3)
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 4 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg2 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg3 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg4 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
;         MsgBox % function
;         MsgBox % arg1
;         MsgBox % arg2
;         MsgBox % arg3
;         MsgBox % arg4
        %function%(arg1, arg2, arg3, arg4)
    }
}

; Just use this to send command
;     detecthiddenwindows, on
;     controlsettext, edit1, % "Monitor_setWindowTag(2)", scriptcomwin_1

