/*
:title:     bug.n/user-interfaces/app-user-interface
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class AppUserInterface extends Rectangle {
  __New(index) {
    this.index := index
    this.name := "AppUserInterface"
    
    this.appCallFuncObject := ObjBindMethod(this, "_onAppCall")
    this.items := {"bar": {}, "content": {}}
    this.updateIntervals := {}
    
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
  
  __Delete() {
    Global logger
    
    i := this.index
    Gui, %i%: Destroy
    logger.warning("User Interface #" . i . " deleted.", "AppUserInterface.__Delete")
  }
  
  _init() {
    Global const, logger
    Static appIface, webBrowser
    
    ;; This window should not be visible in the Windows Taskbar or Alt-Tab-menu, not have a title bar and be at the bottom of the window stack.
    i := this.index
    Gui, %i%: Default
    Gui, Destroy
    Gui, Margin, 0, 0
    Gui, % "+AlwaysOnTop -Caption +HwndWinId +LabelUiface +LastFound +ToolWindow"
    this.winId := winId
    
    If (this.includeAppIface) {
      ;; `appInterface` is a REST-like interface allowing external scripts to call predefined funtions by inserting content to an Edit control.
      Gui, Add, Edit, x0 y0 w0 h0 Hidden vAppIface
      GuiControl, +g, appIface, % this.appCallFuncObject
    }
    Gui, Add, ActiveX, % "vWebBrowser w" . this.w . " h" . this.h, Shell.Explorer
    this.webBrowser := webBrowser
    this.webBrowser.Navigate("file://" . A_ScriptDir . "\modules\user-interfaces\app-user-interface.html")
    DllCall("urlmon\CoInternetSetFeatureEnabled"
          , "Int",  const.FEATURE_DISABLE_NAVIGATION_SOUNDS
          , "UInt", const.SET_FEATURE_ON_PROCESS
          , "Int",  1)
    ;; MrBubbles (2016) Webapp.ahk - Make web-based apps with AutoHotkey. [source code] https://autohotkey.com/boards/viewtopic.php?p=117029#p117029
    logger.debug("Waiting for IE to load the page (possible infinite loop).", "AppUserInterface._init")
		While this.webBrowser.readystate != 4 || this.webBrowser.busy {
		  Sleep, 10   ;; Wait for IE to load the page, referencing it.
		}
    logger.debug("IE loaded the page.", "AppUserInterface._init")
    ;; jodf (2016) Webapp.ahk - Make web-based apps with AutoHotkey. [source code] https://autohotkey.com/boards/viewtopic.php?p=117029#p117029
		ComObjConnect(this.webBrowser, New this.EventHandler())   ;; Connect ActiveX control events to the associated class object.
		logger.info("ActiveX control of User Interface #" . this.index . " connected to event handler.", "AppUserInterface._init")
    
    ;; First set the height of the w3-bar DOM element corresponding to the W3.CSS font size, then reassign the actual height in px.
    this.barH := this.barHeight := this.barH
    Gui, Show, % "x" . this.x . " y" . this.y . " w" . this.w . " h" . this.h, % "User Interface #" . this.index
    If (!this.alwaysOnTop) {
      WinSet, Bottom, , % "ahk_id " . this.winId
    }
    WinSet, Transparent, % this.transparency, % "ahk_id " . this.winId
    logger.info("User Interface #" . this.index . " created.", "AppUserInterface._init")
    
    this.updateItems("", True)
    For part, updateInterval in this.updateIntervals {
      If (updateInterval > 0) {
        funcObject := ObjBindMethod(this, "updateItems", part)
        SetTimer, % funcObject, % updateInterval
        logger.debug("Timer for updating items in User Interface #" . this.index . " (part <i>" . part . "</i>) set to " . updateInterval . " milliseconds.", "AppUserInterface._init")
      }
    }
  }
  
  _onAppCall(uri) {
  }
  
  class EventHandler {
    BeforeNavigate(disp, url) {
      disp.Stop()
    }
    BeforeNavigate2(disp, url) {
      Global logger
      
      disp.Stop()
      If (i := InStr(url, "#")) {
        urlPath := SubStr(url, i + 1)
        this.appCallFuncObject(urlPath)
        logger.info("App function called with argument " . urlPath . ".", "AppUserInterface.EventHandler.BeforeNavigate2")
      }
    }
    DocumentComplete(disp, url) {
      disp.Stop()
    }
    DownloadComplete(disp, url) {
      disp.Stop()
    }
    NavigateComplete2(disp, url) {
      disp.Stop()
    }
    NavigateError(disp, url) {
      disp.Stop()
    }
  }
  
  resizeGuiControls() {
    Global logger
    
    i := this.index
    GuiControl, %i%: Move, this.webBrowser, % "w" . A_GuiWidth . " h" . A_GuiHeight
    logger.info("ActiveX control in User Interface #" . i . " resized to width " . A_GuiWidth . " and height " . A_GuiHeight . ".", "AppUserInterface.resizeGuiControls")
  }
  
  updateItems(part := "", init := False) {
    If (part == "bar" || part == "") {
      If (init) {
        indices := ["01"]
        values := [""]
        classNames := [""]
        iconNames := ["window-minimize", ""]
        this.setBarItems(indices, values, classNames, iconNames)
      }
    }
  }
  
  ;; Functions controlling the DOM of the loaded HTML file in this.webBrowser (ActiveX control).
  ;; Changing elements by id.
  ;; 
  barHeight[] {
    get {
      Return, this.webBrowser.document.getElementById("app-bar").clientHeight
    }
    
    set {
      className := this.webBrowser.document.getElementById("app-bar").className
      this.webBrowser.document.getElementById("app-bar").className := RegExReplace(className, "w3-(tiny|small|medium|large|xlarge|xxlarge|xxxlarge|jumbo)", "w3-" . value)
      h := this.webBrowser.document.getElementById("app-bar").clientHeight
      ; this.webBrowser.document.getElementsByClassName("w3-main")[0].style.marginTop := h . "px"
      Return, h
    }
  }
  
  fitContent(offset := 0) {
    Global logger
    
    iconHeight := this.webBrowser.document.getElementById("app-icons").offsetHeight
    For subId, index in this.items.content {
      element := this.webBrowser.document.getElementById("app-view-" . index)
      h3Height := element.getElementsByTagName("h3")[0].offsetHeight
      inputHeight := 0
      If (element.contains("input")) {
        inputHeight := element.getElementsByTagName("input")[0].offsetHeight
      }
      footerHeight := this.webBrowser.document.getElementsByTagName("footer")[0].offsetHeight
      contentHeight := this.h - this.barHeight - iconHeight - h3Height - inputHeight - footerHeight - offset
      element.getElementsByTagName("div")[0].style.height := contentHeight . "px"
      logger.debug("Table fitted to (" . this.h . " - " . this.barHeight . " - " . iconHeight . " - " . h3Height . " - " . inputHeight . " - " . footerHeight . " - " . offset . ") = " . contentHeight, "AppUserInterface.fitContent")
    }
  }
  
  insertContentItems(index, data, position := "beforeend") {
    ;; possible position values: "afterbegin" or "beforeend".
    For i, tr in data {
      html := "<tr class='app-tr'>"
      For j, td in tr {
        html .= "<td>" . td . "</td>"
      }
      html .= "</tr>"
      this.webBrowser.document.getElementById("app-view-" . index).getElementsByTagName("tbody")[0].insertAdjacentHTML(position, html)
    }
    element := this.webBrowser.document.getElementById("app-icon-" . index).getElementsByTagName("div")[1]
    element.innerHTML += data.Length()
  }
  
  removeContentItems(index, data) {
    Global logger
    
    tbody := this.webBrowser.document.getElementById("app-view-" . index).getElementsByTagName("tbody")[0]
    For i, item in data {
      logger.debug("Removing row with first cell's content <mark>" . item . "</mark>.", "AppUserInterface.removeTableRows")
      rows := tbody.getElementsByClassName("app-tr")
      n := rows.length
      Loop, % n {
        If (RegExMatch(rows[n - A_Index].getElementsByTagName("td")[0].innerHTML, "^" . item . "<div")) {
          tbody.removeChild(rows[n - A_Index])
          element := this.webBrowser.document.getElementById("app-icon-" . index).getElementsByTagName("div")[1]
          element.innerHTML -= 1
        }
      }
    }
  }
  
  setBarItems(indices, values, classNames, iconNames) {
    ;; `indices` should be an array of string values identifying the "app-bar-item-(??)".
    ;; `values` should be an array of HTML strings.
    ;; `classNames` should be an array of arrays with to items: 1. the replaced class name, 2. the replacement.
    ;; `iconNames` should be an array of icon names identifying a font awesome class name as in "fa-(.+)".
    ;; All array have to be of the same size. If all values to a corresponding index are empty, the app bar item will be hidden.
    If (indices.Length() > 0 && indices.Length() == values.Length() && indices.Length() == classNames.Length() && indices.Length() == iconNames.Length()) {
      For i, index in indices {
        element := this.webBrowser.document.getElementById("app-bar-item-" . index)
        element.className := StrReplace(element.className, " w3-hide", "")
        element.getElementsByTagName("span")[0].innerHTML := values[i]
        If (values[i] == "" && classNames[i] == "" && iconNames[i] == "") {
          element.className .= " w3-hide"
        } Else {
          If (classNames[i] != "" && classNames[i].Length() == 2) {
            If (classNames[i][1] == "" && !InStr(element.className, classNames[i][2])) {
              element.className .= " " . classNames[i][2]
            } Else {
              element.className := StrReplace(element.className, classNames[i][1], classNames[i][2])
            }
          }
          If (iconNames[i] != "" && iconNames[i].Length() == 2) {
            icon := element.getElementsByTagName("i")[0]
            If (iconNames[i][1] == "" && !InStr(icon.className, iconNames[i][2])) {
              icon.className := "fa fa-" . iconNames[i][2] . (values[i] != "" ? " app-bar-item-icon" : "")
              icon.className := StrReplace(icon.className, " w3-hide", "")
            } Else If (iconNames[i][2] == "") {
              icon.className .= " w3-hide"
            }
          }
        }
      }
    }
  }
  ;; 
  ;; End of DOM related functions.
}
