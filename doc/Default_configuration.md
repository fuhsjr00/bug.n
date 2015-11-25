## Default setting of configuration variables

The configuration variables, as you can set them in `Config.ini`, are noted in
the format `Conifg_<identifier>=<value>`; you may copy the string from ` ` and
use it as a template for a new line in `Config.ini`.

### Status bar

`Config_showBar=1`
> If false (`=0`), the bar is hidden. It can be made visible or hidden by hotkey
(see below).

`Config_horizontalBarPos=left`
> The horizontal position of the bar: center, left or right side of the monitor
or an offset in pixel (px) from the left (>= 0) or right (< 0).

`Config_verticalBarPos=top`
> The vertical position of the bar: top or bottom of the monitor, tray =
sub-window of the task bar.

`Config_barWidth=100%`
> The width of the bar in pixel (px) or with a per cent sign (%) as a
percentage.

`Config_singleRowBar=1`
> If false, the bar will have to rows, one for the window title and one for all
other GUI controls.

`Config_spaciousBar=0`
> If true, the height of the bar will be set to a value equal to the height of
an edit control, else it will be set to the text height.

`Config_fontName=Lucida Console`
> A monospace font is preferable for bug.n to calculate the correct width of
the bar and its elements (sub-windows).

`Config_fontSize=`
> Font size in pixel. The default value is retrieved from the "Window Color and
Appearance" settings for the "Active Title Bar".

`Config_largeFontSize=24`
> Font size in pixel, i. a. for the numbering of areas in the area trace.

`Config_backColor_#1=<COLOR_GRADIENTINACTIVECAPTION>;<COLOR_ACTIVECAPTION>;<COLOR_MENU>;<COLOR_ACTIVECAPTION>;<COLOR_MENU>;<COLOR_ACTIVECAPTION>;<COLOR_GRADIENTINACTIVECAPTION>;<COLOR_GRADIENTACTIVECAPTION>;<COLOR_GRADIENTACTIVECAPTION>`
> The default background color for bar elements. The value for this and the
other (following) color related configuration variables is a semicolon
separated list, which contains the following items:

* view
* layout
* title
* shebang
* time
* date
* "any text"
* battery status
* volume level

`Config_backColor_#2=<COLOR_GRADIENTACTIVECAPTION>;;;;;;;<COLOR_MENU>;<COLOR_MENU>`
> The background color of bar elements, which are highlighted depending on the
status, i. a. the active view, a discharging battery and the sound volume, if
it is not muted.

`Config_backColor_#3=;;;;;;;ff8040;`
> The background color of bar elements, which are highlighted depending on the
status, i. a. a discharging battery with a battery level lower than 10%.

`Config_foreColor_#1=<COLOR_INACTIVECAPTION>;<COLOR_ACTIVECAPTION>;<COLOR_MENU>;<COLOR_ACTIVECAPTION>;<COLOR_MENU>;<COLOR_ACTIVECAPTION>;<COLOR_INACTIVECAPTION>;<COLOR_ACTIVECAPTION>;<COLOR_GRADIENTINACTIVECAPTION>`
> The default forground color of bar elements. Every bar element consists of a
progress bar with a background and a foreground; the visible part of the
foreground depends on the value of the progress bar.

`Config_foreColor_#2=<COLOR_ACTIVECAPTION>;;;;;;;<COLOR_HIGHLIGHT>;<COLOR_HIGHLIGHT>`
> The foreground color of bar elements, which are highlighted depending on the
status, i. a. the active view, a discharging battery and the sound volume, if
it is not muted.

`Config_foreColor_#3=;;;;;;;<COLOR_INACTIVECAPTION>;`
> The foreground color of bar elements, which are highlighted depending on the
status, i. a. a discharging battery with a battery level lower than 10%.

