/*
:title:     bug.n -- Tiling Window Management
:copyright: (c) 2016 by Joshua Fuhs & joten <https://github.com/fuhsjr00/bug.n>
:license:   GNU General Public License version 3;
              LICENSE.md or at <http://www.gnu.org/licenses/>

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

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
