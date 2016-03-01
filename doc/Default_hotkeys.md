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
> _Activate_ the _next_ window in the active view.

`Config_hotkey=#Up::View_activateWindow(0, -1)`
> _Activate_ the _previous_ window in the active view.

`Config_hotkey=#+Down::View_shuffleWindow(0, +1)`
> _Move_ the active window _to the next position_ in the window list of the view.

`Config_hotkey=#+Up::View_shuffleWindow(0, -1)`
> _Move_ the active window _to the previous position_ in the window list of the view.

`Config_hotkey=#+Enter::View_shuffleWindow(1)`
> _Move_ the active window _to the first position_ in the window list of the view.

    You may also move the active window to any other absolute position in the
window list by using the first parameter.

`Config_hotkey=#c::Manager_closeWindow()`
> _Close_ the active window.

`Config_hotkey=#+d::Window_toggleDecor()`
> _Show / Hide the title bar_ of the active window.

`Config_hotkey=#+f::View_toggleFloatingWindow()`
> _Toggle_ the _floating status_ of the active window.

> The floating status effects the tiling of the active window (i. e. dis- / 
regard it).

`Config_hotkey=#^m::Manager_minimizeWindow()`
> _Minimize_ the active window.
     This implicitly sets the window to be floating.

`Config_hotkey=#+m::Manager_moveWindow()`
> _Move_ the active window _by key_.

> This implicitly sets the window to be floating.

`Config_hotkey=#+s::Manager_sizeWindow()`
> _Resize_ the active window _by key_.
    This implicitly sets the window to be floating.

`Config_hotkey=#+x::Manager_maximizeWindow()`
> _Move and resize_ the active window _to_ the size of the _work area_.
    This implicitly sets the window to be floating.

`Config_hotkey=#i::Manager_getWindowInfo()`
> Get information for the active window.
    The information being id, title, class, process name, style, geometry, tags and floating state.

`Config_hotkey=#+i::Manager_getWindowList()`
> _Get a window list_ for the active view.
    The list contains information about the window id, title and class.

`Config_hotkey=!Down::View_moveWindow(0, +1)`
> Manually _move_ the active window _to the next area_ in the layout.
    This has only an effect, if dynamic tiling is disabled (`Config_dynamicTiling=0`).

`Config_hotkey=!Up::View_moveWindow(0, -1)`
> Manually _move_ the active window _to the previous area_ in the layout.
    This has only an effect, if dynamic tiling is disabled (`Config_dynamicTiling=0`).

`Config_hotkey=!+Enter::Manager_maximizeWindow()`
> _Move and resize_ the active window _to_ the size of the _work area_.
    This implicitly sets the window to be floating.

`Config_hotkey=!<n>::View_moveWindow(<n>)`
> Manually _move_ the active window _to the n<sup><small>th</small></sup> area_ in
the layout.
    &lt;n&gt; can be an integer between 1 and 9. This has only an effect, if dynamic 
tiling is disabled (`Config_dynamicTiling=0`).

<!-- Theoreticaly, this function call seems not to be recognized.

`Config_hotkey=!0::View_moveWindow(10)`
> Manually _move_ the active window _to the n<sup><small>th</small></sup> area_ in
the layout.

This has only an effect, if dynamic tiling is disabled (`Config_dynamicTiling=0`).

-->

`Config_hotkey=!BackSpace::View_toggleStackArea()`
> Toggle the stack area of the layout. 

    If the stack area is toggled off, the master area takes up the whole view and the 
    stack area cannot be used to position windows.

    This has only an effect, if dynamic tiling is disabled (`Config_dynamicTiling=0`).

### Window debugging

`Config_hotkey=#^i::Debug_logViewWindowList()`
> _Dump_ window information on the _windows of the active view_ to the log.

`Config_hotkey=#^+i::Debug_logManagedWindowList()`
> _Dump_ window information on the _managed windows_ to the log.

    The list of managed windows contains the floating and tiled windows of all views.

`Config_hotkey=#^h::Debug_logHelp()`
> _Print column headings_ to the log.

    The column headings give a description of the formatting used in the previous 
    two hotkeys being `Manager_logViewWindowList` and  `Manager_logManagedWindowList`.

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
> Set the _previous_-ly set _layout_. 

