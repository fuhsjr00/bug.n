## Changes

##### Legend

* `-` deleted
* `~` changed
* `+` added

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
