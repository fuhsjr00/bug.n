# Feature planning

## GUI - Status Bar
```
horizontalBarPos   := "left"    * 8.2.0 horizontal bar position (left/ center/ right or relative in pixel)
verticalBarPos     := "top"     * 8.2.0 vertical bar position (top/ bottom/ tray)
barWidth           := "100%"    * 8.2.0 customizable bar width (in pixel or %)
singleRowBar       := True      * 8.2.0 customizable bar height (2 rows, spacious)
spaciousBar        := False
fontName           := "Lucida Console"
fontSize           :=           ... read from system settings
backColor_#{1,2,3} :=           ... read from system settings, #{1,2,3} for different states
foreColor_#{1,2,3} :=           ... read from system settings, allowing frames and progress bars
fontColor_#{1,2,3} :=           ... read from system settings, all colors set individually for view, layout, title, shebang, time, date, "any text", battery status, volume level
barTransparency    := "off"     *  10 -> 8.4.0 transparent bar
readinBat          := False
readinCpu          := False
readinDate         := True      ... with readinDateFormat  := "ddd, dd. MMM. yyyy"    * 9.0.0 customizable date and time format
readinTime         := True      ... with readinTimeFormat  := "HH:mm"
readinDiskLoad     := False
readinMemoryUsage  := False
readinNetworkLoad  := False
readinVolume       := False     *  11 -> 8.4.0 read in volume level and mute status
readinAny()                     ... Text
+ 225 Possible to rearrange items in status bar?
readinInterval     := 30000
Bar_toggleCommandGui()
```

## GUI - Other
```
largeFontSize      := 24        ... for trace areas
View_traceAreas()
areaTraceTimeout   := 1000      ... or continuouslyTraceAreas := True/ default: False
+ web frontend                  ... one webbrowser window per monitor/ workarea? not 'always on top', but with no overlapping tiled windows?
+ configuration gui
```


## Windows/ Windows UI Elements
```
borderWidth     := 0            ... not with Windows 10 -> remove functionality?
borderPadding   := -1           ... not with Windows 10 -> remove functionality?
showBorder      := True         ... not with Windows 10 -> remove functionality?
selBorderColor  := ""           ... not with Windows 10 -> remove functionality?
Window_toggleDecor()
View_activateWindow(0, +/-1)    + 176 focus window in master area, ... but without predifined hotkeys
                                + 162 focus the nth window/ move the nth window to the master area, ... but no included move
+ 131 rotate window focus/ move per stack
+ 183 set window floating and 'always on top'
Manager_closeWindow()
Manager_moveWindow()                        -> remove functionality?
Manager_sizeWindow()                        -> remove functionality?
Manager_getWindowInfo()
Manager_activateMonitor(0, +/-1)
Monitor_toggleNotifyIconOverflowWindow()    -> remove functionality?
```


## Compatibility
```
bbCompatibility    := False                 -> remove functionality?
*  16 display scaling awareness (bar width)
scalingFactor      := 1
ghostWndSubString  := " (Not Responding)"
+   4 vm and rdp suuport
+ improved multi-monitor support                                -> i3wm style views? *lock visible view after window is closed?* activate gui webbrowser?
+ 220 Change Monitor order
+ 227 Compatibility of the bug.n status bar to more than two Windows taskbars.
```


## Views/ Virtual Desktops
```
viewNames          := "1;2;3;4;5;6;7;8;9" (any text)            * 8.3.0 view names
+ 113 set different view names on different monitors            -> i3wm style views?
+ 222 Use icon fonts in views name
onActiveHiddenWnds := "view"                                    * 8.2.1 customize reaction to acivated windows on an inactive view
syncMonitorViews   := 0                                         * 8.2.0 synchronized view on all monitors -> redundant to Windows virtual desktops, not compatible with i3wm?
viewFollowsTagged  := False
Monitor_activateView({1-9/-1})
Monitor_setWindowTag({1-9/10})
Monitor_toggleWindowTag({1-9})
*+ 201 windows 10 virtual desktop adaptation*                   window applicationframe class!
+ 151 i3wm's view sets per monitor/ a single set of views across all monitors
+ 136 per monitor actions, e.g. change layout of the active view on a specific monitor; or per view actions
+ 151 xmonad's 'greedy view'
+ 151 monitor-independent view/ move view to another monitor    -> groups?
+ 151 dynamic view creation and deletion
+ 119 more than one tag in a view like dwm                      -> groups?
*  26 'the attic' view temporarily "hiding" a window            -> i3wm scratch pad?
+ 112 more than 9 views
+ groups/ workareas

? hide/ minimize/ 'move to background' (set per view) inactive view, if another view gets activated, ... instead of just the 'hide' option
? think virtual desktops not as views, but as virtual monitors
- 1. left hand - keyboard, right hand - mouse; 2. left and right hand - keyboard; 2. is a must have (ideological)
- not wanted: move the right hand between keyboard and mouse (between keyboard and touchpad - ok)
- windows cannot simply be moved between virtual desktops by keyboard (no shortcut key, only #Tab -> +Tab -> +Tab -> AppKey -> Down? -> Right -> Enter; no API)
- distinguishing factors (bug.n - Windows 10): dynamic tiling, tile more than 4 windows in a grid, keyboard-only controled virtual desktops (move), reduced UI, linux style
- bug.n issues with Windows 10: modern apps with ApplicationFrameWindow and -Host; bug.n cannot fully hide them, virtual desktops can, but not by keyboard only in a simple way
```


