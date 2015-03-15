## User proposed hotkeys

#### User: jbremer (2012-Oct-27 19:33, bug.n 8.2.1)

| Hotkey | Alias to     | Description                                                                                          |
| ------ | ------------ | ---------------------------------------------------------------------------------------------------- |
| `#x`   | `#Backspace` | toggle view (duplicate of `#Backspace`, but `#x` types much easier)                                  |
| `#j`   | `#Down`      | window down                                                                                          |
| `#k`   | `#Up`        | window up                                                                                            |
| `#t`   | -            | launch a terminal (`Run, C:\Program Files\mintty.exe -`)                                             |
| `#b`   | -            | launch a terminal with an ssh connection (`Run, C:\Program Files\mintty.exe /bin/ssh user@hostname`) |

#### Xmonad hotkeys

Here follows an example for configuring hotkeys, which are similar to those of
[xmonad](http://xmonad.org/); this example was submitted for bug.n version
8.2.1.

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
    Config_hotkey=#t::View_toggleFloating()
    Config_hotkey=#h::View_setMFactor(-0.05)
    Config_hotkey=#j::View_activateWindow(+1)
    Config_hotkey=#+j::View_shuffleWindow(+1)
    Config_hotkey=#k::View_activateWindow(-1)
    Config_hotkey=#+k::View_shuffleWindow(-1)
    Config_hotkey=#l::View_setMFactor(+0.05)
    Config_hotkey=#Enter::View_shuffleWindow(0)
    Config_hotkey=#+c::Manager_closeWindow()
    Config_hotkey=#,::View_setMSplit(+1)
    Config_hotkey=#.::View_setMSplit(-1)
    Config_hotkey=#Space::View_setLayout(>)
