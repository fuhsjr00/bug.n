/*
:title:     bug.n/work-area
:copyright: (c) 2018-2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class WorkArea extends Rectangle {
  __New(desktopIndex, workAreaIndex, rect) {
    Global cfg
    
    this.dIndex := desktopIndex
    this.index := workAreaIndex
    this.id := this.dIndex . "-" . this.index
    this.x := rect.x
    this.y := rect.y
    this.w := rect.w
    this.h := rect.h
    
    this.isPrimary := False
    this.showBar := cfg.showBar
    this.uiface := ""
    
    this.layouts := []
    For i, item in cfg.defaultLayouts {
      name := item.name
      this.layouts[i] := New %name%(i)
      For key, value in this.layouts[i] {
        If (item.HasKey(key)) {
          this.layouts[i][key] := item[key]
        }
      }
    }
    this.layoutA := [this.layouts[1], this.layouts[2]]
    
    this.windows := []
    this.windowA := []
  }
  
  activate() {
    If (this.windowA.Length() > 0) {
      this.windowA[1].runCommand("activate")
    } Else {
      this.uiface.wnd.runCommand("activate")
    }
  }
  
  activateWindowAtIndex(wnd, index, delta, matchFloating) {
    currentIndex := wnd.workArea.index == this.index ? this.getWindowIndex(wnd) : 0
    index := index == 0 ? currentIndex : index
    If (delta != 0) {
      index := this.getAdjacentWindowIndex(index, delta, matchFloating)
    }
    If (index > 0 && index != currentIndex) {
      this.windows[index].runCommand("activate")
    }
  }
  
  addWindow(wnd) {
    this.windows.InsertAt(1, wnd)
  }
  
  arrange() {
    windows := []
    For i, wnd in this.windows {
      If (!wnd.isFloating) {
        wnd.runCommand("top")
        windows.push(wnd)
      }
    }
    this.layoutA[1].arrange(this.x, this.y + (this.showBar && IsObject(this.uiface) ? this.uiface.barH : 0)
                          , this.w, this.h - (this.showBar && IsObject(this.uiface) ? this.uiface.barH : 0), windows)
  }
  
  getAdjacentWindowIndex(index, delta, matchFloating) {
    i := getIndex(index, delta, this.windows.Length())
    If (!matchFloating && this.windows[i].isFloating) {
      delta := Round(delta / Abs(delta))
      Loop, % this.windows.Length() {
        i := getIndex(i, delta, this.windows.Length())
        If (!this.windows[i].isFloating) {
          Break
        }
      }
      i := this.windows[i].isFloating ? 0 : i
    }
    Return, i
  }
  
  getWindowIndex(wnd) {
    index := 0
    For i, item in this.windows {
      If (item.id == wnd.id) {
        index := i
        Break
      }
    }
    Return, index
  }
  
  moveWindowToPosition(wnd, index, delta) {
    ;; matchFloating := False
    currentIndex := this.getWindowIndex(wnd)
    If (index == 1 && delta == 0 && currentIndex == 1 && this.windows.Length() > 1) {
      index := 2
    } Else {
      index := index == 0 ? currentIndex : index
      If (delta != 0) {
        index := this.getAdjacentWindowIndex(index, delta, False)
      }
    }
    If (index != currentIndex) {
      this.windows.RemoveAt(currentIndex)
      this.windows.InsertAt(index, wnd)
    }
  }
  
  removeWindow(wnd) {
    this.windows.RemoveAt(this.getWindowIndex(wnd))
  }
  
  setLayoutProperty(key, value, delta) {
    Global logger
    
    If (this.layoutA[1].HasKey(key)) {
      funcObject := ObjBindMethod(this.layoutA[1], "set" . key)
      %funcObject%(value, delta)
    } Else {
      logger.warning("Property <mark>" . key . "</mark> not known for layout <i>" . this.layoutA[1].name . "</i>.", "WorkArea.setLayoutProperty")
    }
  }
  
  switchToLayout(index, delta) {
    If (index == 0) {
      index := this.layoutA[1].index
    } Else If (index == -1) {
      index := this.layoutA[2].index
    }
    i := getIndex(index, delta, this.layouts.Length())
    If (i != this.layoutA[1].index) {
      updateActive(this.layoutA, this.layouts[i])
    }
  }
}
