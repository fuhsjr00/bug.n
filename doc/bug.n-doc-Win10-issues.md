# Compatibility issues of bug.n with Windows 10


## Issues

1. Windows-Class "ApplicationFrameWindow": Calculator, Edge, Photos, Settings
  Those windows cannot completely be hidden; a frame in the Alt-Tab menu and the icon in the taskbar remains.

2. bug.n bar
  The bug.n bar is sometimes (regularly) overlayed by the windows taskbar and therefor not visible, if it is set to "tray" in Config.ini, i. e. a child window of the taskbar.

3. Resized windows at the bottom right screen corner
  If a window is at the bottom or right of the screen and positioned right to the edge and the pointer is moved over the right or bottom border, the window is resized to leave space to the edge of the screen.
  This also takes effect, if bug.n is not running.

4. Using a single view and Windows' virtual desktops
  * Layouts are saved per view, i. e. one for all virtual desktops; the virtual desktops are not fit for different workflows. Even with manual tiling this does not work.
  * Window lists are saved per view, leaving blank space in a tiled layout.

5. Using at least one view per virtual desktop
  Windows are hidden/ shown when switching views, therewith showing windows from other virtual desktops, making it very messy.


## Personal preferences

1. Alt-Tab menu, but without having to "tab" through more than four windows. => Group windows on virtual desktops or views.
  I am often using stacked windows (i. e. all windows have the same x, y, width and height), therewith only one window is visible at any time; cycling through the windows in the layout (Win+Up/Down) is not that helpful in getting to the wanted window.

2. The system tray contains icons with necessary functionality.

3. A solution is only needed for Windows and therefor a cross-platform window manager is not necessary.

4. Currently, I am using three virtual desktops; with bug.n I used four views.

  
## Conclusion

* i1./p1. => Do not use "show/ hide window", use Windows' virtual desktops instead.
  But there is no sufficient API for Windows' virtual desktops; only "GetWindowDesktopId", "IsWindowOnCurrentVirtualDesktop" and "MoveWindowToDesktop".
  - "MoveWindowToDesktop" only works with windows, for which the application is the owner.
  - If there is not any window on a specific virtual desktop, it cannot be recognized.
  - => There is no knowledge about all given virtual desktops at every time.
  - => Windows can only be moved by pointing device or via the (automated, with a lot of counting steps) means Windows provides in context menus between virtual desktops.

* i2. => Remove the feature `Config_verticalBarPos=tray`.

* p2. => Leave the Windows taskbar visible.

* i3. => Remove window borders?

* p1./p2./p3. => The missing functionality is "tiling window management" and maybe a status bar for showing bug.n's and additional information (compared to the Windows system tray).

* Make bug.n like [Wmutils](https://github.com/wmutils/core), primarily writing the status to text files?
