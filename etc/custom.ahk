/*
:title:     bug.n/custom

This file should include (`#Include`)

* 1 of the modules\configuration\*.ahk files
* selected modules\layouts\*-layout.ahk files
* selected modules\user-interfaces\*-user-interface.ahk files

and any additional custom code (functions or modules). This file itself is included at 
the end of the main script and after the auto-execute section.
The class `Customizations` is instantiated after the class `Configuration` given by 
`#Include, %A_ScriptDir%\modules\configuration\*.ahk`, which allows overwriting 
configuration variables by putting them in `__New`. The function 
`Customizations._init` is called at the end of the auto-execute section, therewith 
commands can be executed after bug.n started by putting them in there.
*/

#Include, %A_ScriptDir%\modules\configuration\default.ahk

#Include, %A_ScriptDir%\modules\layouts\dwm-bottom-stack-layout.ahk
#Include, %A_ScriptDir%\modules\layouts\dwm-monocle-layout.ahk
#Include, %A_ScriptDir%\modules\layouts\dwm-tile-layout.ahk
#Include, %A_ScriptDir%\modules\layouts\floating-layout.ahk
#Include, %A_ScriptDir%\modules\layouts\i3wm-layout.ahk
;; If you remove one of the `layouts\*-layout.ahk` includes above and are using the `configuration\default`, 
;; you will also have to remove the corresponding item from `cfg.defaultLayouts` by redefining it below.

#Include, %A_ScriptDir%\modules\user-interfaces\tray-icon-user-interface.ahk
#Include, %A_ScriptDir%\modules\user-interfaces\app-user-interface.ahk
#Include, %A_ScriptDir%\modules\user-interfaces\system-status-bar-user-interface.ahk
;; If you remove one of the `user-interfaces\*-user-interface.ahk` includes above and are using the `configuration\default`,
;; you will also have to remove the corresponding item from `cfg.userInterfaces` by redefining it below.

;; Custom code.
class Customizations {
  __New() {
    Global cfg, logger
    ;; Overwrite cfg.* variables.
    
    cfg.defaultLayouts := [{symbol: "[M]", name: "DwmMonocleLayout"}
                         , {symbol: "[]=", name: "DwmTileLayout", mfact: 0.65, nmaster: 1}
                         , {symbol: "TTT", name: "DwmBottomStackLayout", mfact: 0.55, nmaster: 1}
                         , {symbol: "><>", name: "FloatingLayout"}]
    cfg.windowManagementRules := [{windowProperties: {desktop: 0}, break: True}   ;; Exclude hidden (?) windows.
      , {windowProperties: {class: "#32770", isPopup: True}, break: True}         ;; Exclude pop-up windows.
      , {windowProperties: {pName: "cloud-drive-ui\.exe"}, break: True}
      , {windowProperties: {pName: "KeePass\.exe"}, break: True}
      ;, {windowProperties: {class: "#32770", pName: "mstsc\.exe"}, break: True}
      ;, {windowProperties: {class: "#32770", pName: "Explorer\.EXE"}, break: True}
      ;; Above this line are exclusions, i.e. no `functions`, but `break: True`.
      , {functions: {setWindowFloating: False}}   ;; Set windows non-floating, if not already excluded.
      , {windowProperties: {pName: "firefox\.exe"}, functions: {setWindowWorkArea: "1-1"}, break: True}
      , {windowProperties: {pName: "Spotify\.exe"}, functions: {setWindowWorkArea: "1-1"}, break: True}
      , {windowProperties: {title: "D:\\development\\bug.n\\_git*"}, functions: {setWindowWorkArea: "2-1"}, break: True}
      , {functions: {setWindowWorkArea: "1"}}]    ;; Set windows to work area 1, if no `break: True` was set previously.
    If (A_ComputerName == "SILKIE") {
      cfg.networkInterfaces := ["AR9002WB"]
      cfg.defaultSystemStatusBarItems := {battery: 21, volume: 22, date: 23, time: 24}
      ; cfg.userInterfaces.push({name: "SystemStatusBarUserInterface", y: 30, w: 1366, h: 19, transparency: 192})
      ;cfg.showAllDesktops := False
      this.onMessageDelay := {shellEvent: 0, desktopChange: 150}
    } Else {
      cfg.defaultSystemStatusBarItems := {volume: 22, date: 23, time: 24}
    }
    
    cfg.desktops := [{label: "1",    workAreas: [{rect: New Rectangle(  0, 0, 1366, 768), isPrimary: True,  showBar: True, layoutA: [1, 2]}]}
                   , {label: "dev",  workAreas: [{rect: New Rectangle(  0, 0, 1366, 768), isPrimary: True,  showBar: True, layoutA: [1, 2]}]}
                   , {label: "test", workAreas: [{rect: New Rectangle(  0, 0,  688, 768), isPrimary: True,  showBar: True, layoutA: [1, 3]}
                                               , {rect: New Rectangle(688, 0,  688, 768), isPrimary: False, showBar: True, layoutA: [1, 3]}]}
                   , {label: "4",    workAreas: [{rect: New Rectangle(  0, 0, 1366, 768), isPrimary: True,  showBar: True, layoutA: [1, 2]}]}]
    
    logger.info("Custom configuration loaded.", "Customizations.__New")
  }
  
  _init() {
    Global mgr
    
    ;; Overwrite hotkeys.
    funcObject := ObjBindMethod(mgr, "switchToLayout", 1)
    Hotkey, #m, %funcObject%
    funcObject := ObjBindMethod(mgr, "switchToLayout", 2)
    Hotkey, #t, %funcObject%
  }
}