## Layouts
```
showBar            := True
+ 157 bar visibility per view
showTaskBar        := False
layout_#1          := "[]=;tile"
+ 121 xmonad's layout grid with golden ratio
+ 100 change the height of individual windows in a vertical stack
+ 224 New windows opened in the floating layout show title bars by default.
+ 224 Forcing a window to float in tile layout shows said window's title bar.
+ 224 Switching layout from floating to tiled hides open window title bars and vice versa.
+ dynamic (i3wm style) layout? rule base layout: a window is added to a group -> how does it relate to the other windows in the same group -> change layout accordingly?
+  48 spread a view over more than one monitor    -> monitor independent groups?
+ 151 -> 9.0.2 reset view i.e. layout properties
layout_#2          := "[M];monocle"
layout_#3          := "><>;"                      -> "||" pause dynamic tiling?
layoutAxis_#1      := 1
layoutAxis_#2      := 2
layoutAxis_#3      := 2
layoutGapWidth     := 0
layoutMFactor      := 0.6
mFactCallInterval  := 700                         * 8.4.0 increasing mfactor resizing over time
newWndPosition     := "top"
viewMargins        := "0;0;0;0"                   * 8.3.0 view margins
View_shuffleWindow(0, +/-1)
View_shuffleWindow(1)
View_toggleFloatingWindow()
Manager_minimizeWindow()                          *  26 -> 9.0.0? allow minimizing to tray/ * 9.0.0 minimize windows and therewith set them floating
Manager_maximizeWindow()                          * 8.1.0 maximize a window to the bug.n workspace and therewith set them floating
View_moveWindow(0, +/-1)                          ... only in manual tiling mode
View_moveWindow(1-10)                             ... only in manual tiling mode
View_toggleStackArea()                            ... only in manual tiling mode
View_setLayout(-1/1/2/3)
View_setLayoutProperty("MFactor", 0, +/-0.05)     ... only for tile layout
View_setLayoutProperty("Axis", 0, +1/+2, 1/2/3)   ... only for tile layout
View_setLayoutProperty("MY"/"MX", 0, +/-1)        ... only for tile layout  * 8.3.0 multi-dimensional tiling of the master area
View_setLayoutProperty("GapWidth", 0, +/-2)
View_resetTileLayout()
View_toggleMargins()
Manager_setWindowMonitor(0, +/-1)
Manager_setViewMonitor(0, +/-1)
Monitor_toggleBar()                               + 211 show on key down, hide on key up
Monitor_toggleTaskBar()
```


## Run State/ Flow Control
```
barCommands        := "Run, explore " Main_ docDir ";Monitor_toggleBar();Reload;ExitApp"                                    * 8.2.0 command input via gui
* 9.0.0 control bug.n (call functions) from a nother script                                                                 -> remove functionality?
dynamicTiling      := True                                                                                                  * 8.4.0 manual tiling
mouseFollowsFocus  := True
shellMsgDelay      := 350
rule_#<i> := "<class>;<title>;<function name>;<is managed>;<m>;<tags>;<is floating>;<is decorated>;<hide title>;<action>"   * 8.3.0 rule based actions (maximize, close)
+ 186 rule selection for windows owned by a specific process
* 177 regex friendly rule in windows info dialog
+  80 auto-create rules for misbehaving windows
Manager_override(rule = "")                                                                                                 * 9.0.0 override rule for the active window by hotkey
monitorDisplayChangeMessages := "ask"                                                                                       *   7 (automatically) handle display changes
Manager_getWindowList()
Debug_logHelp()                                                                                                             * 8.3.0 logging (debugging information)
Debug_logViewWindowList()
Debug_logManagedWindowList()
Debug_setLogLevel(0, +/-1)
*  42 debugging information for rules: which rule was used for a specific window?
*+ 191 rule based wParam handling*
```