`Config_fontColor_#1=<COLOR_INACTIVECAPTIONTEXT>;<COLOR_CAPTIONTEXT>;<COLOR_MENUTEXT>;<COLOR_CAPTIONTEXT>;<COLOR_MENUTEXT>;<COLOR_CAPTIONTEXT>;<COLOR_INACTIVECAPTIONTEXT>;<COLOR_CAPTIONTEXT>;<COLOR_INACTIVECAPTIONTEXT>`
> The default font color for the text of bar elements.

`Config_fontColor_#2=<COLOR_CAPTIONTEXT>;;;;;;;<COLOR_MENUTEXT>;<COLOR_MENUTEXT>`
> The font color of bar elements, which are highlighted depending on the
status, i. a. the active view, a discharging battery and the sound volume, if
it is not muted.

`Config_fontColor_#3=;;;;;;;<COLOR_INACTIVECAPTIONTEXT>;`
> The fontground color of bar elements, which are highlighted depending on the
status, i. a. a discharging battery with a battery level lower than 10%.

The default color values are retrieved from the "Window Color and Appearance"
settings.

`Config_barTransparency=off`
> The degree of transparency for the bar. Possible values are `off` (no
transparency) or an integer between `0` (fully transparent) and `255` (opaque).
At least on Windows >= 8 with `Config_verticalBarPos=tray` the bar won't be
visible at all, if `Config_barTransparency` is not set to `off`.

