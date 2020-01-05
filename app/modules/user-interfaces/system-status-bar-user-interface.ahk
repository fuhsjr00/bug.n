/*
:title:     bug.n/user-interfaces/system-status-bar-user-interface
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class SystemStatusBarUserInterface extends AppUserInterface {
  __New(index) {
    Global cfg
    
    this.index := index
    this.name := "SystemStatusBarUserInterface"
    
    this.appCallFuncObject := ObjBindMethod(this, "_onAppCall")
    this.items := {"bar": cfg.defaultSystemStatusBarItems, "content": {}}
    this.updateIntervals := {"system-status-bar": cfg.systemStatusBarUpdateInterval}
    
    this.x := 0
    this.y := 0
    this.w := 0
    this.h := 34
    
    this.alwaysOnTop := True
    this.barH := "small"
    this.includeAppIface := False
    this.transparency := "Off"    ;; `transparancy` is used to set the transparency of the whole window.
                                  ;; It can be set to an integer between 0 and 255 or the string "Off".
    
    this.webBrowser := ""
    this.winId := 0x0
    this.wnd   := ""
  }
  
  getSystemStatus(key, ByRef value := "", ByRef className := "", ByRef iconName := "") {
    Global cfg, sys
    
    If (key == "network") {
      If (sys.networkInterfaces.Length() == 0) {
        value := "?"
      } Else {
        data := sys.network
        value := StrReplace(Format("{" . (data[1].read.value >= 10 || data[1].read.value == 0 ? ":3u" : ":3.1f") . "}", data[1].read.value) . data[1].read.unit, " ", "&nbsp;")
        value .= "<span class='app-bar-item-separator'> &#8643;&#8638; </span>"
        value .= StrReplace(Format("{" . (data[1].write.value >= 10 || data[1].read.value == 0 ? ":3u" : ":3.1f") . "}", data[1].write.value) . data[1].write.unit, " ", "&nbsp;")
      }
      iconName := ["", "network-wired"]
    } Else If (key == "disk") {
      data := sys.disk
        value := StrReplace(Format("{" . (data[1].read.value >= 10 || data[1].read.value == 0 ? ":3u" : ":3.1f") . "}", data[1].read.value) . data[1].read.unit, " ", "&nbsp;")
        value .= "<span class='app-bar-item-separator'> &#8643;&#8638; </span>"
        value .= StrReplace(Format("{" . (data[1].write.value >= 10 || data[1].read.value == 0 ? ":3u" : ":3.1f") . "}", data[1].write.value) . data[1].write.unit, " ", "&nbsp;")
      iconName := ["", "hdd"]
    } Else If (key == "memory") {
      data := sys.memory
      value := StrReplace(Format("{:3u}", data.value), " ", "&nbsp;") . data.unit
      iconName := ["", "memory"]
    } Else If (key == "processor") {
      data := sys.processor
      value := StrReplace(Format("{:3u}", data.value), " ", "&nbsp;") . data.unit
      iconName := ["", "microchip"]
    } Else If (key == "battery") {
      data := sys.battery
      value := StrReplace(Format("{:3u}", data.value), " ", "&nbsp;") . data.unit
      ;; plug/ battery-empty/ battery-quarter/ battery-half/ battery-three-quarters/ battery-full
      If (data.status == "on") {
        iconName := ["", "plug"]
      } Else {
        className := ["app-bar-item-alarm", ""]
        If (data.value > 90) {
          iconName := ["", "battery-full"]
        } Else If (data.value > 60) {
          iconName := ["", "battery-three-quarters"]
        } Else If (data.value > 30) {
          iconName := ["", "battery-half"]
        } Else If (data.value > 10) {
          iconName := ["", "battery-quarter"]
        } Else {
          className := ["", "app-bar-item-alarm"]
          iconName := ["", "battery-empty"]
        }
      }
    } Else If (key == "volume") {
      data := sys.volume
      value := StrReplace(Format("{:3u}", data.value), " ", "&nbsp;") . data.unit
      ;; volume-mute/ volume-off/ volume-down/ volume-up
      If (data.status == "On") {
        iconName := ["", "volume-mute"]
      } Else {
        If (data.value == 0) {
          iconName := ["", "volume-off"]
        } Else If (data.value > 50) {
          iconName := ["", "volume-up"]
        } Else {
          iconName := ["", "volume-down"]
        }
      }
    } Else If (key == "date") {
      FormatTime, value, A_Now, % cfg.dateFormat
      iconName := ["", "calendar"]
    } Else If (key == "time") {
      FormatTime, value, A_Now, % cfg.timeFormat
      iconName := ["", "clock"]
    }
  }
  
  updateItems(part := "", init := False) {
    Global cfg
    
    If (part == "bar" || part == "") {
      If (init) {
        indices := ["01"]
        values := [""]
        classNames := [""]
        iconNames := ["window-minimize", ""]
        this.setBarItems(indices, values, classNames, iconNames)
      }
    }
    If (part == "system-status-bar" || part == "") {
      indices := []
      values := []
      classNames := []
      iconNames := []
      value := ""
      className := ""
      iconName := ""
      For key, index in cfg.defaultSystemStatusBarItems {
        indices.push(index)
        this.getSystemStatus(key, value, className, iconName)
        values.push(value)
        classNames.push(className)
        iconNames.push(iconName)
      }
      this.setBarItems(indices, values, classNames, iconNames)
    }
  }
}
