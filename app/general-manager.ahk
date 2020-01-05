/*
:title:     bug.n/general-manager
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class GeneralManager {
  __New() {
    this.desktops := []
    this.desktopA := []
    this.primaryUserInterface := ""
    this.windows := {}
    
    ;; Initialize monitors.
    this.mMgr := New MonitorManager(ObjBindMethod(this, "_onDisplayChange"))
    this.detectTaskbars()
    
    ;; Initialize desktops and work areas.
    this.dMgr := New DesktopManager(ObjBindMethod(this, "_onTaskbarCreated"), ObjBindMethod(this, "_onDesktopChange"))
    A := this.dMgr.getCurrentDesktopIndex()
    this._init("desktops")
    this.desktopA.push(this.desktops[A])
    this.dMgr.switchToDesktop(A)
    
    this.detectWindows()
    For i, item in this.desktopA[1].workAreas {
      item.arrange()
    }
    
    this._init("user interfaces")
    
    this._init("shell events")
  }
  
  __Delete() {
    Global app
    this.dMgr := ""
    DllCall("DeregisterShellHookWindow", "UInt", app.windowId)
  }
  
  _init(part) {
    Global app, cfg, logger
    
    
    ;; Desktops.
    If (part == "desktops") {
      m := 0
      n := this.dMgr.getDesktopCount()
      this.maximumWorkAreaCount := this.mMgr.monitors.Length()
      For i, item in cfg.desktops {
        this.desktops[i] := New Desktop(i, item.label)
        If (i > n) {
          this.dMgr.createDesktop()
          m += 1
        }
        If (item.HasKey("workAreas")) {
          For j, wa in item.workAreas {
            this.desktops[i].workAreas.push(New WorkArea(i, j, wa.rect))
            this.desktops[i].workAreas[j].isPrimary := wa.isPrimary
            If (wa.isPrimary) {
              this.desktops[i].primaryWorkArea := this.desktops[i].workAreas[j]
            }
            this.desktops[i].workAreas[j].showBar := wa.showBar
            this.desktops[i].workAreas[j].layoutA := [this.desktops[i].workAreas[j].layouts[wa.layoutA[1]], this.desktops[i].workAreas[j].layouts[wa.layoutA[2]]]
          }
          this.maximumWorkAreaCount := item.workAreas.Length() > this.maximumWorkAreaCount ? item.workAreas.Length() : this.maximumWorkAreaCount
        } Else {
          ;; If no custom work areas are defined, they are derived from the detected monitors per desktop.
          For j, item in this.mMgr.monitors {
            this.desktops[i].workAreas.push(New WorkArea(i, j, item.monitorWorkArea))
          }
          this.desktops[i].workAreas[this.mMgr.primaryMonitor].isPrimary := True
          this.desktops[i].primaryWorkArea := this.desktops[i].workAreas[this.mMgr.primaryMonitor]
        }
        this.desktops[i].workAreaA.push(this.desktops[i].primaryWorkArea)
      }
      logger.info(m . " additional desktop" . (n == 1 ? "" : "s") . " created.", "GeneralManager._init")
      
      
    ;; Shell Events.
    } Else If (part == "shell events") {
      this.shellEventCache := []
      DllCall("RegisterShellHookWindow", "UInt", app.windowId)
      msgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
      OnMessage(msgNum, ObjBindMethod(this, "_onShellEvent"))
      this.shellEvents := { 1: "WINDOWCREATED"
                      ,     2: "WINDOWDESTROYED"
                      ,     4: "WINDOWACTIVATED"
                      ,     6: "REDRAW"
                      ,    10: "ENDTASK"
                      ,    13: "WINDOWREPLACED"
                      ,    14: "WINDOWREPLACING"
                      ,    16: "MONITORCHANGED"
                      , 32772: "RUDEAPPACTIVATED"
                      , 32774: "FLASH"}
      logger.info("ShellHook registered to window with id <mark>" . app.windowId . "</mark>.", "GeneralManager._init")
      ;; SKAN: How to Hook on to Shell to receive its messages? (http://www.autohotkey.com/forum/viewtopic.php?p=123323#123323)
      
      
    ;; User Interfaces
    } Else If (part == "user interfaces") {
      For i, item in cfg.userInterfaces {
        name := item.name
        this.uifaces[i] := New %name%(i)
        this.uifaces[i]["appCallFuncObject"] := ObjBindMethod(this, "_onAppCall")
        For key, value in this.uifaces[i] {
          If (item.HasKey(key)) {
            this.uifaces[i][key] := item[key]
          }
        }
        this.uifaces[i]._init()
      }
      
      wa := this.desktopA[1].primaryWorkArea
      Loop, % this.maximumWorkAreaCount {
        k := this.uifaces.Length() + 1
        this.uifaces[k] := New WorkAreaUserInterface(k)
        this.uifaces[k]["appCallFuncObject"] := ObjBindMethod(this, "_onAppCall")
        
        If (A_Index == 1) {
          For key, index in cfg.defaultSystemStatusBarItems {
            this.items.bar[key] := index
          }
          this.uifaces[k].includeAppIface := True
          this.primaryUserInterface := this.uifaces[k]
        } Else {
          this.uifaces[k].items.content := {"work-areas": "06", "windows": "07", "layouts": "08"}
          this.uifaces[k].updateIntervals := {}
        }
        
        this.uifaces[k].x := wa.x
        this.uifaces[k].y := wa.y
        this.uifaces[k].w := wa.w
        this.uifaces[k].h := wa.h
        
        this.uifaces[k]._init()
        this.uifaces[k].fitContent(56)
        
        i := A_Index
        For j, item in this.desktops {
          If (i <= item.workAreas.Length()) {
            item.workAreas[i].uiface := this.uifaces[k]
            logger.debug("User interface " . k . " associated with work area " . i . " on desktop " . j . ".", "GeneralManager._init")
          }
        }
      }
      
      ;; "<tr><th>Index</th><th>Label</th></tr>"
      data := []
      For i, item in this.desktops {
        data.push([item.index, item.label])
      }
      this.primaryUserInterface.insertContentItems(this.primaryUserInterface.items.content["desktops"], data)
      
      ;; "<tr><th>Index</th><th>Name</th><th>x-Coordinate</th><th>y-Coordinate</th><th>Width</th><th>Height</th></tr>"
      data := []
      For i, item in this.mMgr.monitors {
        data.push([item.index, item.name, item.x, item.y, item.w, item.h])
      }
      this.primaryUserInterface.insertContentItems(this.primaryUserInterface.items.content["monitors"], data)
      
      ;; "<tr><th>Desktop</th><th>Index</th><th>x-Coordinate</th><th>y-Coordinate</th><th>Width</th><th>Height</th></tr>"
      data := []
      For i, item in this.desktops {
        For j, wa in item.workAreas {
          data.push([item.label, wa.index, wa.x, wa.y, wa.w, wa.h])
        }
      }
      this.primaryUserInterface.insertContentItems(this.primaryUserInterface.items.content["work-areas"], data)
      
      data := []
      For id, item in this.windows {
        data.push(this.primaryUserInterface.getContentItem("windows", item))
      }
      this.primaryUserInterface.insertContentItems(this.primaryUserInterface.items.content["windows"], data)
      
      this.updateBarItems(True)
    }
  }
  
  _onAppCall(uri) {
  }
  
  _onDesktopChange(wParam, lParam, msg, winId) {
    Global cfg, logger
    
    ;; Detect changes:
    ;; current monitor/ desktop/ window, different windows on desktop
    Sleep, % cfg.onMessageDelay.desktopChange
    A := this.dMgr.getCurrentDesktopIndex()
    logger.info("Desktop changed from <i>" . this.desktopA[2].index . "</i> to <b>" . A . "</b>.", "GeneralManager._onDesktopChange")
    desktopA := updateActive(this.desktopA, this.desktops[A])
      
    changes := this.detectWindows()
    data := []
    For i, wnd in changes.windows {
      data.push(this.primaryUserInterface.getContentItem("windows", wnd))
    }
    this.primaryUserInterface.insertContentItems(this.primaryUserInterface.items.content["windows"], data)
    For id, wa in changes.workAreas {
      wa.arrange()
    }
    desktopA.workAreaA[1].activate()
    this.updateBarItems()
  }
  
  _onDisplayChange(wParam, lParam) {
    ;; Detect changes:
    ;; monitor added/ removed, position/ resolution/ scaling changed
  }
  
  _onShellEvent(wParam, lParam) {
    Global cfg, logger
    
    If (this.shellEvents.HasKey(wParam)) {
      ;; Detect changes:
      ;; current monitor/ desktop/ window, window opened/ closed/ moved
      Sleep, % cfg.onMessageDelay.shellEvent
      
      winId := Format("0x{:x}", lParam)
      logger.debug("Shell message received with message number '" . wParam . "' and window id '" . winId . "'.", "GeneralManager._onShellEvent")
      WinGetClass, winClass, % "ahk_id " . winId
      WinGetTitle, winTitle, % "ahk_id " . winId
      data := {timestamp: logger.getTimestamp(), msg: this.shellEvents[wParam], num: wParam, winId: winId, winClass: winClass, winTitle: winTitle}
      this.shellEventCache.push(this.primaryUserInterface.getContentItem("messages", data))
      
      changes := this.detectWindows()
      data := []
      For i, wnd in changes.windows {
        data.push(this.primaryUserInterface.getContentItem("windows", wnd))
      }
      this.primaryUserInterface.insertContentItems(this.primaryUserInterface.items.content["windows"], data)
      For id, wa in changes.workAreas {
        wa.arrange()
      }
      this.updateBarItems()
    }
  }
  
  _onTaskbarCreated(wParam, lParam, msg, winId) {
    Global logger
    
    ;; Restart the virtual desktop accessor, when Explorer.exe crashes or restarts (e.g. when coming from a fullscreen game).
    result := this.dMgr.restartVirtualDesktopAccessor()
    If (result > 0) {
      logger.error("Restarting <i>virtual desktop accessor</i> after a crash or restart of Explorer.exe failed.", "GeneralManager._onTaskbarCreated")
    } Else {
      logger.warning("<i>virtual desktop accessor</i> restarted due to a crash or restart of Explorer.exe.", "GeneralManager._onTaskbarCreated")
    }
  }
  
  activateWindowAtIndex(winId := 0, index := 0, delta := 0, matchFloating := False) {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    wnd := this.getWindow(winId)
    desktopA.workAreaA[1].activateWindowAtIndex(wnd, index, delta, matchFloating)
  }
  
  activateWindowsTaskbar() {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    For i, item in this.mMgr.monitors {
      If (item.match(desktopA.workAreaA[1])) {
        If (IsObject(item.trayWnd)) {
          item.trayWnd.runCommand("activate")
        }
        Break
      }
    }
  }
  
  applyWindowManagementRules(wnd) {
    Global cfg
    
    For i, rule in cfg.windowManagementRules {
      propertiesMatched := True
      If (rule.HasKey("windowProperties")) {
        For key, value in rule.windowProperties {
          If (key == "desktop") {
            propertiesMatched := (this.dMgr.getWindowDesktopIndex(wnd.id) == value) && propertiesMatched
          } Else {
            propertiesMatched := (RegExMatch(wnd[key], value) > 0) && propertiesMatched
          }
        }
      }
      testsPassed := True
      If (rule.HasKey("tests")) {
        For j, test in rule.tests {
          funcObject := ObjBindMethod(test.object, test.method, test.parameters)
          testsPassed := %funcObject%() && testsPassed
        }
      }
      
      If (propertiesMatched && testsPassed) {
        If (rule.HasKey("commands")) {
          For j, command in rule.commands {
            wnd.runCommand(command)
          }
        }
        If (rule.HasKey("functions")) {
          ;; `setWindowWorkArea`, `setWindowFloating`, `goToDesktop`, `switchToWorkArea` and `switchToLayout`
          For function, value in rule.functions {
            If (InStr(function, "Window") > 0) {
              funcObject := ObjBindMethod(this, function, wnd)
            } Else If (function == "goToDesktop") {
              funcObject := ObjBindMethod(this.dMgr, function)
            } Else {
              funcObject := ObjBindMethod(this, function)
            }
            %funcObject%(value)
          }
        }
        If (rule.HasKey("break") && rule.break) {
          Break
        }
      }
    }
  }
  
  detectTaskbars() {
    SetTitleMatchMode, RegEx
    WinGet, winId_, List, ahk_class Shell_.*TrayWnd
    SetTitleMatchMode, 3
    Loop, % winId_ {
      winId := Format("0x{:x}", winId_%A_Index%)
      wnd := this.getWindow(winId)
      For i, item in this.mMgr.monitors {
        If (item.match(wnd, False, True)) {
          item.trayWnd := wnd
          Break
        }
      }
    }
  }
  
  detectWindows() {
    Global logger
    
    changes := {windows: [], workAreas: {}}
    windows := {}
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    
    ;; Windows currently found.
    WinGet, winId_, List,,,
    Loop, % winId_ {
      winId := Format("0x{:x}", winId_%A_Index%)
      If (!this.windows.HasKey(winId)) {
        ;; Unknown/ new window. Apply rules initializing the window!
        wnd := this.getWindow(winId)
        wnd.desktop := this.dMgr.getWindowDesktopIndex(wnd.id)
        If (this.dMgr.getWindowDesktopIndex(wnd.id) == desktopA.index) {
          windows[wnd.id] := wnd
        }
        this.applyWindowManagementRules(wnd)
        changes.windows.push(wnd)
        If (wnd.workArea.dIndex == desktopA.index && !wnd.isFloating) {
          changes.workAreas[wnd.workArea.id] := wnd.workArea
        }
      } Else {
        ;; Known window. What happened?
        wnd := this.getWindow(winId)
        If (wnd.workArea != "") {
        ;; Else: Ignore the window.
          If (this.dMgr.getWindowDesktopIndex(wnd.id) == desktopA.index) {
            ;; Only work on the active/ visible desktop.
            windows[wnd.id] := wnd
            
            wa := desktopA.getWorkArea(, wnd)
            logger.debug("Window from work area <i>" . wnd.workArea.id . "</i> found on work area <b>" . wa.id . "</b>.", "GeneralManager.detectWindows")
            If (wa != wnd.workArea) {
              ;; The window moved between work areas or desktops.
              wnd.workArea.removeWindow(wnd)
              wa.addWindow(wnd)
              If (!wnd.isFloating) {
                ;; Mark work areas for rearrangement.
                If (wnd.workArea.dIndex == desktopA.index) {
                  changes.workAreas[wnd.workArea.id] := wnd.workArea
                }
                changes.workAreas[wa.id] := wa
              }
              wnd.workArea := wa
            }
          }
        }
      }
    }
    
    ;; Windows, which should have been found.
    For i, wa in desktopA.workAreas {
      For j, wnd in wa.windows {
        If (!windows.HasKey(wnd.id)) {
          ;; Window was removed from work area.
          DetectHiddenWindows, On
          If (!WinExist(wnd.id)) {
            ;; Window was removed entirely.
            If (IsObject(wnd.workArea)) {
              wnd.workArea.removeWindow(wnd)
              If (wnd.workArea.dIndex == desktopA.index) {
                changes.workAreas[wnd.workArea.id] := wnd.workArea
              }
              this.primaryUserInterface.removeContentItems(this.primaryUserInterface.items.content["windows"], [wnd.id])
              wnd.workArea := ""
              this.windows[wnd.id] := ""
            }
          }
          ;; Else: The move between desktops will be delt with later.
          DetectHiddenWindows, Off
        }
      }
    }
    
    wnd := this.getWindow()
    If (IsObject(wnd.workArea)) {
      workAreaA := updateActive(this.desktopA[1].workAreaA, wnd.workArea)
      windowA := updateActive(this.desktopA[1].workAreaA[1].windowA, wnd)
    }
    
    Return, changes
  }
  
  getWindow(winId := 0) {
    winId := Format("0x{:x}", (winId == 0 ? WinExist("A") : winId))
    wnd := ""
    If (this.windows.HasKey(winId)) {
      wnd := this.windows[winId]
      wnd.update()
    } Else {
      wnd := New Window(winId)
      this.windows[wnd.id] := wnd
    }
    Return, wnd
  }
  
  moveWindowToDesktop(winId := 0, index := 0, delta := 0, loop := False) {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    wnd := this.getWindow(winId)
    If (delta != 0) {
      index := index == 0 ? desktopA.index : index
      index := getIndex(index, delta, this.desktops.Length(), loop)
    }
    If (index == 0 || index != desktopA.index) {
      this.setWindowDesktop(wnd, index)
    }
  }
  
  moveWindowToPosition(winId := 0, index := 0, delta := 0) {
    ;; matchFloating := False
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    wnd := this.getWindow(winId)
    If (IsObject(wnd.workArea)) {
      wa := wnd.workArea
    } Else {
      wa := desktopA.workAreaA[1]
      wnd.workArea := wa
      wa.addWindow(wnd)
    }
    wnd.isFloating := False
    wa.moveWindowToPosition(wnd, index, delta)
    wa.arrange()
  }
  
  moveWindowToWorkArea(winId := 0, index := 0, delta := 0, loop := False) {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    wnd := this.getWindow(winId)
    index := index == 0 ? desktopA.workAreaA[1].index : index
    index := getIndex(index, delta, desktopA.workAreas.Length(), loop)
    this.setWindowWorkArea(wnd, desktopA.index . "-" . index)
    If (!wnd.isFloating) {
      desktopA.workAreas[index].arrange()
    }
  }
  
  setLayoutProperty(key, value := 0, delta := 0) {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    workAreaA := updateActive(desktopA.workAreaA, desktopA.getWorkArea(, this.getWindow()))
    workAreaA.setLayoutProperty(key, value, delta)
    workAreaA.arrange()
  }
  
  setWindowDesktop(wnd, index) {
    If (index == 0) {
      this.dMgr.pinWindow(wnd.id)
    } Else If (index > 0 && index <= this.desktops.Length()) {
      If (this.dMgr.isPinnedWindow(wnd.id) == 1) {
        this.dMgr.unPinWindow(wnd.id)
      }
      this.dMgr.moveWindowToDesktop(wnd.id, index)
    }
  }
  
  setWindowFloating(wnd, value) {
    wnd.isFloating := value
  }
  
  setWindowWorkArea(wnd, id) {
    Global logger
    
    k := InStr(id, "-")
    If (k == 0) {
      i := this.dMgr.getCurrentDesktopIndex()
      j := id
    } Else {
      i := SubStr(id, 1, k - 1)
      j := SubStr(id, k + 1)
    }
    If (i > 0 && i <= this.desktops.Length() && j > 0 && j <= this.desktops[i].workAreas.Length()) {
      this.setWindowDesktop(wnd, i)
      wa := this.desktops[i].workAreas[j]
      If (IsObject(wnd.workArea)) {
        wnd.workArea.removeWindow(wnd)
        If (!wnd.isFloating && wnd.workArea.index != wa.index) {
          wnd.workArea.arrange()
        }
      }
      wnd.workArea := wa
      wa.addWindow(wnd)
    } Else {
      logger.error("Work area at index <mark>" . j . "</mark> on desktop <mark>" . i . "</mark> not found.", "GeneralManager.setWindowWorkArea")
    }
  }
  
  showWindowInformation(winId := 0) {
    Global app
    
    wnd := this.getWindow(winId)
    MsgBox, 3, % app.name . ": Window Information", % wnd.information . "`n`nCopy window information to clipboard?"
    IfMsgBox Yes
      Clipboard := wnd.information
  }
  
  switchToDesktop(index := 0, delta := 0, loop := False) {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    If (index == 0) {
      index := desktopA.index
    } Else If (index == -1) {
      index := this.desktopA[2].index
    }
    index := getIndex(index, delta, this.desktops.Length(), loop)
    If (index != desktopA.index) {
      this.dMgr.goToDesktop(index)
      desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
      desktopA.switchToWorkArea()
    }
  }
  
  switchToLayout(index := 0, delta := 0) {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    desktopA.workAreaA[1].switchToLayout(index, delta)
    desktopA.workAreaA[1].arrange()
    this.updateBarItems()
  }
  
  switchToWorkArea(index := 0, delta := 0, loop := False) {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    desktopA.switchToWorkArea(index, delta, loop)
  }
  
  toggleUserInterfaceBar() {
    desktopA := updateActive(this.desktopA, this.desktops[this.dMgr.getCurrentDesktopIndex()])
    desktopA.workAreaA[1].showBar := !desktopA.workAreaA[1].showBar
    desktopA.workAreaA[1].arrange()
  }
  
  toggleWindowHasCaption(winId := 0) {
    wnd := this.getWindow(winId)
    wnd.runCommand("toggleCaption")
    If (IsObject(wnd.workArea) && !wnd.isFloating) {
      wnd.workArea.arrange()
    }
  }
  
  toggleWindowIsFloating(winId := 0) {
    wnd := this.getWindow(winId)
    this.setWindowFloating(wnd, !wnd.isFloating)
    If (IsObject(wnd.workArea)) {
      wnd.workArea.arrange()
    }
    this.updateBarItems()
  }
  
  updateBarItems(init := False) {
    Global cfg
    
    ;; {"desktops": "01", "layout": "02", "monitor": "03", "window": "04"}
    winTitle := ""
    wa := this.desktopA[1].workAreaA[1]
    If (IsObject(wa.windowA[1])) {
      wa.windowA[1].getProperties()
      winTitle := (wa.windowA[1].isFloating ? "~ " : "") . wa.windowA[1].title
    }
    indices := []
    values := []
    classNames := []
    iconNames := []
    If (cfg.showAllDesktops) {
      ;; Desktops
      For i, item in this.desktops {
        indices.push((i < 10 ? "0" : "") . i)
        values.push(item.label)
        classNames.push(item.index == this.desktopA[1].index ? ["", "app-bar-item-active"] : ["app-bar-item-active", ""])
        iconNames.push("")
      }
      iconNames[1] := init ? ["", ""] : ""
      ;; Work Area
      indices.push((i < 10 ? "0" : "") . indices.Length() + 1)
      values.push(wa.index)
      classNames.push("")
      iconNames.push(init ? ["", "object-group"] : "")
      ;; Layout
      indices.push((i < 10 ? "0" : "") . indices.Length() + 1)
      values.push(wa.layoutA[1].symbol)
      classNames.push(init ? ["", "app-bar-item-active"] : "")
      iconNames.push("")
      ;; Window
      indices.push((i < 10 ? "0" : "") . indices.Length() + 1)
      values.push(winTitle)
      classNames.push("")
      iconNames.push(init ? ["", "window-restore"] : "")
    } Else {
      indices := ["01", "02", "03", "04"]
      values := [this.desktopA[1].label, wa.layoutA[1].symbol, wa.index, winTitle]
      classNames := init ? ["", ["", "app-bar-item-active"], "", ""] : ["", "", "", ""]
      iconNames := init ? [["", "layer-group"], "", ["", "desktop"], ["", "window-restore"]] : ["", "", "", ""]
    }
    this.primaryUserInterface.setBarItems(indices, values, classNames, iconNames)
  }
}

class Desktop {
  __New(index, label) {
    this.index := index
    this.label := label
    this.workAreas := []
    this.workAreaA := []
  }
  
  getWorkArea(index := 0, rect := "") {
    wa := this.workAreaA[1]
    If (index > 0 && index <= this.workAreas.Length()) {
      wa := this.workAreas[index]
    } Else If (IsObject(rect)) {
      For i, item in this.workAreas {
        If (item.match(rect, False, True)) {
          wa := item
          Break
        }
      }
    }
    Return, wa
  }
  
  switchToWorkArea(index, delta, loop) {
    index := index == 0 ? this.workAreaA[1].index : index
    index := getIndex(index, delta, this.workAreas.Length(), loop)
    If (index != this.workAreaA[1].index || delta == 0) {
      workAreaA := updateActive(this.workAreaA, this.workAreas[index])
      workAreaA.activate()
    }
  }
}

class Rectangle {
  ;; A rectangle must have the following properties: x (x-coordinate), y (y-coordinate), w (width), h (height)
  __New(xCoordinate, yCoordinate, width := 0, height := 0) {
    this.x := xCoordinate
    this.y := yCoordinate
    this.w := width
    this.h := height
  }
  
  match(rect, dimensions := False, exhaustively := False, variation := 2) {
    ;; If `exactness == 0`, this function tests if the center of `rect` is inside `Rectangle`,
    ;; else it tests if `rect` has the position and size as `Rectangle` in the limits of `exactness`.
    ;; `exactness` should therefor be equal or greater than 0.
    Global logger
    
    result := False
    If (dimensions) {
      result := Abs(this.x - rect.x) < variation && Abs(this.y - rect.y) < variation && Abs(this.w - rect.w) < variation && Abs(this.h - rect.h) < variation
    } Else {
      coordinates := [[rect.x + rect.w / 2, rect.y + rect.h / 2]]
      If (exhaustively) {
        coordinates.push({x: rect.x + variation,          y: rect.y + variation})
        coordinates.push({x: rect.x + rect.w - variation, y: rect.y + rect.h - variation})
        coordinates.push({x: rect.x + variation,          y: rect.y + rect.h - variation})
        coordinates.push({x: rect.x + rect.w - variation, y: rect.y + variation})
      }
      For i, coord in coordinates {
        If (result := coord.x >= this.x && coord.y >= this.y && coord.x <= this.x + this.w && coord.y <= this.y + this.h) {
          logger.debug("Rectangle " . (this.HasKey("id") ? "with id " . this.id . " " : "") . "(" . this.x . ", " . this.y . ", " . this.w . ", " . this.h
                                                       . ") matches coordinates (" . i . ": " . coord.x . ", " . coord.y . ", " . coord.w . ", " . coord.h . ")"
                                                       . (this.HasKey("id") ? " from " . this.id : "") . ".", "Rectangle.match")
          Break
        }
      }
    }
    Return, result
  }
}

getIndex(curIndex, delta, maxIndex, loop := True) {
  ;; Return a valid index, i.e. between 1 and maxIndex,
  ;; either not exceeding the lower or upper bound, or looping if `loop := True`,
  ;; i.e. resetting it to the lower or upper bound respectively by delta.
  
  index := curIndex
  
  If (loop) {
    ;; upper bound = n, lower bound = 1
    lowerBoundBasedIndex := Mod(index - 1 + delta, maxIndex)
    If (lowerBoundBasedIndex < 0) {
      lowerBoundBasedIndex += maxIndex
    }
    index := 1 + lowerBoundBasedIndex
  } Else {
    index += delta
  }
  
  index := Min(Max(index, 1), maxIndex)
  
  Return, index
}

updateActive(ByRef array, item, count := 2) {
  If (array[1] != item) {
    array.InsertAt(1, item)
  }
  n := array.Length() - count
  Loop, % n {
    array.Pop()
  }
  Return, array[1]
}
