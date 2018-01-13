;; Just use this to send commands

;; The following line is required.
DetectHiddenWindows, On

;; Syntax:
;; ControlSetText, Edit2, % "<function name>(<arguments>)", bug.n_BAR_0

;; 1st example:
;ControlSetText, Edit2, % "Monitor_activateView(4)", bug.n_BAR_0

;; 2nd example:
;ControlSetText, Edit2, % "Monitor_activateView(4)`nView_setLayout(3)", bug.n_BAR_0

;; 3rd example:
ControlSetText, Edit2, % "Monitor_activateView(4)`nRun, explorer.exe", bug.n_BAR_0
