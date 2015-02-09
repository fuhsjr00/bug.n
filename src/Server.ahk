/*
  bug.n -- tiling window management
  Copyright (c) 2010-2015 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.0
*/

Server_init()
{
    ; Create a hidden GUI with an edit control.
    gui, 1:add, edit, w50 h20 vcommand gOnCommandReceived
    ;gui, show, NA, bug.n_BAR_1
}

; Whenever the text in the edit control is changed this subroutine is launched.
OnCommandReceived:
{
    gui, 1:submit, NoHide
    if (RegExMatch(command, "^\s*\w+\s*\(\s*\)\s*$")) ; no args
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        %function%()
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 1 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
        %function%(arg1)
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 2 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg2 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        %function%(arg1, arg2)
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 3 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg2 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg3 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        %function%(arg1, arg2, arg3)
    }
    else if (RegExMatch(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*\)\s*$")) ; 4 arg
    {
        function := RegExReplace(command, "^\s*(\w+)\s*\(.*", "${1}")
        arg1 := RegExReplace(command, "^\s*\w+\s*\(\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg2 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg3 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        arg4 := RegExReplace(command, "^\s*\w+\s*\(\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*[-""_a-zA-Z0-9]+\s*,\s*([-""_a-zA-Z0-9]+).*", "${1}")
        %function%(arg1, arg2, arg3, arg4)
    }
}

; Just use this to send command
;     detecthiddenwindows, on
;     controlsettext, edit1, % "Monitor_setXXX()", bug.n_BAR_1
;     controlsettext, edit1, % "Monitor_setWindowTag(2)", bug.n_BAR_1
;     controlsettext, edit1, % "Monitor_setZZZ(1, 3)", bug.n_BAR_1

;; vim:sts=2 sw=2
