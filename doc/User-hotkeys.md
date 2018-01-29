## User proposed hotkeys

### Table of contents

* [User: jbremer (2012-Oct-27 19:33, bug.n 8.2.1)](#user-jbremer-2012-oct-27-1933-bugn-821)
* [Xmonad hotkeys](#xmonad-hotkeys)
* [AZERTY compatible hotkeys](#azerty-compatible-hotkeys)
* [Slovak (QWERTZ)](#slovak-qwertz)

### User: jbremer (2012-Oct-27 19:33, bug.n 8.2.1) #

| Hotkey | Alias to     | Description                                                                                          |
| ------ | ------------ | ---------------------------------------------------------------------------------------------------- |
| `#x`   | `#Backspace` | toggle view (duplicate of `#Backspace`, but `#x` types much easier)                                  |
| `#j`   | `#Down`      | window down                                                                                          |
| `#k`   | `#Up`        | window up                                                                                            |
| `#t`   | -            | launch a terminal (`Run, C:\Program Files\mintty.exe -`)                                             |
| `#b`   | -            | launch a terminal with an ssh connection (`Run, C:\Program Files\mintty.exe /bin/ssh user@hostname`) |

### Xmonad hotkeys #

Here follows an example for configuring hotkeys, which are similar to those of
[xmonad](http://xmonad.org/); ~~this example was submitted for bug.n version
8.2.1.~~ 2018-01-29: Updated to work with bug.n 9.0.2.

    ; remapping of lock screen needed to free up #l
    Config_hotkey=#^+l::Manager_lockWorkStation()
    
    Config_hotkey=#1::Monitor_activateView(1)
    Config_hotkey=#+1::Monitor_setWindowTag(1)
    Config_hotkey=#2::Monitor_activateView(2)
    Config_hotkey=#+2::Monitor_setWindowTag(2)
    Config_hotkey=#3::Monitor_activateView(3)
    Config_hotkey=#+3::Monitor_setWindowTag(3)
    Config_hotkey=#4::Monitor_activateView(4)
    Config_hotkey=#+4::Monitor_setWindowTag(4)
    Config_hotkey=#5::Monitor_activateView(5)
    Config_hotkey=#+5::Monitor_setWindowTag(5)
    Config_hotkey=#6::Monitor_activateView(6)
    Config_hotkey=#+6::Monitor_setWindowTag(6)
    Config_hotkey=#7::Monitor_activateView(7)
    Config_hotkey=#+7::Monitor_setWindowTag(7)
    Config_hotkey=#8::Monitor_activateView(8)
    Config_hotkey=#+8::Monitor_setWindowTag(8)
    Config_hotkey=#9::Monitor_activateView(9)
    Config_hotkey=#+9::Monitor_setWindowTag(9)
    Config_hotkey=#+0::Monitor_setWindowTag(0)
    Config_hotkey=#^1::Monitor_toggleWindowTag(1)
    Config_hotkey=#^2::Monitor_toggleWindowTag(2)
    Config_hotkey=#^3::Monitor_toggleWindowTag(3)
    Config_hotkey=#^4::Monitor_toggleWindowTag(4)
    Config_hotkey=#^5::Monitor_toggleWindowTag(5)
    Config_hotkey=#^6::Monitor_toggleWindowTag(6)
    Config_hotkey=#^7::Monitor_toggleWindowTag(7)
    Config_hotkey=#^8::Monitor_toggleWindowTag(8)
    Config_hotkey=#^9::Monitor_toggleWindowTag(9)
    Config_hotkey=#q::Reload
    Config_hotkey=#+q::ExitApp
    Config_hotkey=#w::Manager_activateMonitor(1)
    Config_hotkey=#+w::Manager_setWindowMonitor(1)
    Config_hotkey=#e::Manager_activateMonitor(2)
    Config_hotkey=#+e::Manager_setWindowMonitor(2)
    Config_hotkey=#t::View_toggleFloatingWindow()
    Config_hotkey=#h::View_setLayoutProperty(MFactor, 0, -0.05)
    Config_hotkey=#j::View_activateWindow(0,+1)
    Config_hotkey=#+j::View_shuffleWindow(0,+1)
    Config_hotkey=#k::View_activateWindow(0,-1)
    Config_hotkey=#+k::View_shuffleWindow(0,-1)
    Config_hotkey=#l::View_setLayoutProperty(MFactor, 0, +0.05)
    Config_hotkey=#Enter::View_shuffleWindow(1)
    Config_hotkey=#+c::Manager_closeWindow()
    Config_hotkey=#,::View_setLayoutProperty(MY, 0, +1)
    Config_hotkey=#.::View_setLayoutProperty(MY, 0, -1)
    Config_hotkey=#Space::View_setLayout(0, +1)
    Config_hotkey=#^Space::View_resetTileLayout()
    Config_hotkey=#b::Monitor_toggleTaskBar()
    Config_hotkey=#^b::Monitor_toggleBar()

### AZERTY compatible hotkeys #

This configuration was created in order to make view/tagging hotkeys functional with AZERTY keyboards. In fact, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9` and `0` triggers respectively `&`, `é`, `"`, `'`, `(`, `-`, `è`, `_`, `ç` and `à` in such a layout.

```
Config_hotkey=#&::Monitor_activateView(1)
Config_hotkey=#é::Monitor_activateView(2)
Config_hotkey=#"::Monitor_activateView(3)
Config_hotkey=#'::Monitor_activateView(4)
Config_hotkey=#(::Monitor_activateView(5)
Config_hotkey=#-::Monitor_activateView(6)
Config_hotkey=#è::Monitor_activateView(7)
Config_hotkey=#_::Monitor_activateView(8)
Config_hotkey=#ç::Monitor_activateView(9)
Config_hotkey=#+&::Monitor_setWindowTag(1)
Config_hotkey=#+é::Monitor_setWindowTag(2)
Config_hotkey=#+"::Monitor_setWindowTag(3)
Config_hotkey=#+'::Monitor_setWindowTag(4)
Config_hotkey=#+(::Monitor_setWindowTag(5)
Config_hotkey=#+-::Monitor_setWindowTag(6)
Config_hotkey=#+è::Monitor_setWindowTag(7)
Config_hotkey=#+_::Monitor_setWindowTag(8)
Config_hotkey=#+ç::Monitor_setWindowTag(9)
Config_hotkey=#^&::toggleWindowTag(1)
Config_hotkey=#^é::toggleWindowTag(2)
Config_hotkey=#^"::toggleWindowTag(3)
Config_hotkey=#^'::toggleWindowTag(4)
Config_hotkey=#^(::toggleWindowTag(5)
Config_hotkey=#^-::toggleWindowTag(6)
Config_hotkey=#^è::toggleWindowTag(7)
Config_hotkey=#^_::toggleWindowTag(8)
Config_hotkey=#^ç::toggleWindowTag(9)
```

### Slovak (QWERTZ) #

```
Config_hotkey=#BackSpace::Monitor_activateView(-1)
Config_hotkey=#+é::Monitor_setWindowTag(10)
Config_hotkey=#=::Monitor_activateView(1)
Config_hotkey=#+=::Monitor_setWindowTag(1)
Config_hotkey=#^=::Monitor_toggleWindowTag(1)
Config_hotkey=#ľ::Monitor_activateView(2)
Config_hotkey=#+ľ::Monitor_setWindowTag(2)
Config_hotkey=#^ľ::Monitor_toggleWindowTag(2)
Config_hotkey=#š::Monitor_activateView(3)
Config_hotkey=#+š::Monitor_setWindowTag(3)
Config_hotkey=#^š::Monitor_toggleWindowTag(3)
Config_hotkey=#č::Monitor_activateView(4)
Config_hotkey=#+č::Monitor_setWindowTag(4)
Config_hotkey=#^č::Monitor_toggleWindowTag(4)
Config_hotkey=#ť::Monitor_activateView(5)
Config_hotkey=#+ť::Monitor_setWindowTag(5)
Config_hotkey=#^ť::Monitor_toggleWindowTag(5)
Config_hotkey=#ž::Monitor_activateView(6)
Config_hotkey=#+ž::Monitor_setWindowTag(6)
Config_hotkey=#^ž::Monitor_toggleWindowTag(6)
Config_hotkey=#ý::Monitor_activateView(7)
Config_hotkey=#+ý::Monitor_setWindowTag(7)
Config_hotkey=#^ý::Monitor_toggleWindowTag(7)
Config_hotkey=#á::Monitor_activateView(8)
Config_hotkey=#+á::Monitor_setWindowTag(8)
Config_hotkey=#^á::Monitor_toggleWindowTag(8)
Config_hotkey=#í::Monitor_activateView(9)
Config_hotkey=#+í::Monitor_setWindowTag(9)
Config_hotkey=#^í::Monitor_toggleWindowTag(9)
```
