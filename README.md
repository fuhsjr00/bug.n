## bug.n -- Tiling Window Manager

bug.n is a
[tiling window manager](https://en.wikipedia.org/wiki/Tiling_window_manager)
add-on for Microsoft Windows. It is written in the scripting language
[AutoHotkey](http://ahkscript.org/download/).

### What it can do

* Provide layouts for resizing and moving windows, utilizing all available
  screen estate and customizable to your specific needs and workflow
* Provide views (i. e. virtual desktops) for showing only those windows, which
  you need to do your work.
* Dynamically resize and move your windows, applying a specified layout,
  without you having to care about moving them all by mouse
* Increase the available screen estate by hiding and therewith freeing up the
  space occupied by the Microsoft Windows Taskbar and the title bar for every
  single window and replacing all with a single slim status bar (-- but bug.n
  is not a shell replacement)
* Show window management information in the status bar: active window title,
  active layout, overview of the views used
* Show system information in the status bar: time and date, CPU and memory
  usage, disk and network load, battery and volume level
* Store your settings, i. e. which windows and layout were set on a specific
  view
* Support multiple monitors

### What it enables _you_ to do

* You can resize and move windows specified by the active layout and
  initialized by hotkey.
* You can toggle the visibility of the Windows Taskbar.
* You can toggle the visibility of the Windows title bar of the active window.
* You can change the layout for the tiling window management suitable to your
  needs.
  + **Tile**: Lay out all windows like tiles on a master area, which can be
   further split up, and a stacking area, where remaining windows can be stacked
   or shown side by side.
  + **Monocle**: All windows are maximized and only one is shown at any time.
  + **Floating**: Windows are not dynamically tiled.
* You can further customize the layouts for each view.
* You can move windows to another view (virtual desktop) by tagging them with a
  number.
* You can share windows between views by tagging them with more than one
  number.
* You can move between views, hiding the windows, you do not want to see, and
  showing those, you want to see, by pressing a simple hotkey.

### What it can look like

![bug.n screenshot](./doc/screenshots/default_01.png "Screenshot of bug.n with the default configuration.")

### Installing and running bug.n

##### Requirements

* Microsoft Windows 2000 or higher
* [AutoHotkey](http://ahkscript.org/download/) 1.1.10 or higher (if running
  bug.n from source as a script)

You may either
[download the stable version of bug.n](https://github.com/fuhsjr00/bug.n/releases/latest)
from the repository, or
[download the current development version](https://github.com/fuhsjr00/bug.n/archive/master.zip)
as the repository itself. Either way, you will have a `zip` file including an
executable (`bugn.exe`), the source (`src\*`) and documentation (`doc\*`)
files.

There is no installation process for bug.n. Unpack the `zip` file, and you
should be able to run either the executable as it is or the main script
(`src\Main.ahk`) with [AutoHotkey](http://ahkscript.org/download/).

### Documentation

Please see the [documentation](./doc) for more information on
[installing and running](./doc/Installing_and_running.md),
[customizing](./doc/Customization.md) and [using](./doc/Usage.md) bug.n and for
a list of [changes](./doc/CHANGES.md) made with the current version, in
particular the changes in the user interface
([configuration variables](./doc/Default_configuration.md) and
[hotkeys](./doc/Default_hotkeys.md)).

Please see the [CREDITS file](./doc/CREDITS.md) for a list of people and projects,
which contributed to bug.n.

### License

bug.n is licensed under the GNU General Public License version 3. Please see
the [LICENSE file](./LICENSE.md) for the full license text.
