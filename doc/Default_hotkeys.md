## Default hotkeys

### General description

The hotkeys, as you can set them in `Config.ini`, are noted in the format
`<modifier><key>::<function>(<argument>)`.
Possible modifiers are the following:

* `!` (Alt)
* `^` (Ctrl, Control)
* `#` (LWin, left Windows)
* `+` (Shift)

You will have to press all keys of a hotkey at the same time beginning with the
modifier for calling the associated function, e. g. `#^q` means pressing the
left 'Windows key' and the 'Control key' and the 'Q key' (`Win+Ctrl+Q`) for
quitting bug.n.

### Window management

`#Down::View_activateWindow(+1)`
> Activate the next window in the active view.

`#Up::View_activateWindow(-1)`
> Activate the previous window in the active view.

`#+Down::View_shuffleWindow(+1)`
> Move the active window to the next position in the window list of the view.

`#+Up::View_shuffleWindow(-1)`
> Move the active window to the previous position in the window list of the view.

`#+Enter::View_shuffleWindow(0)`
> Move the active window to the first position in the window list of the view.

`#c::Manager_closeWindow()`
> Close the active window.

`#+d::Manager_toggleDecor()`
> Show / Hide the title bar of the active window.

`#+f::View_toggleFloating()`
> Toggle the floating status of the active window (i. e. dis- / regard it when
tiling).

`#+m::Manager_moveWindow()`
> Move the active window by key (only floating windows).

`#+s::Manager_sizeWindow()`
> Resize the active window by key (only floating windows).

`#+x::Manager_maximizeWindow()`
> Move and resize the active window to the size of the work area (only floating
windows).

`#i::Manager_getWindowInfo()`
> Get information for the active window (id, title, class, process name, style,
geometry, tags and floating state).

`#+i::Manager_getWindowList()`
> Get a window list for the active view (id, title and class).

`!Down::View_moveWindow(0, +1)`
> Manually move the active window to the next area in the layout.

`!Up::View_moveWindow(0, -1)`
> Manually move the active window to the previous area in the layout.

`!+Enter::Manager_maximizeWindow()`
> Move and resize the active window to the size of the work area (only floating
windows).

`!<n>::View_moveWindow(<n>)`
> Manually move the active window to the n<sup><small>th</small></sup> area in
the layout (n = 1..9).

`!0::View_moveWindow(10)`
> Manually move the active window to the n<sup><small>th</small></sup> area in
the layout.

`!BackSpace::View_toggleStackArea()`
> Toggle the stack area of the layout. If the stack area is disabled, the
master area takes up the whole view.

### Window debugging

`#^i::Debug_logViewWindowList()`
> Dump window information on the windows of the active view to the log.

`#+^i::Debug_logManagedWindowList()`
> Dump window information on the contents of the managed window list (floating
and tiled windows of all views) to the log.

`#^h::Debug_logHelp()`
> Print a description of the formatting (column headings) used in the previous
two log messages (`Manager_logViewWindowList` and
`Manager_logManagedWindowList`) to the log.

`#^d::Debug_setLogLevel(-1)`
> Decrement the debug log level. Show fewer debug messages.

`#^+d::Debug_setLogLevel(+1)`
> Increment the debug log level. Show more debug messages.

### Layout management

`#Tab::View_setLayout(-1)`
> Set the previously set layout. You may also use `View_setLayout(>)` for
setting the next layout in the layout array.

`#f::View_setLayout(3)`
> Set the 3<sup><small>rd</small></sup> defined layout (i. e. floating layout
in the default configuration).

`#m::View_setLayout(2)`
> Set the 2<sup><small>nd</small></sup> defined layout (i. e. monocle layout in
the default configuration).

`#t::View_setLayout(1)`
> Set the 1<sup><small>st</small></sup> defined layout (i. e. tile layout in
the default configuration).

`#Left::View_setMFactor(-0.05)`
> Reduce the size of the master area in the active view (only for the "tile"
layout). You may also set a second parameter for accelerating the first one.
E. g. with `#Left::View_setMFactor(-0.05, 2)` the first step, by which the
master area is reduced, is -0.0016% and will be doubled with consecutive calls
until it reaches -0.05%.

`#Right::View_setMFactor(+0.05)`
> Enlarge the size of the master area in the active view (only for the "tile"
layout). You may also set a second parameter for accelerating the first one.
E. g. with `#Right::View_setMFactor(0.05, 0.5)` the first step, by which the
master area is reduced, is 0.05%, but with consecutive calls it will be halved
until it reaches 0.0016%.

`#^t::View_rotateLayoutAxis(1, +1)`
> Rotate the layout axis (i. e. 2 -> 1 = vertical layout, 1 -> 2 = horizontal
layout, only for the "tile" layout).

