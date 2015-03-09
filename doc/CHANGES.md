## Changes

##### Legend

* `-` deleted
* `~` changed
* `+` added

### 9.0.0

1. `~` Renamed the function `Manager_toggleDecor` to `Window_toggleDecor`.
2. `~` Renamed the function `View_toggleFloating` to `View_toggleFloatingWindow`.
3. `~` Migrated the following functions to `View_setLayoutProperty`: `View_setGapWidth`, `View_setMFactor`, `View_setMX`,
`View_setMY` and `View_rotateLayoutAxis`.
4. `~` Revised the following functions to allow setting absolute and relative values: `Debug_setLogLevel`,
`Manager_activateMonitor`, `Manager_setViewMonitor`, `Manager_setWindowMonitor`, `Monitor_activateView`, `Monitor_setWindowTag`,
`View_setGapWidth`, `View_setLayout`, `View_setMFactor`, `View_shuffleWindow`.
5. `~` Revised the interface, i. e. the parameters, of the following functions for setting absolute and relative values -- but did
not implement the functionality: `Monitor_toggleWindowTag`, `View_activateWindow`.
6. `~` Revised the bar color scheme.
7. `~` Revised the rule layout. The third parameter is not compared to the window style anymore, but is a function name, which is
called with the window ID as a paramater, when applying the rule.
8. `~` Revised the default rule set.
9. `+` Added the possibility for sending commands to bug.n from another AutoHotkey script.
10. `~` Removed the function `Main_reload` and reassigned the hotkey.
11. `+` Added the possibility to minimize windows, making them floating and thereby excluded from tiling.

