## Configuring rules

### General description

Not all windows should be managed by bug.n the same way, or even may not be
manageable at all. To handle windows differently, you can add rules to the
configuration.

The general format of a rule added to `Config.ini` is as follows (all in one
line, ";" is not allowed as a character in the field values):

```
Config_rule=<class>;
            <title>;
            <function name>;
            <is managed>;
            <monitor>;
            <views / tags>;
            <is floating>;
            <is decorated>;
            <hide title>;
            <action on a single window>
```

With the first part of the rule, you identify the window using the
following information:

1. class (as a regular expression)
2. title (as a regular expression)
3. arbitrary criterion (as a function name, e.g. "Window_isPopup", or blank)

With the second part you can give bug.n the following information on how to
handle the identified windows:

1. Is the window managed at all (0 = no, 1 = yes)?
2. On which monitor should the window be moved (given as an integer >= 0,
0 means the currently active monitor)?
3. On which views should the window be set (given as a binary mask converted to
an integer >= 0, 0 means the currently active view)?
4. Is the window floating, i.e. should not be tiled (0 = no, 1 = yes)?
5. Is the window decorated (0 = no, 1 = yes)? If not, the window title bar is
removed.
6. Should the title text be hidden in the bug.n bar (0 = no, 1 = yes)?
7. A special single window action (`close` or `maximize` or blank).

If you want to replace a rule, which is already set in `Config.ahk`, you will
have to use the correct variable name; e.g. you may set a default rule
(identifying part: `.*;.*;`), overwriting the first rule set in `Config.ahk`,
by using the variable name `Config_rule_#1`. If you want to _add_ a rule,
simply use `Config_rule` as the variable name; the numbering will be done
automatically by bug.n when reading `Config.ini` using the order given there.

To get a draft for a new rule, you can use the hotkey
`#i::Manager_getWindowInfo()` (<kbd>Win</kbd><kbd>I</kbd>), which will give the
full class and title, additional information about and the current values for
the active window included in a string, which can be copied to the
`Config.ini`.

#### Views / Tags

You can set a window to more than one view. Add up the associated numbers as
shown in the following table and set the sixth field of the rule to the value
of the sum.

| view / tag       |   1 |   2 |   3 |   4 |   5 |   6 |   7 |   8 |   9 |              n | all |
| ---------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | -------------- | --- |
| number to sum up |   1 |   2 |   4 |   8 |  16 |  32 |  64 | 128 | 256 | `2 ** (n - 1)` | 511 |

An example would be the value `17` for views 1 and 5.

### Examples

#### Mozilla Firefox

The following `Config.ini` line replaces rule number 16 in the default
configuration, putting windows of 'Mozilla Firefox' on view 5, keeping the
title bar visible and maximizing them.

`Config_rule_#16=MozillaWindowClass;.*Mozilla Firefox;;1;0;16;0;1;0;maximize`

#### Mozilla Thunderbird

The following `Config.ini` line adds a rule, putting windows of 'Mozilla
Thunderbird' on view 4, keeping the title bar visible and maximizing them.

`Config_rule=MozillaWindowClass;.*Mozilla Thunderbird;;1;0;8;0;1;0;maximize`

#### GNU Emacs

The following rule avoids the gaps, which would be the result of Emacs'
line-oriented resizing of its own windows (frames).

`Config_rule=Emacs;.*;;1;0;0;0;0;0;maximize`

#### Atlassian SourceTree

The following rule excludes the confirmation dialog for removing files from the
working copy from being managed by bug.n.

`Config_rule=.*SourceTree.*;Confirm Remove Modified or Untracked Files?;;0;0;0;1;1;0;`

#### hunt-n-peck

As provided by [NickSeagull](https://github.com/NickSeagull) in 
[issue #146](https://github.com/fuhsjr00/bug.n/issues/146):

`Config_rule=*hap*;.*hap*;*hap*;0;0;1;1;1;1;`

#### Applications written with the Qt5 development framework

The following rule is corresponding to rule 4 regarding the previous version of
the Qt development framework:

`Config_rule=Qt5QWindowIcon;.*;;1;0;0;0;0;0;`

#### Applications using the Modern (Windows 10) UI

With some of the Windows 10 applications also running in the background, it is 
not practical for all of them to be tiled by bug.n. Those applications, which 
should be tiled, have to be listed specifically, e.g. Edge:

`Config_rule=ApplicationFrameWindow;.*Edge;;1;0;0;0;1;0;`
