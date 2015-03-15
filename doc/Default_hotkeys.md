## Default hotkeys

### General description

The hotkeys, as you can set them in `Config.ini`, are noted in the format
`Conifg_hotkey=<modifier><key>::<function>(<argument>)`; you may copy the
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

`Conifg_hotkey=#Down::View_activateWindow(0, +1)`
> Activate the next window in the active view.

`Conifg_hotkey=#Up::View_activateWindow(0, -1)`
> Activate the previous window in the active view.

`Conifg_hotkey=#+Down::View_shuffleWindow(0, +1)`
> Move the active window to the next position in the window list of the view.

`Conifg_hotkey=#+Up::View_shuffleWindow(0, -1)`
> Move the active window to the previous position in the window list of the view.

`Conifg_hotkey=#+Enter::View_shuffleWindow(1)`
> Move the active window to the first position in the window list of the view.
You may also move the active window to any other absolute position in the
window list by using the first parameter.

`Conifg_hotkey=#c::Manager_closeWindow()`
> Close the active window.

`Conifg_hotkey=#+d::Window_toggleDecor()`
> Show / Hide the title bar of the active window.

`Conifg_hotkey=#+f::View_toggleFloatingWindow()`
> Toggle the floating status of the active window (i. e. dis- / regard it when
tiling).

`Conifg_hotkey=#^m::Manager_minimizeWindow()`
> Minimize the active window; this implicitly makes the window floating.

`Conifg_hotkey=#+m::Manager_moveWindow()`
> Move the active window by key (only floating windows).

`Conifg_hotkey=#+s::Manager_sizeWindow()`
> Resize the active window by key (only floating windows).

`Conifg_hotkey=#+x::Manager_maximizeWindow()`
> Move and resize the active window to the size of the work area (only floating
windows).

`Conifg_hotkey=#i::Manager_getWindowInfo()`
> Get information for the active window (id, title, class, process name, style,
geometry, tags and floating state).

`Conifg_hotkey=#+i::Manager_getWindowList()`
> Get a window list for the active view (id, title and class).

`Conifg_hotkey=!Down::View_moveWindow(0, +1)`
> Manually move the active window to the next area in the layout.

`Conifg_hotkey=!Up::View_moveWindow(0, -1)`
> Manually move the active window to the previous area in the layout.

`Conifg_hotkey=!+Enter::Manager_maximizeWindow()`
> Move and resize the active window to the size of the work area (only floating
windows).

`Conifg_hotkey=!<n>::View_moveWindow(<n>)`
> Manually move the active window to the n<sup><small>th</small></sup> area in
the layout (n = 1..9).

`Conifg_hotkey=!0::View_moveWindow(10)`
> Manually move the active window to the n<sup><small>th</small></sup> area in
the layout.

`Conifg_hotkey=!BackSpace::View_toggleStackArea()`
> Toggle the stack area of the layout. If the stack area is disabled, the
master area takes up the whole view.

### Window debugging

`Conifg_hotkey=#^i::Debug_logViewWindowList()`
> Dump window information on the windows of the active view to the log.

`Conifg_hotkey=#+^i::Debug_logManagedWindowList()`
> Dump window information on the contents of the managed window list (floating
and tiled windows of all views) to the log.

`Conifg_hotkey=#^h::Debug_logHelp()`
> Print a description of the formatting (column headings) used in the previous
two log messages (`Manager_logViewWindowList` and
`Manager_logManagedWindowList`) to the log.

`Conifg_hotkey=#^d::Debug_setLogLevel(0, -1)`
> Decrement the debug log level. Show fewer debug messages. You may also set
the debug log level to an absolute value by using the first parameter.

`Conifg_hotkey=#^+d::Debug_setLogLevel(0, +1)`
> Increment the debug log level. Show more debug messages. You may also set
the debug log level to an absolute value by using the first parameter.

### Layout management

`Conifg_hotkey=#Tab::View_setLayout(-1)`
> Set the previously set layout. You may also use `View_setLayout(0, +1)` for
setting the next or `View_setLayout(0, -1)` for setting the previous layout in
the layout array.

