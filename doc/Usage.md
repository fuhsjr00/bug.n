## Using bug.n

bug.n is mostly controlled with hotkeys. The available hotkeys are listed in
the document "[Default hotkeys](./Default_hotkeys.md)". For a quick help there
are the following hotkeys:

* `#y` (<kbd>Win</kbd><kbd>Y</kbd>): Show the command GUI, which allows you to
enter bug.n-functions.
* `#Space` (<kbd>Win</kbd><kbd>Space</kbd>): Show / Hide the Windows Taskbar.
* `#^q` (<kbd>Win</kbd><kbd>Ctrl</kbd><kbd>Q</kbd>): Quit bug.n and restore all
windows and Windows UI elements.

The following functions can also be controlled with the mouse:

* With a click on a tag (a number on the left end of the bug.n bar) you can
change the view and show only the windows associated with that tag.
* With a right-click on a tag you can tag the active window with that tag.
* With a click on the layout symbol in the bug.n bar you can toggle the layout
to the last one used.
* With a right-click on the layout symbol you can set the layout to the next in
the list.
* A function can be selected from a list or entered in the command GUI, which
is accessible by clicking on `#!` on the right end of the bug.n bar.

You may also send commands to bug.n from another AutoHotkey script. The sent
string is interpreted and executed by bug.n as one or more (separated by the
newline character) either bug.n-functions (as used in the hotkey configuration)
or AutoHotkey-commands (only `Run` or `Send`). For example, you may use the
following lines in an AutoHotkey script:

    ;; The following line is required.
    DetectHiddenWindows, On

    ;; Syntax:
    ;; ControlSetText, Edit2, % "<function name>(<arguments>)", bug.n_BAR_0

    ;; 1st example:
    ;ControlSetText, Edit2, % "Monitor_activateView(4)", bug.n_BAR_0

    ;; 2nd example:
    ;ControlSetText, Edit2, % "Monitor_activateView(4)`nView_setLayout(3)", bug.n_BAR_0

    ;; 3rd example:
    ControlSetText, Edit2, % "Monitor_activateView(4)`nRun, explorer.exe", bug.n_BAR_0

It might be necessary to put a `Sleep, <delay in milliseconds>`, e.g.
`Sleep, 200`, between to consecutive `ControlSetText` to give bug.n time to
recognize the next command.

### Concepts

#### Layouts

bug.n provides three layouts.

* **tile**: A master area for the main window(s) and a stacking area for the
rest, all windows are shown at any time. This layout can be further changed in
the following respects:
  + the dimensions of the master area (1x1 ... 2x3 ... 9x9)
  + the stacking direction of the master and stacking area (from left to right,
  from top to bottom or monocle)
  + the position of the master area (left, top, right or bottom) and
  accordingly the position of the stacking area
  + the witdh or height of the master area (depending on its position)
* **monocle**: All windows are maximized and only one is shown at any time.
+ **floating**: Do not tile any window.

Please see the document "[Default hotkeys](./Default_hotkeys.md)" for a list of
hotkeys and their associated functions, with which you can set and manipulate
layouts.

#### Tagging

bug.n features an extended implementation of virtual desktops: _tagging_.

Windows are tagged with one or more numbers, which determine on which views
they are shown. Selecting a view shows the windows tagged with the same number
and hides all other windows.

#### Session management

bug.n features a session management, which is used for saving configuration
variables, hotkeys and internal variables; it does not restore applications,
you will have to run them manually. The configuration variables may include
those listed in the document
"[Default configuration](./Default_configuration.md)", hotkeys as
listed in the document "[Default hotkeys](./Default_hotkeys.md)" and internal
variables for the current state of bug.n, e.g. the active view (saved for each
monitor), the layout and its configuration (saved for each view) and window
states as they could be set by a rule.
