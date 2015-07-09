## Default hotkeys

### General description

The hotkeys, as you can set them in `Config.ini`, are noted in the format
`Config_hotkey=<modifier><key>::<function>(<argument>)`; you may copy the
string from ` ` and use it as a template for a new line in `Config.ini`.
Possible modifiers are the following:

* `!` <kbd>Alt</kbd>
* `^` <kbd>Ctrl</kbd>, Control
* `#` <kbd>Win</kbd> / LWin, the left Windows key
* `+` <kbd>Shift</kbd>

You will have to press all keys of a hotkey at the same time beginning with the
modifier for calling the associated function, e. g. `#^q` means pressing the
left 'Windows key' and the 'Control key' and the 'Q key'
(<kbd>Win</kbd><kbd>Ctrl</kbd><kbd>Q</kbd>) for quitting bug.n.

### Window management

`Config_hotkey=#Down::View_activateWindow(0, +1)`
> Activate the next window in the active view.

`Config_hotkey=#Up::View_activateWindow(0, -1)`
> Activate the previous window in the active view.

`Config_hotkey=#+Down::View_shuffleWindow(0, +1)`
> Move the active window to the next position in the window list of the view.

`Config_hotkey=#+Up::View_shuffleWindow(0, -1)`
> Move the active window to the previous position in the window list of the view.

`Config_hotkey=#+Enter::View_shuffleWindow(1)`
> Move the active window to the first position in the window list of the view.

You may also move the active window to any other absolute position in the
window list by using the first parameter.

`Config_hotkey=#c::Manager_closeWindow()`
> Close the active window.

`Config_hotkey=#+d::Window_toggleDecor()`
> Show / Hide the title bar of the active window.

`Config_hotkey=#+f::View_toggleFloatingWindow()`
> Toggle the floating status of the active window.

The floating status effects the tiling of the active window (i. e. dis- / 
regard it).

`Config_hotkey=#^m::Manager_minimizeWindow()`
> Minimize the active window.

This implicitly makes the window floating.

`Config_hotkey=#+m::Manager_moveWindow()`
> Move the active window by key (only floating windows).

`Config_hotkey=#+s::Manager_sizeWindow()`
> Resize the active window by key (only floating windows).

`Config_hotkey=#+x::Manager_maximizeWindow()`
> Move and resize the active window to the size of the work area (only floating
windows).

`Config_hotkey=#i::Manager_getWindowInfo()`
> Get information for the active window.

The information being id, title, class, process name, style, geometry, tags and 
floating state.

`Config_hotkey=#+i::Manager_getWindowList()`
> Get a window list for the active view.

The list contains information about the window id, title and class.

`Config_hotkey=!Down::View_moveWindow(0, +1)`
> Manually move the active window to the next area in the layout.

`Config_hotkey=!Up::View_moveWindow(0, -1)`
> Manually move the active window to the previous area in the layout.

`Config_hotkey=!+Enter::Manager_maximizeWindow()`
> Move and resize the active window to the size of the work area (only floating
windows).

`Config_hotkey=!<n>::View_moveWindow(<n>)`
> Manually move the active window to the n<sup><small>th</small></sup> area in
the layout (n = 1..9).

`Config_hotkey=!0::View_moveWindow(10)`
> Manually move the active window to the n<sup><small>th</small></sup> area in
the layout.

`Config_hotkey=!BackSpace::View_toggleStackArea()`
> Toggle the stack area of the layout. 

If the stack area is disabled, the master area takes up the whole view.

### Window debugging

`Config_hotkey=#^i::Debug_logViewWindowList()`
> Dump window information on the windows of the active view to the log.

`Config_hotkey=#+^i::Debug_logManagedWindowList()`
> Dump window information on the contents of the managed window list to the log.

The list contains the floating and tiled windows of all views.

`Config_hotkey=#^h::Debug_logHelp()`
> Print a description of the formatting (column headings) used in the previous
two log messages to the log.

The previous two hotkeys being `Manager_logViewWindowList` and 
`Manager_logManagedWindowList`.

`Config_hotkey=#^d::Debug_setLogLevel(0, -1)`
> Decrement the debug log level. 

This results in showing fewer debug messages. You may also set the debug log 
level to an absolute value by using the first parameter.