|   # | `-` or `~` Configuration Variables or <br/> `-` Hotkey Functions | `+` Configuration Variables or <br/> `+` Hotkey Functions |
| ---:|:---------------------------------------------------------------- |:--------------------------------------------------------- |
|  1. | `#+d::Manager_toggleDecor()`                                     | `#+d::Window_toggleDecor()`                               |
|  2. | `#+f::View_toggleFloating()`                                     | `#+f::View_toggleFloatingWindow()`                        |
|  3. | `#Left::View_setMFactor(-0.05)`                                  | `#Left::View_setLayoutProperty("MFactor", 0, -0.05)`      |
|     | `#Right::View_setMFactor(+0.05)`                                 | `#Right::View_setLayoutProperty("MFactor", 0, +0.05)`     |
|     | `#^t::View_rotateLayoutAxis(1, +1)`                              | `#^t::View_setLayoutProperty("Axis", 0, +1, 1)`           |
|     | `#^Enter::View_rotateLayoutAxis(1, +2)`                          | `#^Enter::View_setLayoutProperty("Axis", 0, +2, 1)`       |
|     | `#^Tab::View_rotateLayoutAxis(2, +1)`                            | `#^Tab::View_setLayoutProperty("Axis", 0, +1, 2)`         |
|     | `#^+Tab::View_rotateLayoutAxis(3, +1)`                           | `#^+Tab::View_setLayoutProperty("Axis", 0, +1, 3)`        |
|     | `#^Up::View_setMY(+1)`                                           | `#^Up::View_setLayoutProperty("MY", 0, +1)`               |
|     | `#^Down::View_setMY(-1)`                                         | `#^Down::View_setLayoutProperty("MY", 0, -1)`             |
|     | `#^Right::View_setMX(+1)`                                        | `#^Right::View_setLayoutProperty("MX", 0, +1)`            |
|     | `#^Left::View_setMX(-1)`                                         | `#^Left::View_setLayoutProperty("MX", 0, -1)`             |
|     | `#+Left::View_setGapWidth(-2)`                                   | `#+Left::View_setLayoutProperty("GapWidth", 0, -2)`       |
|     | `#+Right::View_setGapWidth(+2)`                                  | `#+Right::View_setLayoutProperty("GapWidth", 0, +2)`      |
|  4. | `#^d::Debug_setLogLevel(-1)`                                     | `#^d::Debug_setLogLevel(0, -1)`                           |
|     | `#^+d::Debug_setLogLevel(+1)`                                    | `#^+d::Debug_setLogLevel(0, +1)`                          |
|     | `#+Down::View_shuffleWindow(+1)`                                 | `#+Down::View_shuffleWindow(0, +1)`                       |
|     | `#+Up::View_shuffleWindow(-1)`                                   | `#+Up::View_shuffleWindow(0, -1)`                         |
|     | `#+Enter::View_shuffleWindow(0)`                                 | `#+Enter::View_shuffleWindow(1)`                          |
|     | `#+0::Monitor_setWindowTag(0)`                                   | `#+0::Monitor_setWindowTag(10)`                           |
|     | `#.::Manager_activateMonitor(+1)`                                | `#.::Manager_activateMonitor(0, +1)`                      |
|     | `#,::Manager_activateMonitor(-1)`                                | `#,::Manager_activateMonitor(0, -1)`                      |
|     | `#+.::Manager_setWindowMonitor(+1)`                              | `#+.::Manager_setWindowMonitor(0, +1)`                    |
|     | `#+,::Manager_setWindowMonitor(-1)`                              | `#+,::Manager_setWindowMonitor(0, -1)`                    |
|     | `#^+.::Manager_setViewMonitor(+1)`                               | `#^+.::Manager_setViewMonitor(0, +1)`                     |
|     | `#^+,::Manager_setViewMonitor(-1)`                               | `#^+,::Manager_setViewMonitor(0, -1)`                     |
|  5. | `#Down::View_activateWindow(+1)`                                 | `#Down::View_activateWindow(0, +1)`                       |
|     | `#Up::View_activateWindow(-1)`                                   | `#Up::View_activateWindow(0, -1)`                         |
|  6. | `Config_normBgColor`                                             |                                                           |
|     | `Config_normFgColor`                                             |                                                           |
|     | `Config_selBgColor`                                              |                                                           |
|     | `Config_selFgColor`                                              |                                                           |
|     |                                                                  | `Config_backColor_#1`                                     |
|     |                                                                  | `Config_backColor_#2`                                     |
|     |                                                                  | `Config_backColor_#3`                                     |
|     |                                                                  | `Config_foreColor_#1`                                     |
|     |                                                                  | `Config_foreColor_#2`                                     |
|     |                                                                  | `Config_foreColor_#3`                                     |
|     |                                                                  | `Config_fontColor_#1`                                     |
|     |                                                                  | `Config_fontColor_#2`                                     |
|     |                                                                  | `Config_fontColor_#3`                                     |
|  7. | `Config_rule_#2`                                                 |                                                           |
|  8. | `Config_rule_#3`                                                 |                                                           |
|     | `Config_rule_#4`                                                 |                                                           |
|     | `Config_rule_#7`                                                 |                                                           |
|     | `Config_rule_#9`                                                 |                                                           |
|     | `Config_rule_#10`                                                |                                                           |
|     | `Config_rule_#11`                                                |                                                           |
|     | `Config_rule_#12`                                                |                                                           |
|     |                                                                  | `Config_rule_#13`                                         |
|     |                                                                  | `Config_rule_#14`                                         |
|     |                                                                  | `Config_rule_#15`                                         |
|     |                                                                  | `Config_rule_#16`                                         |
|     |                                                                  | `Config_rule_#17`                                         |
| 10. | `#^r::Main_reload()`                                             |                                                           |
|     | `#^+r::Reload`                                                   | `#^r::Reload`                                             |
| 11. |                                                                  | `#^m::Manager_minimizeWindow()`                           |

### 8.4.0

1. `+` Session auto-save and restore. Layout and Window information is stored
periodically so that it may be recovered after a restart.
2. `+` Toggling the overflow window of the 'notify icons' by hotkey.
3. `+` Manual tiling.
4. `+` Increasing MFactor Resizing Over Time
5. `+` Bar transparency
6. `+` Reading in the sound volume and mute status and displaying it in the status bar.

| #   | Configuration variables           | Hotkeys                                         |
| ---:| --------------------------------- | ----------------------------------------------- |
|  2. |                                   | `#+y::Monitor_toggleNotifyIconOverflowWindow()` |
|  3. | `Config_largeFontSize=24`         | `!Down::View_moveWindow(0, +1)`                 |
|     | `Config_areaTraceTimeout=1000`    | `!Up::View_moveWindow(0, -1)`                   |
|     | `Config_continuouslyTraceAreas=0` | `!+Enter::Manager_maximizeWindow()`             |
|     | `Config_dynamicTiling=1`          | `!<n>::View_moveWindow(<n>)`                    |
|     |                                   | `!0::View_moveWindow(10)`                       |
|     |                                   | `!BackSpace::View_toggleStackArea()`            |
|     |                                   | `!+y::View_traceAreas()`                        |
|  4. | `Config_mFactCallInterval=700`    | `View_setMFactor(d, dFact=1)`                   |
|  5. | `Config_barTransparency=off`      |                                                 |
|  6. | `Config_readinVolume`             |                                                 |

