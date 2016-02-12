/*
:title:     bug.n -- Tiling Window Management
:copyright: (c) 2016 by Joshua Fuhs & joten <https://github.com/fuhsjr00/bug.n>
:license:   GNU General Public License version 3;
              LICENSE.md or at <http://www.gnu.org/licenses/>

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

Log_init(truncate = True) {
  Global Log_file, Log_level
  Global Log_level_#0, Log_level_#1, Log_level_#2, Log_level_#3, Log_level_#4, Log_level_#5, Log_level_#6, Log_level_#7
  
  If Not Log_level
    Log_level := 2
  
  l := ";CRITICAL;ERROR;WARNING;INFO;DEBUG;SUPER"
  StringSplit, Log_level_#, l, `;
  
  If truncate And FileExist(Log_file)
    FileDelete, %Log_file%
  FormatTime, t, , yyyy-MM-dd
  FileAppend, % "`r`n# " . t . "`r`n", %Log_file%
  Log_msg("Log started", 4)
}

Log_msg(text, l, t = True) {    ;; level = 0: log in any case
  Global Log_file, Log_level
  Global Log_level_#1, Log_level_#2, Log_level_#3, Log_level_#4, Log_level_#5, Log_level_#6, Log_level_#7
  
  If (Log_level >= l) {
    If t
      FormatTime, t, , yyyy-MM-dd HH:mm:ss
    i := l + 1
    text := Str_pad(t, " ", 19) . "> " . Str_pad(Log_level_#%i%, ".", 8) . ": " . text . "`r`n"
    FileAppend, %text%, %Log_file%
  }
}

Log_setLevel(d, l = 0) {
  Global Log_level
  Global Log_level_#1, Log_level_#2, Log_level_#3, Log_level_#4, Log_level_#5, Log_level_#6, Log_level_#7
  
  l := l ? l : Log_level
  l := Int_min(Int_max(l + d, 1), 6)
  If (l != Log_level) {
    Log_level := l
    i := l + 1
    Log_msg("Log level set to " . Log_level_#%i%, 0)
  }
}