`Config_barCommands=Run, explore doc;Monitor_toggleBar();Reload;ExitApp`
> The commands seperated by semicolon, which are listed in the command GUI of
the bar (#!) and therewith can be selected rather then typed; bug.n functions
(as used in the hotkey configuration), the `Run` and `Send` command of
AutoHotkey can be used here.

`Config_readinBat=0`
> If true (`=1`), the system battery status is read in and displayed in the
status bar. This only makes sense, if you have a system battery (notebook).

`Config_readinCpu=0`
> If true (`=1`), the current CPU load is read in and displayed in the status bar.

`Config_readinDate=1`
> If true (`=1`), the current date is read in (format: "ddd, dd. MMM. yyyy") and
displayed in the status bar.

`Config_readinDateFormat=ddd, dd. MMM. yyyy`
> The format in which the date, if it is read in, should be displayed. Please see
the documentation at 
[autohotkey.com](https://www.autohotkey.com/docs/commands/FormatTime.htm#Date_Formats_case_sensitive)
for a description of the string components.

`Config_readinDiskLoad=0`
> If true (`=1`), the current disk load (read and write) is read in and displayed
in the status bar.

`Config_readinMemoryUsage=0`
> If true (`=1`), the system memory usage is read in and displayed in the status
bar.

`Config_readinNetworkLoad=0`
> If not false (`=0`) and given an identifying string for the network interface,
which should be monitored, the current network load (up and down) is read in
and displayed in the status bar.

`Config_readinTime=1`
> If true (`=1`), the current time is read in (format: "HH:MM") and displayed in
the status bar.

`Config_readinTimeFormat=HH:mm`
> The format in which the time, if it is read in, should be displayed. Please see
the documentation at 
[autohotkey.com](https://www.autohotkey.com/docs/commands/FormatTime.htm#Time_Formats_case_sensitive)
for a description of the string components.

`Config_readinVolume=0`
> If true (`=1`), the current sound volume is read in
(format: "VOL: <mute> <volume percentage>") and displayed in the status bar.

`Config_readinInterval=30000`
> Time in milliseconds after which the above status values are refreshed.

### Windows ui elements

`Config_bbCompatibility=0`
> If true (`=1`), bug.n looks for BlackBox components (bbLeanBar, bbSlit and
SystemBarEx) when calculating the work area. It is assumed that the virtual
desktop functionality of BlackBox and NOT bug.n is used (=> Hiding and showing
windows is detected and acted upon).

`Config_borderWidth=0`
> If > 0, the window border width is set to the given integer value.

`Config_borderPadding=-1`
> If >= 0, the window border padding is set to the given integer value (only
for Windows >= Vista).

`Config_showTaskBar=0`
> If false (`=0`), the task bar is hidden. It can be made visible or hidden by
hotkey (see below).

`Config_showBorder=1`
> If false (`=0`), the window borders are hidden; therefor windows cannot be
resized manually by dragging the border, even if using the according hotkey.

`Config_selBorderColor=`
> Border colour of the active window; format: 0x00BBGGRR (e. g. `0x006A240A`,
if =0, the system's window border colour is not changed).

### Window arrangement

`Config_viewNames=1;2;3;4;5;6;7;8;9`
> The names of the views separated by a semicolon. This variable sets the names
of the views shown in the status bar and determines the number of views
(`Config_viewCount`); the total number of names given, i. e. views, should not
be exceeded by the configured hotkeys.

    Config_layout_#1=[]=;tile
    Config_layout_#2=[M];monocle
    Config_layout_#3=><>;
> The layout symbol and arrange function (the first entry is set as the default
layout, no layout function means floating behavior)

`Config_layoutCount=3`
> Total number of layouts defined above.

`Config_layoutAxis_#1=1`
> The layout axis: 1 = x, 2 = y; negative values mirror the layout, setting the
master area to the right / bottom instead of left / top.

`Config_layoutAxis_#2=2`
> The master axis: 1 = x (from left to right), 2 = y (from top to bottom),
3 = z (monocle).

`Config_layoutAxis_#3=2`
> The stack axis:  1 = x (from left to right), 2 = y (from top to bottom),
3 = z (monocle).

`Config_layoutGapWidth=0`
> The default gap width in px (only even numbers) used in the "tile" and
"monocle" layout, i. e. the space between windows and around the layout.

`Config_layoutMFactor=0.6`
> The factor for the size of the master area, which is multiplied by the
monitor size.

`Config_areaTraceTimeout=1000`
> The time in milliseconds, for which the area trace is shown.
The area trace indicates the areas in the "tile" layout, which can be used to
manually resize and position windows by hotkey. See also `View_moveWindow(<n>)`
and `View_traceAreas()` in the listing of hotkeys.

`Config_continuouslyTraceAreas=0`
> If true (`=1`), the area trace is continuously shown over the desktop.

`Config_dynamicTiling=1`
> If true (`=1`), windows are dynamically tiled i. e. the layout is reset and
therewith all windows resized and positioned automatically, if new windows are
created or existing destroyed or moved.
If false (`=0`) you may use manual tiling.

`Config_ghostWndSubString= (Not Responding)`
> The text string, which identifies a hung window in its title bar; the german
Windows version uses " (Keine Rückmeldung)".

`Config_mFactCallInterval=700`
> The time in milliseconds, in which two consecutive calls to
`View_setLayoutProperty("MFactor", 0, <d>, <dFact>)` have to be made, to
accelerate the increasing or decreasing of `mfact`. See also
`View_setLayoutProperty("MFactor", 0, <d>, <dFact>)` in the listing of hotkeys.

`Config_mouseFollowsFocus=1`
> If true (`=1`), the mouse pointer is set over the focused window, if a window
is activated by bug.n.

`Config_newWndPosition=top`
> The position of a new window in a view; `top`: at the beginning of the window
list and the master area (default), `masterBottom`: at the end of the master
area, `stackTop`: on top of the stack area, `bottom`: at the end of the window
list and the stack area.

`Config_onActiveHiddenWnds=view`
> The action, which will be taken, if a window e. g. should be activated, but
is not visible; `view`: show the view accordng to the first tag of the window
in question, `tag`: add the window in question to the current visible view,
`hide`: hide the window again ignoring the activation.

`Config_shellMsgDelay=350`
> The time bug.n waits after a shell message (a window is opened, closed or the
focus has been changed); if there are any problems recognizing, when windows
are opened or closed, try to increase this number.

`Config_syncMonitorViews=0`
> The number of monitors (2 or more), for which views should be activated, when
using the accordant hotkey. If set to 1, the views are activated for all
monitors. If set to 0, views are activated independently (only on the active
monitor).

`Config_viewFollowsTagged=0`
> If true (`=1`) and a window is tagged with a single tag, the view is
correspondingly set to the tag.

`Config_viewMargins=0;0;0;0`
> The margin of a view (around the layout, "monocle" and "tile") as a semicolon
separated list of values in px (top;right;bottom;left), which by default can be
activated per view with the hotkey <kbd>Win</kbd><kbd>Shift</kbd><kbd>N</kbd>
(`View_toggleMargins`). With view margins you may create an empty area on the
monitor, which is not occupied by the layout, therewith making a desktop widget
visible.

### Rules

For a general description of rules and how they can be replaced or added see
the [specific documentation](./Configuring_rules.md).

`Config_rule_#1=.*;.*;;1;0;0;0;0;0;`
> By default all windows are managed, not allocated on a specific monitor or
view, not floating (i. e. tiled), the window title bar is not visible, the
title is not hidden on the bug.n status bar and no window action is taken, when
the window first is created.

`Config_rule_#2=.*;.*;Window_isChild;0;0;0;1;1;1;`
> Child windows (style WS_CHILD) will not be managed, are floating and the
titles are hidden.

`Config_rule_#3=.*;.*;Window_isPopup;0;0;0;1;1;1;`
> Pop-up windows (style WS_POPUP) will not be managed, are floating and the
titles are hidden.

`Config_rule_#4=QWidget;.*;;1;0;0;0;0;0;`
> Windows created by QT (QWidget) have the style WS_POPUP, but should be
excluded from the preceding rule.

`Config_rule_#5=SWT_Window0;.*;;1;0;0;0;0;0;`
> Also windows created by Java (SWT) e. g. Eclipse should be excluded from the
second rule for the same reason as above.

`Config_rule_#6=Xming;.*;;1;0;0;0;0;0;`
> Also Xming windows should be excluded from the second rule for the same
reason as above.

    Config_rule_#7=MsiDialog(No)?CloseClass;.*;;1;0;0;1;1;0;
    Config_rule_#8=AdobeFlashPlayerInstaller;.*;;1;0;0;1;0;0;

`Config_rule_#9=CalcFrame;.*;;1;0;0;1;1;0;`
> Windows calculator.

`Config_rule_#10=CabinetWClass;.*;;1;0;0;0;1;0;`
> Windows Explorer. If the window's title bar is hidden, it looks distorted.

`Config_rule_#11=OperationStatusWindow;.*;;0;0;0;1;1;0;`
> Windows Explorer dialog.These windows should also be treated as pop-up
windows.

`Config_rule_#12=Chrome_WidgetWin_1;.*;;1;0;0;0;1;0;`
> Chrome web browser. If the window's title bar is hidden, it looks distorted.

`Config_rule_#13=Chrome_WidgetWin_1;.*;Window_isPopup;0;0;0;1;1;0;`
> With the preceding rule overriding #2 Chrome pop-up windows would be treated
as new main windows.

`Config_rule_#14=Chrome_RenderWidgetHostHWND;.*;;0;0;0;1;1;0;`
> These windows may represent new tabs, which should not be treated as new
windows.

`Config_rule_#15=IEFrame;.*Internet Explorer;;1;0;0;0;1;0;`
> Internet Explorer. If the window's title bar is hidden, it looks distorted.

`Config_rule_#16=MozillaWindowClass;.*Mozilla Firefox;;1;0;0;0;1;0;`
> Firefox web browser. If the window's title bar is hidden, it looks distorted.

`Config_rule_#17=MozillaDialogClass;.*;;1;0;0;1;1;0;`
> These windows should also be treated as pop-up windows.

`Config_ruleCount=17`
> This variable will be automatically set to the total number of active rules
above.

### Configuration management

`Config_autoSaveSession=auto`
> Automatically save the current state of monitors, views, layouts (active
view, layout, axes, mfact and msplit) and windows to the configuration files in
the data directory of bug.n. Possible values are `off`, `auto` and `ask`.

`Config_maintenanceInterval=5000`
> The interval in milliseconds, in which the session will be automatically
saved to especially support the recovery of window states after bug.n
unintentionally quits.
