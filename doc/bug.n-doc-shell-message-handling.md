# Observations

| Application    | Message Number | Class                    | Special Property | Comment                                                           |
| -------------- | --------------:| ------------------------ | ---------------- | ----------------------------------------------------------------- |
| Notepad        |             16 | `Notepad`, `IME`         | hidden           | first hidden, later not; additionaly associated with class `IME`  |
| Explorer       |           none | `CabinetWClass`          |                  | WorkerW is triggered                                              |
| Calculator     |       16, 1, 2 | `ApplicationFrameWindow` | cloaked, hidden  | first hidden, later not                                           |
| GitHub Desktop |          16, 1 | `Chrome_WidgetWin_1`     |                  | additional hidden window with class `Chrome_WidgetWin_0`          |

Windows, which do not get deleted, when closing the application:
* hidden Notepad window
* additional GitHub window

The calculator window is immediately deleted.

# Conclusion

Especially Explorer windows are not recognized via shell messages, which match the window. Therefor shell messages can only be used as a trigger, but newly created/ deleted windows have to be detected in comparison to a list of known windows.