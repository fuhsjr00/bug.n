/*
:title:     bug.n/user-interfaces/minimal-user-interface
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class MinimalUserInterface {
  __New(index) {
    this.index := index
    this.name := "MinimalUserInterface"
    
    this.appCallFuncObject := ObjBindMethod(this, "_onAppCall")
    this.items := {"bar": {}, "content": {}}
    this.updateIntervals := {}
  }
  
  __Delete() {
  }
  
  _init() {
    this.updateItems("", True)
    For part, updateInterval in this.updateIntervals {
      If (updateInterval > 0) {
        funcObject := ObjBindMethod(this, "updateItems", part)
        SetTimer, % funcObject, % updateInterval
        logger.debug("Timer for updating items in User Interface #" . this.index . " (part <i>" . part . "</i>) set to " . updateInterval . " milliseconds.", "MinimalUserInterface._init")
      }
    }
  }
  
  _onAppCall(uri) {
  }
  
  updateItems(part := "", init := False) {
  }
}