You may also use `View_setLayout(0, +1)` for setting the next or 
`View_setLayout(0, -1)` for setting the previous layout in the layout array.

`Config_hotkey=#f::View_setLayout(3)`
> Set the _floating layout_.

`Config_hotkey=#m::View_setLayout(2)`
> Set the _monocle layout_.

`Config_hotkey=#t::View_setLayout(1)`
> Set the _tile layout_.

`Config_hotkey=#Left::View_setLayoutProperty(MFactor, 0, -0.05)`
> _Reduce_ the size of _the master area_ in the active view.

    This has only an effect, if the tile layout is active.

    You may also set an additional parameter for accelerating the third one. E. g. 
    with `Config_hotkey=#Left::View_setLayoutProperty(MFactor, 0, -0.05, 2)` the 
    first step, by which the master area is reduced, is -0.0016% and will be 
    doubled with consecutive calls until it reaches -0.05%.
    With the second parameter you may set an absolute value, e. g.
    `View_setLayoutProperty(MFactor, 0.5, 0)` splits the view in half.

`Config_hotkey=#Right::View_setLayoutProperty(MFactor, 0, +0.05)`
> _Enlarge_ the size of _the master area_ in the active view.

    This has only an effect, if the tile layout is active.

    You may also set a additional parameter for accelerating the third one. E. g. 
    with `Config_hotkey=#Right::View_setLayoutProperty(MFactor, 0, +0.05, 0.5)` the
    first step, by which the master area is reduced, is 0.05%, but with consecutive
    calls it will be halved until it reaches 0.0016%.
    With the second parameter you may set an absolute value, e. g.
    `View_setLayoutProperty(MFactor, 0.67, 0)` makes the master area two thirds
    and the stacking area one third the size of the view.

`Config_hotkey=#^t::View_setLayoutProperty(Axis, 0, +1, 1)`
> Rotate the layout axis.

    I. e. 2 -> 1 = vertical layout, 1 -> 2 = horizontal layout.
    
    This has only an effect, if the tile layout is active.

`Config_hotkey=#^Enter::View_setLayoutProperty(Axis, 0, +2, 1)`
> Mirror the layout axis.

    I. e. -1 -> 1 / 1 -> -1 = master on the left / right side, 
    -2 -> 2 / 2 -> -2 = master at top / bottom.

    This has only an effect, if the tile layout is active.

`Config_hotkey=#^Tab::View_setLayoutProperty(Axis, 0, +1, 2)`
> Rotate the master axis.

    I. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 
    2 -> 3 = z-axis = monocle.
    
    This has only an effect, if the tile layout is active.

`Config_hotkey=#^+Tab::View_setLayoutProperty(Axis, 0, +1, 3)`
> Rotate the stack axis.

    I. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 
    2 -> 3 = z-axis = monocle.
    
    This has only an effect, if the tile layout is active.

`Config_hotkey=#^Up::View_setLayoutProperty(MY, 0, +1)`
> Increase the master Y dimension.

    This results in an increased number of windows in the master area by X. 
    Maximum of 9.
    
    This has only an effect, if the tile layout is active.

`Config_hotkey=#^Down::View_setLayoutProperty(MY, 0, -1)`
> Decrease the master Y dimension.

    This results in a decreased number of windows in the master area by X. 
    Minimum of 1.
    
    This has only an effect, if the tile layout is active.

`Config_hotkey=#^Right::View_setLayoutProperty(MX, 0, +1)`
> Increase the master X dimension.

    This results in an increased number of windows in the master area by Y. 
    Maximum of 9.
    
    This has only an effect, if the tile layout is active.

`Config_hotkey=#^Left::View_setLayoutProperty(MX, 0, +1)`
> Decrease the master X dimension.

    This results in a decreased number of windows in the master area by Y. 
    Minimum of 1.
    
    This has only an effect, if the tile layout is active.

`Config_hotkey=#+Left::View_setLayoutProperty(GapWidth, 0, -2)`
> _Decrease the gap between windows_ in "monocle" and "tile" layout. 

    You may also set an absolute value for the gap width by using the first 
    parameter, e. g. `View_setLayoutProperty(GapWidth, 0, 0)` will eliminate the 
    gap and `View_setLayoutProperty(GapWidth, 20, 0)` will set it to 20px.