`Conifg_hotkey=#f::View_setLayout(3)`
> Set the 3<sup><small>rd</small></sup> defined layout (i. e. floating layout
in the default configuration).

`Conifg_hotkey=#m::View_setLayout(2)`
> Set the 2<sup><small>nd</small></sup> defined layout (i. e. monocle layout in
the default configuration).

`Conifg_hotkey=#t::View_setLayout(1)`
> Set the 1<sup><small>st</small></sup> defined layout (i. e. tile layout in
the default configuration).

`Conifg_hotkey=#Left::View_setLayoutProperty(MFactor, 0, -0.05)`
> Reduce the size of the master area in the active view (only for the "tile"
layout). You may also set an additional parameter for accelerating the third
one. E. g. with
`Conifg_hotkey=#Left::View_setLayoutProperty(MFactor, 0, -0.05, 2)` the first
step, by which the master area is reduced, is -0.0016% and will be doubled with
consecutive calls until it reaches -0.05%.
With the second parameter you may set an absolute value, e. g.
`View_setLayoutProperty(MFactor, 0.5, 0)` splits the view in half.

`Conifg_hotkey=#Right::View_setLayoutProperty(MFactor, 0, +0.05)`
> Enlarge the size of the master area in the active view (only for the "tile"
layout). You may also set a additional parameter for accelerating the third
one. E. g. with
`Conifg_hotkey=#Right::View_setLayoutProperty(MFactor, 0, +0.05, 0.5)` the
first step, by which the master area is reduced, is 0.05%, but with consecutive
calls it will be halved until it reaches 0.0016%.
With the second parameter you may set an absolute value, e. g.
`View_setLayoutProperty(MFactor, 0.67, 0)` makes the master area two thirds
and the stacking area one third the size of the view.

`Conifg_hotkey=#^t::View_setLayoutProperty(Axis, 0, +1, 1)`
> Rotate the layout axis (i. e. 2 -> 1 = vertical layout, 1 -> 2 = horizontal
layout, only for the "tile" layout).

`Conifg_hotkey=#^Enter::View_setLayoutProperty(Axis, 0, +2, 1)`
> Mirror the layout axis (i. e. -1 -> 1 / 1 -> -1 = master on the left / right
side, -2 -> 2 / 2 -> -2 = master at top / bottom, only for the "tile" layout).

`Conifg_hotkey=#^Tab::View_setLayoutProperty(Axis, 0, +1, 2)`
> Rotate the master axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 =
y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).

`Conifg_hotkey=#^+Tab::View_setLayoutProperty(Axis, 0, +1, 3)`
> Rotate the stack axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 =
y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).

`Conifg_hotkey=#^Up::View_setLayoutProperty(MY, 0, +1)`
> Increase the master Y dimension by 1, i.e. increase the number of windows in
the master area by X. Maximum of 9 (only for the "tile" layout).

`Conifg_hotkey=#^Down::View_setLayoutProperty(MY, 0, -1)`
> Decrease the master Y dimension by 1, i.e. decrease the number of windows in
the master area by X. Minimum of 1 (only for the "tile" layout).

`Conifg_hotkey=#^Right::View_setLayoutProperty(MX, 0, +1)`
> Increase the master X dimension by 1, i. e. increase the number of windows in
the master area by Y. Maximum of 9 (only for the "tile" layout).

`Conifg_hotkey=#^Left::View_setLayoutProperty(MX, 0, +1)`
> Decrease the master X dimension by 1, i. e. decrease the number of windows in
the master area by Y. Minimum of 1 (only for the "tile" layout).

`Conifg_hotkey=#+Left::View_setLayoutProperty(GapWidth, 0, -2)`
> Decrease the gap between windows in "monocle" and "tile" layout. You may also
set an absolute value for the gap width by using the first parameter, e. g.
`View_setLayoutProperty(GapWidth, 0, 0)` will eliminate the gap and
`View_setLayoutProperty(GapWidth, 20, 0)` will set it to 20px.

`Conifg_hotkey=#+Right::View_setLayoutProperty(GapWidth, 0, +2)`
> Increase the gap between windows in "monocle" and "tile" layout.

### View / Tag management

