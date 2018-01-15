## Customizing bug.n

bug.n can be customized by setting configuration variables and hotkeys (the key
bindings for the bug.n functions).

To change either of them, first create a configuration file (`Config.ini`) by
using the hotkey `#^s`, i.e. <kbd>Win</kbd><kbd>Ctrl</kbd><kbd>S</kbd>. The
file is either saved in the directory you specified with the parameter to the
executable or script when running bug.n, or in the Windows user directory
(e.g. `C:\Users\joten\AppData\Roaming\bug.n`).

You may then edit the file with a text editor, i.a. using the hotkey `#^e`
(<kbd>Win</kbd><kbd>Ctrl</kbd><kbd>E</kbd>), and add a new line for each
configuration variable with its value; the general format is
`<variable>=<value>` not using quotation marks surrounding the values.
If you want to set a boolean value, use `1` for "True" and `0` for "False";
e.g. `Config_showBar=0`. You will have to reload bug.n for the changes to take
effect.

To set a hotkey, use the variable name `Config_hotkey` and [the hotkey notation
from AutoHotkey](http://ahkscript.org/docs/Hotkeys.htm) as value:
`Config_hotkey=<key name>::<command or function name>`.
You may overwrite default or add new hotkeys.
* To deactivate a hotkey from the default configuration, add a new line in the
format `Config_hotkey=<key name>::` (without a function name).
* To assign an external program to a new hotkey, add a line in the general
format, using the `Run` command of AutoHotkey as described in
http://ahkscript.org/docs/commands/Run.htm (`Run, Target [, WorkingDir,
Max|Min|Hide|UseErrorLevel, OutputVarPID]`).
* You may also use the `Send` command of AutoHotkey as described in
http://ahkscript.org/docs/commands/Send.htm

The available configuration variables are listed in the document
"[Default configuration](./Default_configuration.md)"; the hotkeys with their
associated functions are listed in the document
"[Default hotkeys](./Default_hotkeys.md)".

You may find a sample and template configuration file on the Wiki page
[Configuration examples](https://github.com/fuhsjr00/bug.n/wiki/Configuration-examples).

### Re-using Win+L

The hotkey `#l` (<kbd>Win</kbd><kbd>L</kbd>) is set by Microsoft Windows to
lock the workstation. If you want to use it as a hotkey in bug.n, you can bind
another hotkey, e.g. `#^+l`
(<kbd>Win</kbd><kbd>Ctrl</kbd><kbd>Shift</kbd><kbd>L</kbd>), to the lock
function by using the bug.n-function `Manager_lockWorkStation()`, which i.a.
sets the registry key
`Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableLockWorkstation`
and locks the workstation. This than allows to set `#l` as a hotkey in
`Config.ini`.

If <kbd>Win</kbd><kbd>L</kbd> still locks the workstation, use the new
keybinding for locking the workstation at least once and therewith set the
needed registry key.

**WARNING**: This will permanently set a registry key.
