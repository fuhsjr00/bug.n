## bug.n default hotkeys

### Abbreviations

* `!` <kbd>Alt</kbd>
* `^` <kbd>Ctrl</kbd>, Control
* `#` <kbd>Win</kbd> / LWin, the left Windows key
* `+` <kbd>Shift</kbd>

### Window management

#### #Down
Activate the next window in the active view.

#### #Up
Activate the previous window in the active view.

#### #+Down
Move the active window to the next position in the window list of the view.

#### #+Up
Move the active window to the previous position in the window list of the view.

#### #+Enter
Move the active window to the first position in the window list of the view.

#### #c
Close the active window.

#### #+d
Show / Hide the title bar of the active window.

#### #+f
Toggle the floating status of the active window.

#### #^m
Minimize the active window.

#### #+m
Move the active window by key (only floating windows).

#### #+s
Resize the active window by key (only floating windows).

#### #+x
Move and resize the active window to the size of the work area (only floating
windows).

#### #i
Get information for the active window.

#### #+i
Get a window list for the active view.

#### !Down
Manually move the active window to the next area in the layout.

#### !Up
Manually move the active window to the previous area in the layout.

#### !+Enter
Move and resize the active window to the size of the work area (only floating
windows).

#### !&lt;n&gt;
Manually move the active window to the n<sup><small>th</small></sup> area in
the layout (n = 1..9).

#### !0
Manually move the active window to the n<sup><small>th</small></sup> area in
the layout.

#### !BackSpace
Toggle the stack area of the layout. 

### Window debugging

#### #^i
Dump window information on the windows of the active view to the log.

#### #+^i
Dump window information on the contents of the managed window list to the log.

#### #^h
Print a description of the formatting (column headings) used in the previous
two log messages to the log.

#### #^d
Decrement the debug log level. 

#### #^+d
Increment the debug log level. 

### Layout management

#### #Tab
Set the previously set layout. 

#### #f
Set the floating layout.

#### #m
Set the monocle layout.

#### #t
Set the tile layout.

#### #Left
Reduce the size of the master area in the active view (only for the "tile"
layout). 

#### #Right
Enlarge the size of the master area in the active view (only for the "tile"
layout). 

#### #^t
Rotate the layout axis (only for the "tile" layout).

#### #^Enter
Mirror the layout axis (only for the "tile" layout).

#### #^Tab
Rotate the master axis (only for the "tile" layout).

#### #^+Tab
Rotate the stack axis (only for the "tile" layout).

#### #^Up
Increase the master Y dimension by 1 (only for the "tile" layout).

#### #^Down
Decrease the master Y dimension by 1 (only for the "tile" layout).

#### #^Right
Increase the master X dimension by 1 (only for the "tile" layout).

#### #^Left
Decrease the master X dimension by 1 (only for the "tile" layout).

#### #+Left
Decrease the gap between windows in "monocle" and "tile" layout. 

#### #+Right
Increase the gap between windows in "monocle" and "tile" layout.

### View / Tag management

#### #+n
Toggle the view margins.

#### #BackSpace
Activate the previously activated view. 

#### #+0
Tag the active window with all tags (n = 1..`Config_viewCount`). 

#### #&lt;n&gt;
Activate the n<sup><small>th</small></sup> view (n = 1..`Config_viewCount`).

#### #+&lt;n&gt;
Tag the active window with the n<sup><small>th</small></sup> tag (n =
1..`Config_viewCount`).

#### #^&lt;n&gt;
Add / Remove the n<sup><small>th</small></sup> tag (n = 1..`Config_viewCount`)
for the active window, if it is not / is already set.

### Monitor management

#### #.
Activate the next monitor in a multi-monitor environment. 

#### #,
Activate the previous monitor in a multi-monitor environment.

#### #+.
Set the active window's view to the active view on the next monitor in a
multi-monitor environment. 

#### #+,
Set the active window's view to the active view on the previous monitor in a
multi-monitor environment.

#### #^+.
Set all windows of the active view on the active view of the next monitor in
a multi-monitor environment. 

#### #^+,
Set all windows of the active view on the active view of the previous monitor
in a multi-monitor environment.

### GUI management

#### #+Space
Hide / Show the bar (bug.n status bar) on the active monitor.

#### #Space
Hide / Show the task bar.

#### #y
Open the command GUI for executing programmes or bug.n functions.

#### #+y
Toggle the overflow window of the 'notify icons'.

#### !+y
Indicate the areas of the "tile" layout.

### Administration

#### #^e
Open the configuration file in the standard text editor. 

#### #^s
Save the current state of monitors, views, layouts to the configuration file.

#### #^r
Reload bug.n (i. e. the whole script).

#### #^q
Quit bug.n, restore the default Windows UI and show all windows.