`#^Enter::View_rotateLayoutAxis(1, +2)`
> Mirror the layout axis (i. e. -1 -> 1 / 1 -> -1 = master on the left / right
side, -2 -> 2 / 2 -> -2 = master at top / bottom, only for the "tile" layout).

`#^Tab::View_rotateLayoutAxis(2, +1)`
> Rotate the master axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 =
y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).

`#^+Tab::View_rotateLayoutAxis(3, +1)`
> Rotate the stack axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 =
y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).

`#^Up::View_setMY(+1)`
> Increase the master Y dimension by 1, i.e. increase the number of windows in
the master area by X. Maximum of 9 (only for the "tile" layout).

`#^Down::View_setMY(-1)`
> Decrease the master Y dimension by 1, i.e. decrease the number of windows in
the master area by X. Minimum of 1 (only for the "tile" layout).

`#^Right::View_setMX(+1)`
> Increase the master X dimension by 1, i. e. increase the number of windows in
the master area by Y. Maximum of 9 (only for the "tile" layout).

`#^Left::View_setMX(-1)`
> Decrease the master X dimension by 1, i. e. decrease the number of windows in
the master area by Y. Minimum of 1 (only for the "tile" layout).

`#+Left::View_setGapWidth(-2)`
> Decrease the gap between windows in "tile" layout.

`#+Right::View_setGapWidth(+2)`
> Increase the gap between windows in "tile" layout.

### View / Tag management

`#+n::View_toggleMargins()`
> Toggle the view margins, which are set by the configuration variable
`Config_viewMargins`.

`#BackSpace::Monitor_activateView(-1)`
> Activate the previously activated view. You may also use
`Monitor_activateView(<)` or `Monitor_activateView(>)` for activating the
previous or next adjacent view.

`#+0::Monitor_setWindowTag(0)`
> Tag the active window with all tags (n = 1..`Config_viewCount`). You may also
use `Monitor_setWindowTag(<)` or `Monitor_setWindowTag(>)` for setting the tag
of the previous or next adjacent to the current view.

`#<n>::Monitor_activateView(<n>)`
> Activate the n<sup><small>th</small></sup> view (n = 1..`Config_viewCount`).

`#+<n>::Monitor_setWindowTag(<n>)`
> Tag the active window with the n<sup><small>th</small></sup> tag (n =
1..`Config_viewCount`).

`#^<n>::Monitor_toggleWindowTag(<n>)`
> Add / Remove the n<sup><small>th</small></sup> tag (n = 1..`Config_viewCount`)
for the active window, if it is not / is already set.

### Monitor management

`#.::Manager_activateMonitor(+1)`
> Activate the next monitor in a multi-monitor environment.

`#,::Manager_activateMonitor(-1)`
> Activate the previous monitor in a multi-monitor environment.

`#+.::Manager_setWindowMonitor(+1)`
> Set the active window to the active view on the next monitor in a
multi-monitor environment.

`#+,::Manager_setWindowMonitor(-1)`
> Set the active window to the active view on the previous monitor in a
multi-monitor environment.

`#^+.::Manager_setViewMonitor(+1)`
> Set all windows of the active view on the active view of the next monitor in
a multi-monitor environment.

`#^+,::Manager_setViewMonitor(-1)`
> Set all windows of the active view on the active view of the previous monitor
in a multi-monitor environment.

### GUI management

`#+Space::Monitor_toggleBar()`
> Hide / Show the bar (bug.n status bar) on the active monitor.

`#Space::Monitor_toggleTaskBar()`
> Hide / Show the task bar.

`#y::Bar_toggleCommandGui()`
> Open the command GUI for executing programmes or bug.n functions.

`#+y::Monitor_toggleNotifyIconOverflowWindow()`
> Toggle the overflow window of the 'notify icons'.

`!+y::View_traceAreas()`
> Indicate the areas of the "tile" layout.

### Administration

`#^e::Run, edit %Config_filePath%`
> Open the configuration file in the standard text editor.

`#^s::Config_UI_saveSession()`
> Save the current state of monitors, views, layouts to the configuration file.

`#^r::Main_reload()`
> Reload bug.n (i. e. the configuration and its dependent settings) without
deleting the window lists of bug.n and restoring windows.
- It does not reset internal configuration variables, the tray icon or menu,
hotkeys (unless defined in `Config.ini`), individual window settings like
`Config_showBorder` (since windows might be hidden) or hiding the title bar, the
monitor count or views.
- It does not reload the monitor configuration and therefor does not recognize
any changes in the number of monitors.
- It does not reload functions.
- Changed rules are only applied to new windows.

`#^+r::Reload`
> Reload bug.n (i. e. the whole script), which resets the configuration, the
bar, the monitor configuration and window lists of bug.n. It is like Quitting
and restarting bug.n.

`#^q::ExitApp`
> Quit bug.n, restore the default Windows UI and show all windows.
