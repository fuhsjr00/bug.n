/*
:title:     bug.n/userinterface
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class UserInterface {
  __New(index, xCoordinate, yCoordinate, width, height, funcObject, transparency := "Off", barPosition := "top", barHeight := "medium", htmlFile := "") {
    ;; This is the web browser window with an ActiveX control. Argument 2-5 are used to position and size the window.
    ;; funcObject should be a function object for app:// calls, which can receive a string, the URL path, as an argument.
    ;; transparancy is used to set the transparency of the whole window and can be an integer between 0 and 255 or the string "Off".
    ;; htmlFile is the local file, which is loaded into the ActiveX control (web browser).
    Global logger, sys
    Static appIface, display
    
    this.index := index
    this.x := xCoordinate
    this.y := yCoordinate
    this.w := width
    this.h := height
    htmlFile := htmlFile != "" ? htmlFile : A_ScriptDir . "\userinterface.html"
    this.barIsVisible := True
    
    ;; This window should not be visible in the Windows Taskbar or Alt-Tab-menu, not have a title bar and be at the bottom of the window stack.
    Gui, %index%: Default
    Gui, Destroy
    Gui, Margin, 0, 0
    Gui, % "+AlwaysOnTop -Caption +HwndWinId +LabelUiface +LastFound +ToolWindow"
    this.winId := winId
    this.wnd   := ""
    
    Gui, Add, Edit, x0 y0 w0 h0 Hidden vAppIface
    GuiControl, +g, appIface, % funcObject
    Gui, Add, ActiveX, % "vDisplay w" . this.w . " h" . this.h, Shell.Explorer
    this.display := display
    this.display.Navigate("file://" . htmlFile)
    DllCall("urlmon\CoInternetSetFeatureEnabled"
           ,"Int",  sys.FEATURE_DISABLE_NAVIGATION_SOUNDS
           ,"UInt", sys.SET_FEATURE_ON_PROCESS
           ,"Int", 1)
    ;; MrBubbles (2016) Webapp.ahk - Make web-based apps with AutoHotkey. [source code] https://autohotkey.com/boards/viewtopic.php?p=117029#p117029
		While this.display.readystate != 4 || this.display.busy {
		  Sleep, 10                   ;; Wait for IE to load the page, referencing it.
		}
    ;; jodf (2016) Webapp.ahk - Make web-based apps with AutoHotkey. [source code] https://autohotkey.com/boards/viewtopic.php?p=117029#p117029
		ComObjConnect(this.display, this.EventHandler)    ;; Connect ActiveX control events to the associated class object.
		logger.info("ActiveX control connected to event handler.", "UserInterface.__New")
		
		this.barPosition := barPosition
		this.barHeight   := barHeight
		this.fitTables()
    this.display.Navigate("javascript:document.getElementById('bug-n-log-icon').click()")
    
    Gui, Show, % "NoActivate x" . this.x . " y" . this.y . " w" . this.w . " h" . this.h, % "bug.n Display " . this.index
    WinSet, Bottom, , % "ahk_id " . this.winId
    WinSet, Transparent, % transparency, % "ahk_id " . this.winId
    logger.info("Web browser window #" . index . " created.", "UserInterface.__New")
  }
  
  __Delete() {
    Global logger
    
    i := this.index
    Gui, %i%: Destroy
    logger.warning("Web browser window #" . i . " deleted.", "UserInterface.__Delete")
  }
  
  class EventHandler {
    BeforeNavigate(disp, url) {
      disp.Stop()
    }
    BeforeNavigate2(disp, url) {
      Global logger, mgr
      
      disp.Stop()
      If (i := InStr(url, "#")) {
        urlPath := SubStr(url, i + 1)
        mgr.onUifaceAppCall(urlPath)
        logger.info("App function called with argument " . urlPath . ".", "UserInterface.EventHandler.BeforeNavigate2")
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
    GuiControl, %i%: Move, this.display, w%A_GuiWidth% h%A_GuiHeight%
    logger.info("ActiveX control in GUI #" . i . " resized to width " . A_GuiWidth . " and height " . A_GuiHeight . ".", "UserInterface.resizeGUIControls")
  }
  
  ;; Functions controlling the DOM of the loaded HTML file in this.display (ActiveX control).
  ;; Changing elements by id.
  
  barHeight[] {
    get {
      Return, this.display.document.getElementById("bug-n-bar").clientHeight
    }
    
    set {
      className := this.display.document.getElementById("bug-n-bar").className
      this.display.document.getElementById("bug-n-bar").className := RegExReplace(className, "w3-(tiny|small|medium|large|xlarge|xxlarge|xxxlarge|jumbo)", "w3-" . value)
      h := this.display.document.getElementById("bug-n-bar").clientHeight
      this.display.document.getElementsByClassName("w3-main")[0].style.marginTop := (this.barPosition == "top" ? h : 0) . "px"
      Return, h
    }
  }
  
  barPosition[] {
    get {
      RegExMatch(this.display.document.getElementById("bug-n-bar").className, "O)w3-(bottom|top)", className)
      Return, className[1]
    }
    
    set {
      className := this.display.document.getElementById("bug-n-bar").className
      this.display.document.getElementById("bug-n-bar").className := RegExReplace(className, "w3-(bottom|top)", "w3-" . value)
      Return, value
    }
  }
  
  fitTables() {
    Global logger
    
    iconHeight := this.display.document.getElementById("bug-n-icon-row").offsetHeight
    For i, subId in ["monitors", "desktops", "windows", "messages", "work-areas", "views", "log"] {
      view := this.display.document.getElementById("bug-n-" . subId . "-view")
      h3Height := view.getElementsByTagName("h3")[0].offsetHeight
      inputHeight := 0
      If (subId == "windows" || subId == "messages" || subId == "log") {
        inputHeight := view.getElementsByTagName("input")[0].offsetHeight
      }
      tableHeight := this.h - this.barHeight - iconHeight - h3Height - inputHeight - 38
      view.getElementsByTagName("div")[0].style.height := tableHeight . "px"
      logger.debug("Table fitted to (" . this.h . " - " . this.barHeight . " - " . iconHeight . " - " . h3Height . " - " . inputHeight . " - 32) = " . tableHeight, "UserInterface.fitTables")
    }
  }
  
  insertTableRows(subId, data, position := "beforeend") {
    ;; possible position values: "afterbegin" or "beforeend".
    keys := subKeys := []
    If (subId == "desktops") {
      keys := ["index", "GUID"]
    } Else If (subID == "log") {
      keys := ["timestamp", "level", "src", "msg"]
    } Else If (subId == "messages") {
      keys := ["timestamp", "msg", "msgNum", "winId"]
      subKeys := ["winClass", "winTitle", "winPName", "winStyle", "winExStyle", "winMinMax", "winX", "winY", "winW", "winH"]
    } Else If (subId == "monitors") {
      keys := ["index", "name", "x", "y", "w", "h"]
    } Else If (subId == "views") {
      keys := ["index", "name", "workArea", "desktop", "x", "y", "w", "h", "layout"]
    } Else If (subId == "windows") {
      keys := ["id", "class", "title", "pName", "style", "exStyle", "minMax", "x", "y", "w", "h", "view"]
    } Else If (subId == "work-areas") {
      keys := ["index", "x", "y", "w", "h"]
    }
    For i, item in data {
      html := "<tr>"
      For j, key in keys {
        If (subId == "messages" && key == "winId") {
          html .= "<td class='w3-tooltip'>" . item[key]
          html .= "<table class='w3-text' style='position:absolute;'><tr><th>Class</th><th>Title</th><th>Process Name</th><th>Style</th><th>ExStyle</th><th>Min/ Max</th><th>x-Coordinate</th><th>y-Coordinate</th><th>Width</th><th>Height</th></tr><tr>"
          For k, subKey in subKeys {
            html .= "<td>" . item[subKey] . "</td>"
          }
          html .= "</tr></table></td>"
        } Else {
          html .= "<td>" . item[key] . "</td>"
        }
      }
      html .= "</tr>"
      this.display.document.getElementById("bug-n-" . subId . "-view").getElementsByTagName("tbody")[0].insertAdjacentHTML(position, html)
    }
    count := this.display.document.getElementById("bug-n-" . subId . "-icon").getElementsByTagName("div")[1].innerHTML
    this.setIconCounter(subId, count + data.Length())
  }
  
  setCurrentIndicator(subId, value) {
    If (subId == "views") {
      
    } Else {
      this.display.document.getElementById("bug-n-" . subId . "-indicator").getElementsByTagName("span")[0].innerHTML := value
    }
  }
  
  setIconCounter(subId, value) {
    this.display.document.getElementById("bug-n-" . subId . "-icon").getElementsByTagName("div")[1].innerHTML := value
  }
  
  setSystemInformation(data) {
    For key, value in data {
      If (value == "") {
        this.display.document.getElementById("bug-n-system-" . key).style.display := "none"
      } Else {
        If (key == "network" || key == "storage") {
          If (key == "network") {
            text := [Format("{1:-3.1f}", value[1].received.value) . value[1].received.unit
                   , Format("{1:-3.1f}", value[1].sent.value) . value[1].sent.unit]
          } Else If (key == "storage") {
            text := [Format("{1:-3.1f}", value[1].write.value) . value[1].write.unit
                   , Format("{1:-3.1f}", value[1].read.value) . value[1].read.unit]
          }
          barItemText := this.display.document.getElementById("bug-n-system-" . key).getElementsByTagName("span")[0]
          barItemText.innerHTML := text[1]
          barItemText := this.display.document.getElementById("bug-n-system-" . key).getElementsByTagName("span")[1]
          barItemText.innerHTML := text[2]
        } Else {
          class := ""
          icon  := ""
          text  := "???%"
          If (key == "battery") {
            If (value.acLineStatus == "on") {
              icon := "plug"
            } Else If (value.level.value < 25) {
              icon := "battery-empty"
              If (value.level.value < 10) {
                class := "alert"
              }
            } Else If (value.level.value < 50) {
              icon := "battery-quarter"
            } Else If (value.level.value < 75) {
              icon := "battery-half"
            } Else If (value.level.value < 100) {
              icon := "battery-three-quarters"
            } Else {
              icon := "battery-full"
            }
            text := value.level.value . value.level.unit
          } Else If (key == "volume") {
            If (value.muteStatus == "On") {
              icon := "volume-mute"
            } Else If (value.level.value < 1) {
              icon := "volume-off"
            } Else If (value.level.value < 66) {
              icon := "volume-down"
            } Else {
              icon := "volume-up"
            }
            text := value.level.value . value.level.unit
          } Else If (key == "date" || key == "time") {
            text := value
          } Else {
            text := value.value . value.unit
          }
          If (icon != "") {
            barItemIcon := this.display.document.getElementById("bug-n-system-" . key).getElementsByTagName("i")[0]
            barItemIcon.className := RegExReplace(barItemIcon.className, "fa-(.+)", "fa-" . icon)
          }
          barItemText := this.display.document.getElementById("bug-n-system-" . key).getElementsByTagName("span")[0]
          barItemText.innerHTML := text
          If (class != "") {
            barItemText.className := RegExReplace(barItemText.className, "bug-n-(.+)", "bug-n-" . class)
          }
        }
      }
    }
  }
  
  ;; End of DOM related functions.
  
  ;; Set the tray menu only once when bug.n starts.
  ;; This function should not be called froman instance.
  setTrayMenu(name, logo) {
    ;; The name will be shown in the tooltip, the logo as the tray icon.
    Global logger
    
    Menu, Tray, Tip, % name
    If (A_IsCompiled) {
      Menu, Tray, Icon, %A_ScriptFullPath%, -159
    } Else If FileExist(logo) {
      Menu, Tray, Icon, % logo
    } Else {
      logger.warning("Icon file <mark>" . logo . "</mark> not found.", "UserInterface.__New")
    }
    Menu, Tray, MainWindow
    logger.info("Tray menu set with tooltip, icon and main window.", "UserInterface.setTrayMenu")
  }
}
