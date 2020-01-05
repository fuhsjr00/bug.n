/*
:title:     bug.n/layouts/dwm-monocle-layout
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class DwmMonocleLayout {
  __New(index) {
    this.index := index
    this.name := "DwmMonocleLayout"
    this.symbol := "[M]"
  }
  
  arrange(x, y, w, h, windows) {
    For i, wnd in windows {
      wnd.move(x, y, w, h)
    }
    this.symbol := "[" . windows.Length() . "]"
  }
}
