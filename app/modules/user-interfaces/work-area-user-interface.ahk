/*
:title:     bug.n/user-interfaces/work-area-user-interface
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class WorkAreaUserInterface extends AppUserInterface {
  __New(index) {
    Global cfg
    
    this.index := index
    this.name := "WorkAreaUserInterface"
    
    this.appCallFuncObject := ObjBindMethod(this, "_onAppCall")
    this.items := {"bar": {"desktops": "01", "layout": "02", "monitor": "03", "window": "04"}
      , "content": {"configuration": "01", "desktops": "02", "monitors": "04", "work-areas": "06", "windows": "07", "messages": "09", "log": "11"}}
    For key, index in cfg.defaultSystemStatusBarItems {
      this.items.bar[key] := index
    }
    this.updateIntervals := {"system-status-bar": cfg.systemStatusBarUpdateInterval
      , "messages": cfg.messagesViewUpdateInterval, "log": cfg.logViewUpdateInterval}
    
    this.x := 0
    this.y := 0
    this.w := 0
    this.h := 0
    
    this.alwaysOnTop := False
    this.barH := "small"
    this.includeAppIface := False
    this.transparency := "Off"    ;; `transparancy` is used to set the transparency of the whole window.
                                  ;; It can be set to an integer between 0 and 255 or the string "Off".
    
    this.webBrowser := ""
    this.winId := 0x0
    this.wnd   := ""
  }
  
  updateItems(part := "", init := False) {
    Global cfg, logger, mgr, SystemStatusBarUserInterface
    
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
        SystemStatusBarUserInterface.getSystemStatus(key, value, className, iconName)
        values.push(value)
        classNames.push(className)
        iconNames.push(iconName)
      }
      this.setBarItems(indices, values, classNames, iconNames)
    }
    If ((part == "messages" || part == "") && !init) {
      this.insertContentItems(this.items.content["messages"], (IsObject(mgr) ? mgr.shellEventCache : []), "afterbegin")
      mgr.shellEventCache := []
    }
    If (part == "log" || part == "") {
      this.insertContentItems(this.items.content["log"], logger.cache, "afterbegin")
      logger.cache := []
    }
    If (part == "") {
      If (init) {
        For key, index in this.items.content {
          ; "content": {"configuration": "01", "desktops": "02", "monitors": "04", "work-areas": "06", "windows": "07", "messages": "09", "log": "11"}}
          this.setContent(index, key)
        }
      }
    }
  }
  
  ;; Functions controlling the DOM of the loaded HTML file in this.webBrowser (ActiveX control).
  ;; Changing elements by id.
  ;; 
  getContentItem(key, source) {
    data := []
    
    If (key == "windows") {
      ;; "<tr><th>Id</th><th>Class</th><th>Title</th><th>Process Name</th><th>Style</th><th>ExStyle</th><th>Min/ Max</th><th>x-Coordinate</th><th>y-Coordinate</th><th>Width</th><th>Height</th><th>Desktop</th></tr>"
      properties := "<span class=""w3-tooltip"">" . source.id
          . "<span style=""position: absolute; left: 0; width: 16em; z-index: 3;"" class=""w3-text w3-tag w3-light-grey w3-left-align"">"
          . "<i class=""fa fa-window-maximize w3-padding-small w3-text-" . (source.hasCaption   ? "blue"    : "grey") . """></i>"
          . "<i class=""fa fa-star            w3-padding-small w3-text-" . (source.isAppWindow  ? "green"   : "grey") . """></i>"
          . "<i class=""fa fa-child           w3-padding-small w3-text-" . (source.isChild      ? "black"   : "grey") . """></i>"
          . "<i class=""fa fa-mask            w3-padding-small w3-text-" . (source.isCloaked    ? "purple"  : "grey") . """></i>"
          . "<i class=""fa fa-shield-alt      w3-padding-small w3-text-" . (source.isElevated   ? "orange"  : "grey") . """></i>"
          . "<i class=""fa fa-ghost           w3-padding-small w3-text-" . (source.isGhost      ? "pink"    : "grey") . """></i>"
          . "<i class=""fa fa-window-restore  w3-padding-small w3-text-" . (source.isPopup      ? "blue"    : "grey") . """></i>" . "</span></span>"
      ;; *class*, *title*, pId, *pName*, pPath, *style*, _exStyle_, _minMax_, hasCaption, isAppWindow, isChild, isCloaked, isElevated, isGhost, isPopup
      title := source.title
      If (StrLen(title) > 16) {
        title := "<span class=""w3-tooltip"">" . SubStr(title, 1, 16)
          . "...<span style=""position: absolute; left: 0; z-index: 3;"" class=""w3-text w3-tag w3-light-grey"">"
          . StrReplace(title, " ", "&nbsp;") . "</span></span>"
      }
      pName := source.pName
      If (StrLen(pName) > 16) {
        pName := "<span class=""w3-tooltip"">" . SubStr(pName, 1, 16)
          . "...<span style=""position: absolute; left: 0; z-index: 3;"" class=""w3-text w3-tag w3-light-grey"">"
          . StrReplace(pName, " ", "&nbsp;") . "</span></span>"
      }
      style := "<span class=""w3-tooltip"">" . source.style
          . "<span style=""position: absolute; left: 0; z-index: 3;"" class=""w3-text w3-tag w3-light-grey w3-left-align"">"
          . "Style:&nbsp;" . source.style . "<br/>ExStyle:&nbsp;" . source.exStyle . "<br/>Min/&nbsp;Max:&nbsp;" . source.minMax . "</span></span>"
      data := [properties, source.class, title, pName, style, source.x, source.y, source.w, source.h
          , source.desktop, source.workArea.index, source.isFloating]
      
    } Else If (key == "messages") {
      winId := "<span class=""w3-tooltip"">" . source.winId
          . "<span style=""position: absolute; right: -1ex; z-index: 3;"" class=""w3-text w3-tag w3-light-grey"">"
          . StrReplace((source.winTitle != "" ? "Title: " . source.winTitle . " | " : "")
                     . (source.winClass != "" ? "Class: " . source.winClass . " | " : "")
                     . "Id: " . source.winId, " ", "&nbsp;") . "</span></span>"
      data := [source.timestamp, source.msg, source.num, winId]
    }
    
    Return, data
  }
  
  setContent(index, key) {
    iconName := ""
    theadHTML := ""
    If (key == "configuration") {
      iconName := "fa-tools"
    } Else If (key == "desktops") {
      iconName := "fa-layer-group"
      theadHTML := "<tr><th>Index</th><th>Label</th></tr>"
    } Else If (key == "monitors") {
      iconName := "fa-desktop"
      theadHTML := "<tr><th>Index</th><th>Name</th><th>x-Coordinate</th><th>y-Coordinate</th><th>Width</th><th>Height</th></tr>"
    } Else If (key == "work-areas") {
      iconName := "fa-object-group"
      theadHTML := "<tr><th>Desktop</th><th>Index</th><th>x-Coordinate</th><th>y-Coordinate</th><th>Width</th><th>Height</th></tr>"
    } Else If (key == "windows") {
      iconName := "fa-window-restore"
      theadHTML := "<tr><th>Id</th><th>Class</th><th>Title</th><th>Process Name</th><th>Style</th><th>x-Coord.</th><th>y-Coord.</th><th>Width</th><th>Height</th><th>Desktop</th><th>Work Area</th><th>Floating?</th></tr>"
    } Else If (key == "messages") {
      iconName := "fa-ellipsis-v"
      theadHTML := "<tr><th>Timestanmp</th><th>Message</th><th>Number</th><th>Window Id</th></tr>"
    } Else If (key == "log") {
      iconName := "fa-scroll"
      theadHTML := "<tr><th>Timestanmp</th><th>Level</th><th>Source</th><th>Message</th></tr>"
    }
    
    element := this.webBrowser.document.getElementById("app-icon-" . index)
    icon := element.getElementsByTagName("i")[0]
    icon.className := StrReplace(icon.className, "fa-window-minimize", iconName)
    element.getElementsByTagName("h4")[0].innerHTML := Format("{:T}", StrReplace(key, "-", " "))
    element.className := StrReplace(element.className, " w3-hide", "")
    
    element := this.webBrowser.document.getElementById("app-view-" . index).getElementsByTagName("h3")[0]
    icon := element.getElementsByTagName("i")[0]
    icon.className := StrReplace(icon.className, "fa-window-minimize", iconName)
    element.getElementsByTagName("span")[0].innerHTML := Format("{:T}", StrReplace(key, "-", " "))
    this.webBrowser.document.getElementById("app-view-" . index).getElementsByTagName("thead")[0].innerHTML := theadHTML
    
    element := this.webBrowser.document.getElementsByTagName("footer")[0]
    element.className := StrReplace(element.className, " w3-hide", "")
  }
  ;; 
  ;; End of DOM related functions.
}
