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
    Global Config_barTransparency, Config_maintenanceInterval, Config_readinBat, Config_readinCpu, Config_readinDate, Config_readinDateFormat, Config_readinDiskLoad, Config_readinInterval, Config_readinMemoryUsage, Config_readinNetworkLoad, Config_readinTime, Config_readinTimeFormat, Config_showBar
    
    this.uifaceTransparency     := Config_barTransparency                                 ;; possible values: "Off", 0-255
    this.barHeight              := "medium"                                               ;; possible values: "tiny", "small", "medium", "large", "xlarge", "xxlarge", "xxxlarge", "jumbo"
    this.showBar                := Config_showBar                                         ;; possible values: True, False
    this.showBatteryStatus      := Config_readinBat                                       ;; possible values: True, False
    this.showCpuUsage           := Config_readinCpu                                       ;; possible values: True, False
    this.showDate               := Config_readinDate ? Config_readinDateFormat : ""       ;; possible values: "", a quoted string as described in https://autohotkey.com/docs/commands/FormatTime.htm#Date_Formats_case_sensitive
    this.showMemoryUsage        := Config_readinMemoryUsage                               ;; possible values: True, False
    this.showNetworkUsage       := Config_readinNetworkLoad                               ;; possible values: "", an array of quoted network interface names
    this.showStorageUsage       := Config_readinDiskLoad ? [Config_readinDiskLoad] : ""   ;; possible values: "", an array of quoted physical drive names, e.g. ["PhysicalDrive0"]
    this.showTime               := Config_readinTime ? Config_readinTimeFormat : ""       ;; possible values: "", a quoted string as described in https://autohotkey.com/docs/commands/FormatTime.htm#Time_Formats_case_sensitive
    ;; show*                                    ;; possible values for hiding *: False, 0, ""
    this.logViewUpdateInterval  := Config_maintenanceInterval                             ;; possible values: "Off", 1-4294967295 (time in milliseconds)
    this.sysInfoUpdateInterval  := Config_readinInterval                                  ;; possible values: "Off", 1-4294967295 (time in milliseconds)
    
    this.rules := []
    
    ;; WINDOWCREATED
    this.rules[1] := []
    
    ;; WINDOWDESTROYED
    this.rules[2] := []
    
    ;; ACTIVATESHELLWINDOW  :=  3
    
    ;; WINDOWACTIVATED
    this.rules[4] := []
    
    ;; GETMINRECT           :=  5
    
    ;; REDRAW
    this.rules[6] := []
    
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
    
    ;; RUDEAPPACTIVATED
    this.rules[32772] := []
  }
}
