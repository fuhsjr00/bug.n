/*
:title:     bug.n/configuration
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Configuration {
  __New() {
    Global Config_barTransparency, Config_maintenanceInterval, Config_readinBat, Config_readinCpu, Config_readinDate, Config_readinDateFormat, Config_readinDiskLoad, Config_readinInterval, Config_readinMemoryUsage, Config_readinNetworkLoad, Config_readinTime, Config_readinTimeFormat, Config_readinVolume, Config_showBar, Config_showTaskbar, Config_verticalBarPos
    
    this.uifaceTransparency     := Config_barTransparency                                             ;; possible values: "Off", an integer between 0 and 255
    this.barHeight              := "medium"                                                           ;; possible values: "tiny", "small", "medium", "large", "xlarge", "xxlarge", "xxxlarge", "jumbo"
    this.barPosition            := Config_verticalBarPos == "tray" ? "top" : Config_verticalBarPos    ;; possible values: "bottom", "top"
    this.showBarDefault         := Config_showBar                                                     ;; possible values: True, False
    this.showBatteryStatus      := Config_readinBat                                                   ;; possible values: True, False
    this.showCpuUsage           := Config_readinCpu                                                   ;; possible values: True, False
    this.showDate               := Config_readinDate ? Config_readinDateFormat : ""                   ;; possible values: "", a quoted string as described in https://autohotkey.com/docs/commands/FormatTime.htm#Date_Formats_case_sensitive
    this.showMemoryUsage        := Config_readinMemoryUsage                                           ;; possible values: True, False
    this.showNetworkUsage       := Config_readinNetworkLoad ? [Config_readinNetworkLoad] : ""         ;; possible values: "", an array of quoted network interface names, e.g. ["AR9002WB"]
    this.showStorageUsage       := Config_readinDiskLoad                                              ;; possible values: True, False
    this.showTime               := Config_readinTime ? Config_readinTimeFormat : ""                   ;; possible values: "", a quoted string as described in https://autohotkey.com/docs/commands/FormatTime.htm#Time_Formats_case_sensitive
    this.showVolumeLevel        := Config_readinVolume                                                ;; possible values: True, False
    ;; this.show*                                                                                     ;; possible values for hiding *: False, 0, ""
    this.sysInfoUpdateInterval  := Config_readinInterval                                              ;; possible values: "Off", an integer between 1 and 4294967295 (time in milliseconds)
    this.logViewUpdateInterval  := Config_maintenanceInterval                                         ;; possible values: "Off", an integer between 1 and 4294967295 (time in milliseconds)
    
    this.showTaskbarDefault     := Config_showTaskbar                                                 ;; possible values: True, False
    
    this.rules := []
    
    ;; bug.n auto start
    this.rules[0] := [{conditions: ["get/True"], actions: ["set/userinterfaces/_/bar?window=_"]}]

    ;; WINDOWCREATED
    this.rules[1] := [{conditions: ["get/windows/_?isAppWindow=False"],             actions: ["break"]}
      , {conditions: ["get/windows/_?class=^ApplicationFrameWindow$&title=^$"],     actions: ["break"]}
      , {conditions: ["get/windows/_?class=^OperationStatusWindow$"],               actions: ["break"]}
      , {conditions: ["get/windows/_?class=^Progman$&title=^Program Manager$"],     actions: ["break"]}
      , {conditions: ["get/windows/_?class=^CabinetWClass$"],                       actions: ["set/windows?id=_&tile=True&title=On", "break"]}
      , {conditions: ["get/windows/_?class=^Chrome_WidgetWin_1$&isPopup=False"],    actions: ["set/windows?id=_&tile=True&title=On", "break"]}
      , {conditions: ["get/windows/_?class=^ApplicationFrameWindow$&title=Edge$"],  actions: ["set/windows?id=_&tile=True&title=On", "break"]}
      , {conditions: ["get/windows/_?class=^IEFrame$&title=Internet Explorer$"],    actions: ["set/windows?id=_&tile=True&title=On", "break"]}
      , {conditions: ["get/windows/_?class=^MozillaWindowClass$&title=Firefox$"],   actions: ["set/windows?id=_&tile=True&title=On", "break"]}
      , {conditions: ["get/windows/_?class=^ApplicationFrameWindow$&title=^(Calculator|Rechner)$"], actions: ["set/windows?id=_&tile=False&title=On", "break"]}
      , {conditions: ["get/windows/_?class=^QWidget$"],     actions: ["set/windows?id=_&tile=True&title=On&caption=Off", "break"]}
      , {conditions: ["get/windows/_?class=^SWT_Window0$"], actions: ["set/windows?id=_&tile=True&title=On&caption=Off", "break"]}
      , {conditions: ["get/windows/_?class=^Xming$"],       actions: ["set/windows?id=_&tile=True&title=On&caption=Off", "break"]}
      , {conditions: ["get/windows/_?isChild=True"],        actions: ["break"]}
      , {conditions: ["get/windows/_?isPopup=True"],        actions: ["break"]}
      , {conditions: ["get/windows/_?isAppWindows=True"],   actions: ["set/windows?id=_&tile=True&title=On&caption=Off", "break"]}]
    
    ;;
    this.rules[16] := this.rules[1]
    
    ;; WINDOWDESTROYED
    this.rules[2] := [{conditions: ["get/windows/_?isAppWindow=False"], actions: ["break"]}
      , {conditions: ["get/windows/_?isAppWindow=True"], actions: ["set/windows/_?"]}]
    
    ;; ACTIVATESHELLWINDOW  :=  3
    
    ;; WINDOWACTIVATED
    this.rules[4] := [{conditions: ["get/windows/_?isAppWindow=False"], actions: ["break"]}
      , {conditions: ["get/windows/_?isAppWindow=True"], actions: ["set/userinterfaces/_/bar?window=_"]}]
    
    ;; REDRAW
    this.rules[6] := this.rules[4]
    
    ;; RUDEAPPACTIVATED
    this.rules[32772] := this.rules[4]
    
    ;; GETMINRECT           :=  5
    
    ;; TASKMAN              :=  7
    ;; LANGUAGE             :=  8
    ;; SYSMENU              :=  9
    ;; ENDTASK              := 10
    ;; ACCESSIBILITYSTATE   := 11
    ;; APPCOMMAND           := 12
    ;; WINDOWREPLACED       := 13
    ;; WINDOWREPLACING      := 14
    ;; HIGHBIT              := 15?
    ;; FLASH                := 16?
    ;; RUDEAPPACTIVATED     := 17?
    
    ;; WM_DISPLAYCHANGE
    this.rules[126] := []
    
    ;; HIGHBIT              := 32768
    ;; FLASH                := 32774
  }
}