## Application
```
autoSaveSession := "auto"   ... at maintenanceInterval := 5000 seconds
Config_ UI_saveSession()    *   2 -> 8.4.0 save/ restore window properties (monitor, view, floating, ...) and bug.n settings (i.a. layout)
Config_edit()               * 8.2.0 hotkey for opening the config file
Reload
ExitApp
tools/build.ahk             * 9.0.1 build script
github wiki                 * 9.0.1 tutorial
doc/cheatsheet              *  54 -> 9.0.1 doc/cheatsheet
README.md                   *  39 screenshot in readme
* 8.2.0 setting absolute and relative values in functions (activate view, tag window, set layout)
*  17 switch to a specific monitor given by number
Config_hotkey=              * 8.2.0 set hotkeys via config.ini
+  44 restore a session (with starting applications) or window properties (as the applications are opened by the user)      -> rule based?
+ 151 allow 1 hotkey -> n function calls mappings in config.ini
+ modules
+ JS_ON_ config file?
```

---------------------------------------------------------------------------------------------------

# Feature list

## Open enhancement requests
+ 227 Compatibility of the bug.n status bar to more than two Windows taskbars.
+ 225 Possible to rearrange items in status bar?
+ 224 New windows opened in the floating layout show title bars by default.
+ 224 Forcing a window to float in tile layout shows said window's title bar.
+ 224 Switching layout from floating to tiled hides open window title bars and vice versa.
+ 222 Use icon fonts in views name
+ 220 Change Monitor order

+ 211 Show bar only when key presses
+ 201 windows 10 virtual desktop adaptation
+ 191 rule based wParam handling
+ 186 rule selection for windows owned by a specific process
+ 183 set window floating and 'always on top'
+ 176 focus window in master area
+ 162 focus the nth window/ move the nth window to the master area
+ 157 bar visibility per view
+ 151 i3wm's view sets per monitor/ a single set of views across all monitors
+ 151 dynamic view creation and deletion
+ 151 -> 9.0.2 reset view i.e. layout properties
+ 151 allow 1 hotkey -> n function calls mappings in config.ini
+ 151 xmonad's 'greedy view'
+ 151 monitor-independent view -> move view to another monitor
+ 136 per monitor actions, e.g. change layout of the active view on a specific monitor; or per view actions
+ 131 rotate window focus/ move per stack
+ 121 xmonad's layout grid with golden ratio
+ 119 more than one tag in a view like dwm
+ 113 set different view names on different monitors
+ 112 more than 9 views
+ 100 change the height of individual windows in a vertical stack
+  80 auto-create rules for misbehaving windows
+  48 spread a view over more than one monitor
+  44 restore a session (with starting applications) or window properties (as the applications are opened by the user)
+   4 vm and rdp suuport

## Closed enhancement requests
* 177 regex friendly rule in windows info dialog
*  54 -> 9.0.1 doc/cheatsheet
*  42 debugging information for rules: which rule was used for a specific window?
*  39 screenshot in readme
*  26 -> 9.0.0? allow minimizing to tray
*  26 'the attic' view temporarily "hiding" a window
*  17 switch to a specific monitor given by number
*  16 display scaling aware bar width
*  11 -> 8.4.0 read in volume level and mute status
*  10 -> 8.4.0 transparent bar
*   7 (automatically) handle display changes
*   2 -> 8.4.0 save/ restore window properties (monitor, view, floating, ...) and bug.n settings (i.a. layout)

## Additional features
* 9.0.1 build script
* 9.0.1 tutorial
* 9.0.0 control bug.n (call functions) from a nother script
* 9.0.0 minimize windows and therewith set them floating
* 9.0.0 customizable date and time format
* 9.0.0 override rule for the active window by hotkey
* 8.4.0 manual tiling
* 8.4.0 increasing mfactor resizing over time
* 8.3.0 multi-dimensional tiling of the master area
* 8.3.0 logging (debugging information)
* 8.3.0 view margins
* 8.3.0 rule based actions (macimize, close)
* 8.3.0 view names
* 8.2.1 customize reaction to acivated windows on an inactive view
* 8.2.0 set hotkeys via config.ini
* 8.2.0 horizontal and virtical bar position (left/ center/ right or relative in pixel, top/ bottom/ tray)
* 8.2.0 customizable bar width (in pixel or %) and height (2 rows, spacious)
* 8.2.0 synchronized view on all monitors
* 8.2.0 command input via gui
* 8.2.0 hotkey for opening the config file
* 8.2.0 setting absolute and relative values in functions (activate view, tag window, set layout)
* 8.1.0 maximize a window to the bug.n workspace and therewith set them floating