### 8.3.0

* `~` Changed the command line argument from specifying 'the path to the
Config.ini' to 'the path to the general data directory containing the
Config.ini and log.txt'.
* `+` Multi-dimensional tiling of the master area. The user may now specify X
and Y dimensions independently up to 9 x 9.
* `+` Created bug.n log to record major and debugging events and window
information.
* `+` 'View margins' allowing a layout to occupy a limited space of the
monitor.
* `+` 'Single window action', which allows to close or maximize windows based
on rules.
* `+` 'Reload' hotkey, which reloads the whole script.
* `+` Re-Setting the 'Reload' and 'ExitApp' hotkey in 'Config.ini'-
* `+` Added the configuration variable `Config_viewNames`, with which views can
be named and the number of views can be set. The configuration variable
`Config_viewCount` therewith becomes obsolete.
* `-` Removed the configuration variable `Config_viewCount`.
* `-` Removed the explicit listing of commands in the `Bar_cmdGui`.
* `-` Removed the default rules for Gimp, since from version 2.8 onwards Gimp
can use a single application window instead of three and more.

### 8.2.1

* `+` feature #005446: Reload function (reloading bug.n without changing the
current association of windows to views/tags)
* `+` workaround bug #018364: (Evernote: new note) Introducing the
configuration variable `Config_onActiveHiddenWnds` to set the behaviour of
bug.n for already existing but hidden windows on redraw

### 8.2.0

* `-` `Config_addRunCommands` (the 'Run' item in 'command GUI').
* `-` `Config_sessionFilePath`
* `-` `Config_topBar` (replaced by `Config_verticalBarPos`.
* `~` The default values for the color (`Config_normBgColor`,
`Config_normFgColor`, `Config_selBgColor` and `Config_selFgColor`) and font
size (`Config_fontSize`) of the status bar are now retrieved from the system
settings.
* `+` Default rules
* `+` `Config_hotkey` (setting hotkeys in 'Config.ini').
* `+` `Config_horizontalBarPos` (The horizontal position of the bar: `center`,
`left` or `right` side of the monitor or an offset in pixel (px) from the left
(>= 0) or right (< 0).
* `+` `Config_verticalBarPos` (The vertical position of the bar: `top` or
`bottom` of the monitor, `tray` = sub-window of the task bar.
* `+` `Config_barWidth` (The width of the bar in pixel (px) or with a per cent
sign (%) as a percentage.
* `+` `Config_singleRowBar` (If false, the bar will have to rows, one for the
window title and one for all other GUI controls.
* `+` `Config_spaciousBar` (If true, the height of the bar will be set to a
value equal to the height of an edit control, else it will be set to the text
height.
* `+` `Config_syncMonitorViews` (The number of monitors (2 or more), for which
views should be activated, when using the accordant hotkey. If set to 1, the
views are actiated for all monitors. If set to 0, views are activated
independently (only on the active monitor).
* `~` Changed hotkeys
  + `#s` => `#^s::Config_saveSession()`
  + `#+r` => `#^r::Reload`
  + `#+q` => `#^q::ExitApp`
* `+` `#y::Bar_toggleCommandGui()` (Open the command GUI for executing
programmes or bug.n functions.)
* `+` `#^e::Run, edit, %Config_sessionFilePath%` (Open the session file in the
standard text editor.
* `+` "<" and ">" as an argument for `Monitor_activateView`.
* `+` "<" and ">" as an argument for `Monitor_setWindowTag`.
* `+` `Manager_maximizeWindow()` to 'command GUI'
* `~` The number of windows on a view is not indicated by different background
colors anymore, but by a progress bar.
* `~` The battery status is also indicated with a progress bar.
* `+` A monitor with no windows on it can now be activated by cklicking on the
desktop and therewith changing the active window.

### 8.1.0

* `-` `Config_showTitleBars`
* `~` `Config_rules` have two more parameters (window style and if the window
is decorated; this replaces `Config_showTitleBars`).
* `+` `LWin+Shift+X` maximizes a window to the bug.n workspace.
* `+` You may now use `Monitor_activateView(">")` for cycling through the views
and `View_setLayout(">")` for cycling through the layouts.