`Config_hotkey=#^+d::Debug_setLogLevel(0, +1)`
> Increment the debug log level. 

This results in showing more debug messages. You may also set the debug log 
level to an absolute value by using the first parameter.

### Layout management

`Config_hotkey=#Tab::View_setLayout(-1)`
> Set the previously set layout. 

You may also use `View_setLayout(0, +1)` for setting the next or 
`View_setLayout(0, -1)` for setting the previous layout in the layout array.

`Config_hotkey=#f::View_setLayout(3)`
> Set the floating layout.

`Config_hotkey=#m::View_setLayout(2)`
> Set the monocle layout.

`Config_hotkey=#t::View_setLayout(1)`
> Set the tile layout.

`Config_hotkey=#Left::View_setLayoutProperty(MFactor, 0, -0.05)`
> Reduce the size of the master area in the active view (only for the "tile"
layout). 

You may also set an additional parameter for accelerating the third one. E. g. 
with `Config_hotkey=#Left::View_setLayoutProperty(MFactor, 0, -0.05, 2)` the 
first step, by which the master area is reduced, is -0.0016% and will be 
doubled with consecutive calls until it reaches -0.05%.
With the second parameter you may set an absolute value, e. g.
`View_setLayoutProperty(MFactor, 0.5, 0)` splits the view in half.

`Config_hotkey=#Right::View_setLayoutProperty(MFactor, 0, +0.05)`
> Enlarge the size of the master area in the active view (only for the "tile"
layout). 

You may also set a additional parameter for accelerating the third one. E. g. 
with `Config_hotkey=#Right::View_setLayoutProperty(MFactor, 0, +0.05, 0.5)` the
first step, by which the master area is reduced, is 0.05%, but with consecutive
calls it will be halved until it reaches 0.0016%.
With the second parameter you may set an absolute value, e. g.
`View_setLayoutProperty(MFactor, 0.67, 0)` makes the master area two thirds
and the stacking area one third the size of the view.

`Config_hotkey=#^t::View_setLayoutProperty(Axis, 0, +1, 1)`
> Rotate the layout axis (only for the "tile" layout).

I. e. 2 -> 1 = vertical layout, 1 -> 2 = horizontal layout.

`Config_hotkey=#^Enter::View_setLayoutProperty(Axis, 0, +2, 1)`
> Mirror the layout axis (only for the "tile" layout).

I. e. -1 -> 1 / 1 -> -1 = master on the left / right side, 
-2 -> 2 / 2 -> -2 = master at top / bottom.

`Config_hotkey=#^Tab::View_setLayoutProperty(Axis, 0, +1, 2)`
> Rotate the master axis (only for the "tile" layout).

I. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 
2 -> 3 = z-axis = monocle.

`Config_hotkey=#^+Tab::View_setLayoutProperty(Axis, 0, +1, 3)`
> Rotate the stack axis (only for the "tile" layout).

I. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 
2 -> 3 = z-axis = monocle.

`Config_hotkey=#^Up::View_setLayoutProperty(MY, 0, +1)`
> Increase the master Y dimension by 1 (only for the "tile" layout).

This results in an increased number of windows in the master area by X. 
Maximum of 9.

`Config_hotkey=#^Down::View_setLayoutProperty(MY, 0, -1)`
> Decrease the master Y dimension by 1 (only for the "tile" layout).

This results in a decreased number of windows in the master area by X. 
Minimum of 1.

`Config_hotkey=#^Right::View_setLayoutProperty(MX, 0, +1)`
> Increase the master X dimension by 1 (only for the "tile" layout).

This results in an increased number of windows in the master area by Y. 
Maximum of 9.

`Config_hotkey=#^Left::View_setLayoutProperty(MX, 0, +1)`
> Decrease the master X dimension by 1 (only for the "tile" layout).

This results in a decreased number of windows in the master area by Y. 
Minimum of 1.

`Config_hotkey=#+Left::View_setLayoutProperty(GapWidth, 0, -2)`
> Decrease the gap between windows in "monocle" and "tile" layout. 

You may also set an absolute value for the gap width by using the first 
parameter, e. g. `View_setLayoutProperty(GapWidth, 0, 0)` will eliminate the 
gap and `View_setLayoutProperty(GapWidth, 20, 0)` will set it to 20px.