## Existing features - Configuration

### Status bar
```
showBar           := True
horizontalBarPos  := "left"
verticalBarPos    := "top"
barWidth          := "100%"
singleRowBar      := True
spaciousBar       := False
fontName          := "Lucida Console"
fontSize          := ... read from system settings
largeFontSize     := 24   for trace areas
backColor_#{1,2,3} := ... read from system settings, #{1,2,3} for different states
foreColor_#{1,2,3} := ... read from system settings, allowing frames and progress bars
fontColor_#{1,2,3} := ... read from system settings, all colors set individually for view, layout, title, shebang, time, date, "any text", battery status, volume level
barTransparency   := "off"
barCommands       := "Run, explore " Main_docDir ";Monitor_toggleBar();Reload;ExitApp"
readinBat         := False
readinCpu         := False
readinDate        := True   ... with readinDateFormat  := "ddd, dd. MMM. yyyy"
readinDiskLoad    := False
readinMemoryUsage := False
readinNetworkLoad := False
readinTime        := True   ... with readinTimeFormat  := "HH:mm"
readinVolume      := False
readinAny()                 ... Text
readinInterval    := 30000
```

### Windows ui elements
```
bbCompatibility := False
borderWidth     := 0
borderPadding   := -1
showTaskBar     := False
showBorder      := True
selBorderColor  := ""
scalingFactor   := 1
```

### Window arrangement
```
viewNames          := "1;2;3;4;5;6;7;8;9" (any text)
layout_#1          := "[]=;tile"
layout_#2          := "[M];monocle"
layout_#3          := "><>;"
layoutAxis_#1      := 1
layoutAxis_#2      := 2
layoutAxis_#3      := 2
layoutGapWidth     := 0
layoutMFactor      := 0.6
areaTraceTimeout   := 1000
continuouslyTraceAreas := False
dynamicTiling      := True
ghostWndSubString  := " (Not Responding)"
mFactCallInterval  := 700
mouseFollowsFocus  := True
newWndPosition     := "top"
onActiveHiddenWnds := "view"
shellMsgDelay      := 350
syncMonitorViews   := 0
viewFollowsTagged  := False
viewMargins        := "0;0;0;0"

rule_#<i> := "<class>;<title>;<function name>;<is managed>;<m>;<tags>;<is floating>;<is decorated>;<hide title>;<action>"
```

### Configuration management
```
autoSaveSession := "auto"   ... every maintenanceInterval := 5000 seconds
monitorDisplayChangeMessages := "ask"
```

## Existing features - Hotkeys/ Functions

### Window management
```
View_activateWindow(0, +/-1)
View_shuffleWindow(0, +/-1)
View_shuffleWindow(1)
Manager_closeWindow()
Window_toggleDecor()
View_toggleFloatingWindow()
Manager_moveWindow()          ... only in manual tiling mode
Manager_minimizeWindow()
Manager_sizeWindow()
Manager_maximizeWindow()
Manager_getWindowInfo()
Manager_getWindowList()
View_moveWindow(0, +/-1)      ... only in manual tiling mode
Manager_maximizeWindow()
View_moveWindow(1-10)
View_toggleStackArea()        ... only in manual tiling mode
```

### Window debugging
```
Debug_logViewWindowList()
Debug_logManagedWindowList()
Debug_logHelp()
Debug_setLogLevel(0, +/-1)
```

### Layout management
```
View_setLayout(-1/1/2/3)
View_setLayoutProperty("MFactor", 0, +/-0.05)     ... only for tile layout
View_setLayoutProperty("Axis", 0, +1/+2, 1/2/3)   ... only for tile layout
View_setLayoutProperty("MY"/"MX", 0, +/-1)        ... only for tile layout
View_setLayoutProperty("GapWidth", 0, +/-2)
View_resetTileLayout()
```

### View/Tag management
```
View_toggleMargins()
Monitor_activateView({1-9/-1})
Monitor_setWindowTag({1-9/10})
Monitor_toggleWindowTag({1-9})
```

### Monitor management
```
Manager_activateMonitor(0, +/-1)
Manager_setWindowMonitor(0, +/-1)
Manager_setViewMonitor(0, +/-1)
```

### GUI management
```
Monitor_toggleBar()
Monitor_toggleTaskBar()
Bar_toggleCommandGui()
Monitor_toggleNotifyIconOverflowWindow()
View_traceAreas()
```

### Administration
```
Config_edit()
Config_UI_saveSession()
Reload
ExitApp
```
