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
  space occupied by
  * the Microsoft Windows Taskbar and
  * the title bar for every single window
* and replacing all with a single slim status bar (-- but bug.n is not a shell
  replacement)
* Show window management information in the status bar:
  * active window title
  * active layout
  * overview of the views used
* Show system information in the status bar:
  * time and date
  * CPU and memory usage
  * disk and network load
  * battery level
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
  * **Tile**: Lay out all windows like tiles on a master area, which can be
   further split up, and a stacking area, where remaining windows can be stacked
   or shown side by side.
  * **Monocle**: All windows are maximized and only one is shown at any time.
  * **Floating**: Windows are not dynamically tiled.
* You can further customize the layouts for each view.
* You can move windows to another view (virtual desktop) by tagging them with a
  number.
* You can share windows between views by tagging them with more than one
  number.
* You can move between views, hiding the windows, you do not want to see, and
  showing those, you want to see, by pressing a simple hotkey.


### Installing and running bug.n

#### Requirements

* Microsoft Windows 2000 or higher

If running bug.n from source as a script:

* [AutoHotkey](http://ahkscript.org/download/)

There is no installation wizard for bug.n. If you downloaded the repository
from [GitHub](./) as a zip file and unpacked it, you should be able to run
either the executbale as it is or the main script (src\Main.ahk) with
[AutoHotkey](http://ahkscript.org/download/).

bug.n stores the session data (configuration, layout, window states and log) to
the user's APPDATA directory, e. g. C:\Users\joten\AppData\Roaming\bug.n.

Please see the [documentation](./doc) or the [Wiki](../../wiki) for more
information on installing and running, customizing and using bug.n and for a
list of changes made with the current version, in particular the changes in the
user interface (configuration variables and hotkeys).


### License

bug.n is licensed under the GNU General Public License version 3. Please see
the [LICENSE file](./LICENSE.md) for the full license text.


### Credits

bug.n and its documentation is written by Joshua Fuhs and joten, but some
source was copied from the AutoHotkey forum
(http://www.autohotkey.com/forum). These are explicitly marked in the source
code at the end of the appropriate section. Additionally the following listing
summarizes these sources (of ideas or code):

#### Patch ideas

* pitkali (http://pitkali.info/bugn):
  * Sync window arrays on fussy events and unknown window ids
  * Dialog detection upon manage
  * Regular expression support in rules
  * Window information handling patches
    * memory leaks
    * flickering windows

#### Ideas or concepts

* suckless.org: [dwm](http://dwm.suckless.org)
* jgpaiva: [GridMove](http://jgpaiva.donationcoders.com/gridmove.html)
* Lexikos: [WindowPad - multi-monitor window-moving tool](http://www.autohotkey.com/forum/topic21703.html)

#### Code snippets

* fures: [System + Network monitor - with net history graph](http://www.autohotkey.com/community/viewtopic.php?p=260329)
* maestrith: [Script Writer](http://www.autohotkey.net/~maestrith/Script Writer/)
* PhiLho: [AC/Battery status](http://www.autohotkey.com/forum/topic7633.html)
* Pillus: [System monitor (HDD/Wired/Wireless) using keyboard LEDs](http://www.autohotkey.com/board/topic/65308-system-monitor-hddwiredwireless-using-keyboard-leds/)
* Sean:
  * [CPU LoadTimes](http://www.autohotkey.com/forum/topic18913.html)
  * [Network Download/Upload Meter](http://www.autohotkey.com/community/viewtopic.php?t=18033)
* SKAN:
  * [Crazy Scripting : Quick Launcher for Portable Apps](http://www.autohotkey.com/forum/topic22398.html)
  * [HDD Activity Monitoring LED](http://www.autohotkey.com/community/viewtopic.php?p=113890&sid=64d9824fdf252697ff4d5026faba91f8#p113890)
  * [How to Hook on to Shell to receive its messages?](http://www.autohotkey.com/forum/viewtopic.php?p=123323#123323)
* Unambiguous: [Re-use WIN+L as a hotkey in bug.n](http://www.autohotkey.com/community/viewtopic.php?p=500903&sid=eb3c7a119259b4015ff045ef80b94a81#p500903)