`Config_hotkey=#+Right::View_setLayoutProperty(GapWidth, 0, +2)`
> Increase the gap between windows in "monocle" and "tile" layout.

### View / Tag management

`Config_hotkey=#+n::View_toggleMargins()`
> Toggle the view margins.

These are set by the configuration variable `Config_viewMargins`.

`Config_hotkey=#BackSpace::Monitor_activateView(-1)`
> Activate the previously activated view. 

You may also use `Monitor_activateView(0, -1)` or `Monitor_activateView(0, +1)` 
for activating the previous or next adjacent view.

`Config_hotkey=#+0::Monitor_setWindowTag(10)`
> Tag the active window with all tags (n = 1..`Config_viewCount`). 

You may also use `Monitor_setWindowTag(0, -1)` or `Monitor_setWindowTag(0, +1)` 
for setting the tag of the previous or next adjacent to the current view.

`Config_hotkey=#<n>::Monitor_activateView(<n>)`
> Activate the n<sup><small>th</small></sup> view (n = 1..`Config_viewCount`).

`Config_hotkey=#+<n>::Monitor_setWindowTag(<n>)`
> Tag the active window with the n<sup><small>th</small></sup> tag (n =
1..`Config_viewCount`).

`Config_hotkey=#^<n>::Monitor_toggleWindowTag(<n>)`
> Add / Remove the n<sup><small>th</small></sup> tag (n = 1..`Config_viewCount`)
for the active window, if it is not / is already set.

### Monitor management

`Config_hotkey=#.::Manager_activateMonitor(0, +1)`
> Activate the next monitor in a multi-monitor environment. 

You may also activate a specific monitor by using the first parameter, e. g.
`Manager_activateMonitor(1)` will activate the first monitor.

`Config_hotkey=#,::Manager_activateMonitor(0, -1)`
> Activate the previous monitor in a multi-monitor environment.

`Config_hotkey=#+.::Manager_setWindowMonitor(0, +1)`
> Set the active window's view to the active view on the next monitor in a
multi-monitor environment. 

You may also set the active window on a specific monitor by using the first 
parameter, e. g. `Manager_setWindowMonitor(1)` will set the active window on 
the first monitor.

`Config_hotkey=#+,::Manager_setWindowMonitor(0, -1)`
> Set the active window's view to the active view on the previous monitor in a
multi-monitor environment.

`Config_hotkey=#^+.::Manager_setViewMonitor(0, +1)`
> Set all windows of the active view on the active view of the next monitor in
a multi-monitor environment. 

You may also set all windows of the active view on a specific monitor by using 
the first parameter, e. g. `Manager_setViewMonitor(1)` will set all windows of 
the active view on the first monitor.

`Config_hotkey=#^+,::Manager_setViewMonitor(0, -1)`
> Set all windows of the active view on the active view of the previous monitor
in a multi-monitor environment.

### GUI management

`Config_hotkey=#+Space::Monitor_toggleBar()`
> Hide / Show the bar (bug.n status bar) on the active monitor.

`Config_hotkey=#Space::Monitor_toggleTaskBar()`
> Hide / Show the task bar.

`Config_hotkey=#y::Bar_toggleCommandGui()`
> Open the command GUI for executing programmes or bug.n functions.

`Config_hotkey=#+y::Monitor_toggleNotifyIconOverflowWindow()`
> Toggle the overflow window of the 'notify icons'.

`Config_hotkey=!+y::View_traceAreas()`
> Indicate the areas of the "tile" layout.

### Administration

`Config_hotkey=#^e::Run, edit <Config_filePath>`
> Open the configuration file in the standard text editor. 

If you want to set this hotkey in `Config.ini`, you have to replace 
`<Config_filePath>` with an explicit file path.

`Config_hotkey=#^s::Config_UI_saveSession()`
> Save the current state of monitors, views, layouts to the configuration file.

`Config_hotkey=#^r::Reload`
> Reload bug.n (i. e. the whole script).

This resets i. a. the configuration and internal variables of bug.n, including 
the window lists. It is like Quitting and restarting bug.n.
If `Config_autoSaveSession` is not set to `off`, the window lists can be
restored and windows are put to their associated monitor and views.

`Config_hotkey=#^q::ExitApp`
> Quit bug.n, restore the default Windows UI and show all windows.