`Conifg_hotkey=#+n::View_toggleMargins()`
> Toggle the view margins, which are set by the configuration variable
`Config_viewMargins`.

`Conifg_hotkey=#BackSpace::Monitor_activateView(-1)`
> Activate the previously activated view. You may also use
`Monitor_activateView(0, -1)` or `Monitor_activateView(0, +1)` for activating
the previous or next adjacent view.

`Conifg_hotkey=#+0::Monitor_setWindowTag(10)`
> Tag the active window with all tags (n = 1..`Config_viewCount`). You may also
use `Monitor_setWindowTag(0, -1)` or `Monitor_setWindowTag(0, +1)` for setting
the tag of the previous or next adjacent to the current view.

`Conifg_hotkey=#<n>::Monitor_activateView(<n>)`
> Activate the n<sup><small>th</small></sup> view (n = 1..`Config_viewCount`).

`Conifg_hotkey=#+<n>::Monitor_setWindowTag(<n>)`
> Tag the active window with the n<sup><small>th</small></sup> tag (n =
1..`Config_viewCount`).

`Conifg_hotkey=#^<n>::Monitor_toggleWindowTag(<n>)`
> Add / Remove the n<sup><small>th</small></sup> tag (n = 1..`Config_viewCount`)
for the active window, if it is not / is already set.

### Monitor management

`Conifg_hotkey=#.::Manager_activateMonitor(0, +1)`
> Activate the next monitor in a multi-monitor environment. You may also
activate a specific monitor by using the first parameter, e. g.
`Manager_activateMonitor(1)` will activate the first monitor.

`Conifg_hotkey=#,::Manager_activateMonitor(0, -1)`
> Activate the previous monitor in a multi-monitor environment.

`Conifg_hotkey=#+.::Manager_setWindowMonitor(0, +1)`
> Set the active window's view to the active view on the next monitor in a
multi-monitor environment. You may also set the active window on a specific
monitor by using the first parameter, e. g. `Manager_setWindowMonitor(1)` will
set the active window on the first monitor.

`Conifg_hotkey=#+,::Manager_setWindowMonitor(0, -1)`
> Set the active window's view to the active view on the previous monitor in a
multi-monitor environment.

`Conifg_hotkey=#^+.::Manager_setViewMonitor(0, +1)`
> Set all windows of the active view on the active view of the next monitor in
a multi-monitor environment. You may also set all windows of the active view on
a specific monitor by using the first parameter, e. g.
`Manager_setViewMonitor(1)` will set all windows of the active view on the
first monitor.

`Conifg_hotkey=#^+,::Manager_setViewMonitor(0, -1)`
> Set all windows of the active view on the active view of the previous monitor
in a multi-monitor environment.

### GUI management

`Conifg_hotkey=#+Space::Monitor_toggleBar()`
> Hide / Show the bar (bug.n status bar) on the active monitor.

`Conifg_hotkey=#Space::Monitor_toggleTaskBar()`
> Hide / Show the task bar.

`Conifg_hotkey=#y::Bar_toggleCommandGui()`
> Open the command GUI for executing programmes or bug.n functions.

`Conifg_hotkey=#+y::Monitor_toggleNotifyIconOverflowWindow()`
> Toggle the overflow window of the 'notify icons'.

`Conifg_hotkey=!+y::View_traceAreas()`
> Indicate the areas of the "tile" layout.

### Administration

`Conifg_hotkey=#^e::Run, edit <Config_filePath>`
> Open the configuration file in the standard text editor. If you want to set
this hotkey in `Config.ini`, you have to replace `<Config_filePath>` with an
explicit file path.

`Conifg_hotkey=#^s::Config_UI_saveSession()`
> Save the current state of monitors, views, layouts to the configuration file.

`Conifg_hotkey=#^r::Reload`
> Reload bug.n (i. e. the whole script), which resets i. a. the configuration
and internal variables of bug.n, including the window lists. It is like
Quitting and restarting bug.n.
If `Config_autoSaveSession` is not set to `off`, the window lists can be
restored and windows are put to their associated monitor and views.

`Conifg_hotkey=#^q::ExitApp`
> Quit bug.n, restore the default Windows UI and show all windows.
