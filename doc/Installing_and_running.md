## Installing and running bug.n

#### Requirements

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

You may copy bug.n anywhere you like -- at least if you have write access 
there -- e.g. `C:\Program Files\bugn` or link it to the 'Windows Start Menu'
or the 'Windows Taskbar', for example.

By default bug.n stores the session data (configuration, layout, window states
and log) to the user's APPDATA directory, e.g.
`C:\Users\joten\AppData\Roaming\bug.n`.

You may redirect the bug.n data directory by setting the first argument either
to the executable or to the main script (`Main.ahk`), when running bug.n,
e.g. `C:\Program Files\bugn\bugn.exe D:\bugn`; but you will need to have write
access to this directory.

You can run bug.n manually, either by using the executable and starting it like
any other application, or by using the main script (`Main.ahk`) and starting it
with [AutoHotkey](http://ahkscript.org/download/).
If using the script, the working directory must be the directory, where the
file `Main.ahk` is saved; therewith bug.n can find the other script files. One
possibility, to do so, is to install AutoHotkey, open the directory, where
`Main.ahk` is saved, and execute the file.

### Microsoft Windows User Access Control

If you are using bug.n on Microsoft Windows Vista or higher you may use
applications, which run with administrator privileges, e.g. 'administrative
tools'. In the case that you are running bug.n in the standard user session,
i.e. _without_ administrator privileges, bug.n will not be able to manage the
associated windows. If you want those application windows to be managed, you
need to run bug.n with administrator privileges, too.
You can set the option `Run this program as an administrator` on the
'Compatibility' tab, section 'Privilege level' of the bug.n executable file
properties. But if you also want to run bug.n when Windows starts, you will
have to create a task in 'Task Scheduler'.

#### Create a task in 'Task Scheduler'

In Windows 7 you can create a task following the steps from the
[Windows website](http://windows.microsoft.com/en-us/windows/schedule-task#1TC=windows-7):

1. Open Task Scheduler by clicking the **Start** button, clicking
**Control Panel**, clicking **System and Security**, clicking
**Administrative Tools**, and then double-clicking **Task Scheduler**
(Administrator permission required). If you're prompted for an administrator
password or confirmation, type the password or provide confirmation.
2. Click the **Action** menu, and then click **Create Basic Task**.
3. Type a name for the task and an optional description, and then click
**Next**.
4. Click **When I log on**, and then click **Next**.
5. To schedule a program to start automatically, click **Start a program**, and
then click **Next**.
6. Click **Browse** to find the program you want to start, and then click
**Next**.
7. Select the **Open the Properties dialog for this task when I click Finish**
check box and click **Finish**.
8. In the **Properties** dialog box, select the following, and then click
**OK**.
   * **Run only when user is logged on**
   * **Run with highest privileges**
