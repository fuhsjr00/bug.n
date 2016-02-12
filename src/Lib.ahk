/*
:title:     bug.n -- Tiling Window Management
:copyright: (c) 2016 by Joshua Fuhs & joten <https://github.com/fuhsjr00/bug.n>
:license:   GNU General Public License version 3;
              LICENSE.md or at <http://www.gnu.org/licenses/>

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

Cmd_eval(s) {
  Log_msg("**Command_eval**: '" . s . "'", 5)
  c := SubStr(s, 1, 5)
  If (s = "ExitApp")
    ExitApp
  Else If (s = "Reload")
    Reload
  Else If (c = "Send ")
    Send % SubStr(s, 6)
  Else If (c = "Run, ") {
    parameters := SubStr(s, 6)
    StringReplace, parameters, parameters, `,%A_Space%, `,, All
    StringSplit, p, parameters, `,
    If (p0 = 1)
      Run, %p1%
    Else If (p0 = 2)
      Run, %p1%, %p2%
    Else If (p0 = 3)
      Run, %p1%, %p2%, %p3%
    Else If (p0 = 4)
      Run, %p1%, %p2%, %p3%, %p4%
  } Else {
    i := InStr(s, "(")
    j := InStr(s, ")", False, i)
    If i And j {
      fun := SubStr(s, 1, i - 1)
      arguments := SubStr(s, i + 1, j - (i + 1))
      StringReplace, arguments, arguments, %A_Space%, , All
      StringSplit, arg, arguments, `,
      If (arg0 = 0)
        %fun%()
      Else If (arg0 = 1)
        %fun%(arg1)
      Else If (arg0 = 2)
        %fun%(arg1, arg2)
      Else If (arg0 = 3)
        %fun%(arg1, arg2, arg3)
      Else If (arg0 = 4)
        %fun%(arg1, arg2, arg3, arg4)
    }
  }
  Log_msg("Command evaluated '" . s . "'", 4)
}

Int_min(a, b) {
  Return, a < b ? a : b
}

Int_max(a, b) {
  Return, a > b ? a : b
}

Str_pad(s, chars, count) {
  str := ""
  Loop, % Abs(count)
    str .= chars
  If (count < 0)
    Return SubStr(str . s, count + 1)
  Else
    Return SubStr(s . str, 1, count)
}