`Config_hotkey=#+Right::View_setLayoutProperty(GapWidth, 0, +2)`
> _Increase the gap between windows_ in "monocle" and "tile" layout.

### View / Tag management

`Config_hotkey=#+n::View_toggleMargins()`
> Toggle the view margins.

    These are set by the configuration variable `Config_viewMargins`.

`Config_hotkey=#BackSpace::Monitor_activateView(-1)`
> Activate the previously activated view. 

    You may also use `Monitor_activateView(0, -1)` or `Monitor_activateView(0, +1)` 
    for activating the previous or next adjacent view.

`Config_hotkey=#+0::Monitor_setWindowTag(10)`
> Tag the active window with all tags. 

`Config_hotkey=#<n>::Monitor_activateView(<n>)`
> Activate the n<sup><small>th</small></sup> view.

&lt;n&gt; can be an integer between 1 and `Config_viewCount`.

`Config_hotkey=#+<n>::Monitor_setWindowTag(<n>)`
> Tag the active window with the n<sup><small>th</small></sup> tag.

    &lt;n&gt; can be an integer between 1 and `Config_viewCount`.
    
    You may also use `Monitor_setWindowTag(0, -1)` or `Monitor_setWindowTag(0, +1)` 
    for setting the tag of the previous or next adjacent to the current view.

`Config_hotkey=#^<n>::Monitor_toggleWindowTag(<n>)`
> Add / Remove the n<sup><small>th</small></sup> tag for the active window, if 
it is not / is already set.

    &lt;n&gt; can be an integer between 1 and `Config_viewCount`.

### Monitor management

`Config_hotkey=#.::Manager_activateMonitor(0, +1)`
> Activate the _next monitor_ in a multi-monitor environment. 

    You may also activate a specific monitor by using the first parameter, e. g.
`Manager_activateMonitor(1)` will activate the first monitor.

`Config_hotkey=#,::Manager_activateMonitor(0, -1)`
> Activate the _previous monitor_ in a multi-monitor environment.

`Config_hotkey=#+.::Manager_setWindowMonitor(0, +1)`
> _Set_ the active window's view _to_ the active view on _the next monitor_ in a
multi-monitor environment. 
    
    You may also set the active window on a specific monitor by using the first 
    parameter, e. g. `Manager_setWindowMonitor(1)` will set the active window on 
    the first monitor.

`Config_hotkey=#+,::Manager_setWindowMonitor(0, -1)`
> _Set_ the active window's view _to_ the active view on _the previous monitor_ in a
multi-monitor environment.

`Config_hotkey=#^+.::Manager_setViewMonitor(0, +1)`
> _Set all windows_ of the active view _on_ the active view of _the next monitor_ in
a multi-monitor environment. 

    You may also set all windows of the active view on a specific monitor by using 
    the first parameter, e. g. `Manager_setViewMonitor(1)` will set all windows of 
    the active view on the first monitor.

`Config_hotkey=#^+,::Manager_setViewMonitor(0, -1)`
> _Set all windows_ of the active view _on_ the active view of _the previous monitor_
in a multi-monitor environment.

### GUI management

`Config_hotkey=#+Space::Monitor_toggleBar()`
> _Hide / Show the bar_ (bug.n status bar) on the active monitor.

`Config_hotkey=#Space::Monitor_toggleTaskBar()`
> Hide / Show the task bar.

`Config_hotkey=#y::Bar_toggleCommandGui()`
> _Open the command GUI_ for executing programmes or bug.n functions.

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
> _Save the current state_ of monitors, views, layouts to the configuration file.

`Config_hotkey=#^r::Reload`
> _Reload_ bug.n (i. e. the whole script).

    This resets i. a. the configuration and internal variables of bug.n, including 
    the window lists. It is like Quitting and restarting bug.n.
    If `Config_autoSaveSession` is not set to `off`, the window lists can be
    restored and windows are put to their associated monitor and views.

`Config_hotkey=#^q::ExitApp`
> _Quit_ bug.n, restore the default Windows UI and show all windows.
