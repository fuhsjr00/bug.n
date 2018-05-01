/*
  bug.n -- tiling window management
  Copyright (c) 2010-2018 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.2
*/

View_init(m, v)
{
  Global

  View_#%m%_#%v%_area_#0        := 0
  View_#%m%_#%v%_aWndIds        := "0;"
  View_#%m%_#%v%_layout_#1      := 1
  View_#%m%_#%v%_layout_#2      := 1
  View_#%m%_#%v%_layoutAxis_#1  := Config_layoutAxis_#1
  View_#%m%_#%v%_layoutAxis_#2  := Config_layoutAxis_#2
  View_#%m%_#%v%_layoutAxis_#3  := Config_layoutAxis_#3
  View_#%m%_#%v%_layoutGapWidth := Config_layoutGapWidth
  View_#%m%_#%v%_layoutMFact    := Config_layoutMFactor
  View_#%m%_#%v%_layoutMX       := 1
  View_#%m%_#%v%_layoutMY       := 1
  View_#%m%_#%v%_layoutSymbol   := Config_layoutSymbol_#1
  View_#%m%_#%v%_margins        := "0;0;0;0"
  View_#%m%_#%v%_showStackArea  := True
  StringSplit, View_#%m%_#%v%_margin, View_#%m%_#%v%_margins, `;
  View_#%m%_#%v%_wndIds         := ""
}

View_activateWindow(i, d = 0) {
  Local aWndId, direction, failure, j, v, wndId, wndId0, wndIds

  Debug_logMessage("DEBUG[1] View_activateWindow(" . i . ", " . d . ")", 1)
  If (i = 0) And (d = 0)
    Return

  WinGet, aWndId, ID, A
  Debug_logMessage("DEBUG[2] Active Windows ID: " . aWndId, 2, False)
  v := Monitor_#%Manager_aMonitor%_aView_#1
  Debug_logMessage("DEBUG[2] View (" . v . ") wndIds: " . View_#%Manager_aMonitor%_#%v%_wndIds, 2, False)
  StringTrimRight, wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, 1
  StringSplit, wndId, wndIds, `;
  Debug_logMessage("DEBUG[2] wndId count: " . wndId0, 2, False)
  If (i > 0) And (i <= wndId0) And (d = 0) {
    wndId := wndId%i%
    Window_set(wndId, "AlwaysOnTop", "On")
    Window_set(wndId, "AlwaysOnTop", "Off")
    Window_#%wndId%_isMinimized := False
    Manager_winActivate(wndId)
  } Else If (wndId0 > 1) {
    If Not InStr(Manager_managedWndIds, aWndId . ";") Or Window_#%aWndId%_isFloating
      Window_set(aWndId, "Bottom", "")
    Loop, % wndId0 {
      If (wndId%A_Index% = aWndId) {
        j := A_Index
        Break
      }
    }
    Debug_logMessage("DEBUG[2] Current wndId index: " . j, 2, False)

    If (d > 0)
      direction = 1
    Else
      direction = -1
    i := Manager_loop(j, d, 1, wndId0)
    Loop, % wndId0 {
      Debug_logMessage("DEBUG[2] Next wndId index: " . i, 2, False)
      wndId := wndId%i%
      If Not Window_#%wndId%_isMinimized {
        Window_set(wndId, "AlwaysOnTop", "On")
        Window_set(wndId, "AlwaysOnTop", "Off")

        ;; If there are hung windows on the screen, we still want to be able to cycle through them.
        failure := Manager_winActivate(wndId)
        If Not failure
          Break
      }
      i := Manager_loop(i, direction, 1, wndId0)
    }
  }
}

View_addWindow(m, v, wndId) {
  Local i, mSplit, n, replace, search

  StringReplace, View_#%m%_#%v%_wndIds, View_#%m%_#%v%_wndIds, % wndId ";",, All
  If Tiler_isActive(m, v) And ((Config_newWndPosition = "masterBottom") Or (Config_newWndPosition = "stackTop")) {
    n := View_getTiledWndIds(m, v)
    mSplit := View_#%m%_#%v%_layoutMX * View_#%m%_#%v%_layoutMY
    If (mSplit = 1 And Config_newWndPosition = "masterBottom")
      View_#%m%_#%v%_wndIds := wndId ";" . View_#%m%_#%v%_wndIds
    Else If ((Config_newWndPosition = "masterBottom" And n < mSplit) Or (Config_newWndPosition = "stackTop" And n <= mSplit))
      View_#%m%_#%v%_wndIds .= wndId ";"
    Else {
      If (Config_newWndPosition = "masterBottom")
        i := mSplit - 1
      Else
        i := mSplit
      search  := View_tiledWndId%i% ";"
      replace := search wndId ";"
      StringReplace, View_#%m%_#%v%_wndIds, View_#%m%_#%v%_wndIds, %search%, %replace%
    }
  }
  Else If (Config_newWndPosition = "bottom")
    View_#%m%_#%v%_wndIds .= wndId ";"
  Else
    View_#%m%_#%v%_wndIds := wndId ";" View_#%m%_#%v%_wndIds
}

View_arrange(m, v, setLayout = False) {
  Local fn, h, l, w, x, y

  Debug_logMessage("DEBUG[1] View_arrange(" . m . ", " . v . ")", 1)

  l := View_#%m%_#%v%_layout_#1
  fn := Config_layoutFunction_#%l%
  If fn {
    x := Monitor_#%m%_x + View_#%m%_#%v%_layoutGapWidth + View_#%m%_#%v%_margin4
    y := Monitor_#%m%_y + View_#%m%_#%v%_layoutGapWidth + View_#%m%_#%v%_margin1
    w := Monitor_#%m%_width - 2 * View_#%m%_#%v%_layoutGapWidth - View_#%m%_#%v%_margin4 - View_#%m%_#%v%_margin2
    h := Monitor_#%m%_height - 2 * View_#%m%_#%v%_layoutGapWidth - View_#%m%_#%v%_margin1 - View_#%m%_#%v%_margin3

    ;; All window actions are performed on independent windows. A delay won't help.
    SetWinDelay, 0
    If Config_dynamicTiling Or setLayout {
      View_getTiledWndIds(m, v)
      If (fn = "monocle") {
        ;; 'View_getLayoutSymbol_monocle'
        View_#%m%_#%v%_layoutSymbol := "[" View_tiledWndId0 "]"
        ;; 'View_arrange_monocle'
        Tiler_stackTiles(0, 0, 1, View_tiledWndId0, +1, 3, x, y, w, h, 0)
      } Else    ;; (fn = "tile")
        Tiler_layoutTiles(m, v, x, y, w, h)
    } Else If (fn = "tile") {
      Tiler_layoutTiles(m, v, x, y, w, h, "blank")
      If Config_continuouslyTraceAreas
        View_traceAreas(True)
    }
    SetWinDelay, 10
  }
  Else    ;; floating layout (no 'View_arrange_', following is 'View_getLayoutSymbol_')'
    View_#%m%_#%v%_layoutSymbol := Config_layoutSymbol_#%l%

  Bar_updateLayout(m)
}

View_getActiveWindow(m, v) {
  Local listId, listIds, wndId

  listIds := "aWndIds;wndIds"
  wndId := 0
  Loop, Parse, listIds, `;
  {
    listId := A_LoopField
    Loop, Parse, View_#%m%_#%v%_%listId%, `;
    {
      If Not A_LoopField
        Break
      Else If Not WinExist("ahk_id" A_LoopField) Or Window_#%A_LoopField%_isMinimized
        Continue
      Else {
        wndId := A_LoopField
        Break
      }
    }
    If wndId {
      If (listId = "wndIds")
        View_setActiveWindow(m, v, wndId)
      Break
    }
  }

  Return, wndId
}

View_getTiledWndIds(m, v)
{
  Local n, tiledWndIds, wndIds

  n := 0
  tiledWndIds := ""
  StringTrimRight, wndIds, View_#%m%_#%v%_wndIds, 1
  Loop, PARSE, wndIds, `;
  {
    If A_LoopField And Not Window_#%A_LoopField%_isFloating And WinExist("ahk_id " A_LoopField) and Not Window_isHung(A_LoopField)
    {
      n += 1
      tiledWndIds .= A_LoopField ";"
    }
  }
  View_tiledWndIds := tiledWndIds
  StringTrimRight, tiledWndIds, tiledWndIds, 1
  StringSplit, View_tiledWndId, tiledWndIds, `;

  Return, n
}

View_ghostWindow(m, v, bodyWndId, ghostWndId)
{
  Local search, replace

  search := bodyWndId ";"
  replace := search ghostWndId ";"
  StringReplace, View_#%m%_#%v%_wndIds, View_#%m%_#%v%_wndIds, %search%, %replace%
}

View_moveToIndex(m, v, n, w) {
  Local wndIds

  View_#%n%_#%w%_area_#0        := View_#%m%_#%v%_area_#0
  View_#%n%_#%w%_aWndIds        := View_#%m%_#%v%_aWndIds
  View_#%n%_#%w%_layout_#1      := View_#%m%_#%v%_layout_#1
  View_#%n%_#%w%_layout_#2      := View_#%m%_#%v%_layout_#2
  View_#%n%_#%w%_layoutAxis_#1  := View_#%m%_#%v%_layoutAxis_#1
  View_#%n%_#%w%_layoutAxis_#2  := View_#%m%_#%v%_layoutAxis_#2
  View_#%n%_#%w%_layoutAxis_#3  := View_#%m%_#%v%_layoutAxis_#3
  View_#%n%_#%w%_layoutGapWidth := View_#%m%_#%v%_layoutGapWidth
  View_#%n%_#%w%_layoutMFact    := View_#%m%_#%v%_layoutMFact
  View_#%n%_#%w%_layoutMX       := View_#%m%_#%v%_layoutMX
  View_#%n%_#%w%_layoutMY       := View_#%m%_#%v%_layoutMY
  View_#%n%_#%w%_layoutSymbol   := View_#%m%_#%v%_layoutSymbol
  View_#%n%_#%w%_margins        := View_#%m%_#%v%_margins
  View_#%n%_#%w%_showStackArea  := View_#%m%_#%v%_showStackArea
  View_#%n%_#%w%_wndIds         := View_#%m%_#%v%_wndIds
  StringSplit, View_#%n%_#%w%_margin, View_#%n%_#%w%_margins, `;
  StringTrimRight, wndIds, View_#%n%_#%w%_wndIds, 1
  Loop, PARSE, wndIds, `;
  {
    Window_#%A_LoopField%_monitor := n
    Window_#%A_LoopField%_tags -= 1 << v - 1
    Window_#%A_LoopField%_tags += 1 << w - 1
  }
}

; @TODO: Theoretically, something is wrong here. From the hotkeys this should be manual tiling, but the function says otherwise.
View_moveWindow(i=0, d=0) {
  Local aWndId, m, v

  WinGet, aWndId, ID, A
  m := Manager_aMonitor
  v := Monitor_#%m%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v) And InStr(Manager_managedWndIds, aWndId ";") And Not (i = 0 And d = 0) And View_#%m%_#%v%_area_#0 And (i <= View_#%m%_#%v%_area_#0) {
    If (i = 0)
      i := Manager_loop(Window_#%aWndId%_area, d, 1, View_#%m%_#%v%_area_#0)
    Window_move(aWndId, View_#%m%_#%v%_area_#%i%_x, View_#%m%_#%v%_area_#%i%_y, View_#%m%_#%v%_area_#%i%_width, View_#%m%_#%v%_area_#%i%_height)
    Window_#%aWndId%_area := i
    Manager_setCursor(aWndId)
  }
}

View_resetTileLayout() {
  Local m, v

  m := Manager_aMonitor
  v := Monitor_#%m%_aView_#1
  
  View_#%m%_#%v%_area_#0        := 0
  View_#%m%_#%v%_layout_#2      := View_#%m%_#%v%_layout_#1
  View_#%m%_#%v%_layout_#1      := 1
  View_#%m%_#%v%_layoutAxis_#1  := Config_layoutAxis_#1
  View_#%m%_#%v%_layoutAxis_#2  := Config_layoutAxis_#2
  View_#%m%_#%v%_layoutAxis_#3  := Config_layoutAxis_#3
  View_#%m%_#%v%_layoutGapWidth := Config_layoutGapWidth
  View_#%m%_#%v%_layoutMFact    := Config_layoutMFactor
  View_#%m%_#%v%_layoutMX       := 1
  View_#%m%_#%v%_layoutMY       := 1
  View_#%m%_#%v%_layoutSymbol   := Config_layoutSymbol_#1
  View_#%m%_#%v%_margins        := "0;0;0;0"
  View_#%m%_#%v%_showStackArea  := True
  StringSplit, View_#%m%_#%v%_margin, View_#%m%_#%v%_margins, `;
  
  If Tiler_isActive(m, v)
    View_arrange(m, v)
}

View_setActiveWindow(m, v, wndId) {
  Global

  If wndId {
    StringReplace, View_#%m%_#%v%_aWndIds, View_#%m%_#%v%_aWndIds, % wndId ";", All
    View_#%m%_#%v%_aWndIds := wndId ";" View_#%m%_#%v%_aWndIds
  }
}

View_setGapWidth(i, d = 0) {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If (i = 0) And (d != 0)
    i := View_#%Manager_aMonitor%_#%v%_layoutGapWidth
  i += d
  If (i >= 0 And i < Monitor_#%Manager_aMonitor%_height And i < Monitor_#%Manager_aMonitor%_width) {
    i := Ceil(i / 2) * 2
    View_#%Manager_aMonitor%_#%v%_layoutGapWidth := i
    Return, 1
  } Else
    Return, 0
}

View_setLayout(i, d = 0) {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If (i = -1)
    i := View_#%Manager_aMonitor%_#%v%_layout_#2
  Else If (i = 0)
    i := View_#%Manager_aMonitor%_#%v%_layout_#1
  i := Manager_loop(i, d, 1, Config_layoutCount)
  If (i > 0) And (i <= Config_layoutCount) {
    If Not (i = View_#%Manager_aMonitor%_#%v%_layout_#1) {
      View_#%Manager_aMonitor%_#%v%_layout_#2 := View_#%Manager_aMonitor%_#%v%_layout_#1
      View_#%Manager_aMonitor%_#%v%_layout_#1 := i
    }
    View_arrange(Manager_aMonitor, v, True)
  }
}

View_setLayoutProperty(name, i, d, opt = 0) {
  Local a, l, v

  a := False
  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If Tiler_isActive(Manager_aMonitor, v) {
    If (name = "Axis")
      a := Tiler_setAxis(Manager_aMonitor, v, opt, d)
    Else If (name = "MFactor") {
      If (opt = 0)
        opt := 1
      a := Tiler_setMFactor(Manager_aMonitor, v, i, d, opt)
    } Else If (name = "MX")
      a := Tiler_setMX(Manager_aMonitor, v, d)
    Else If (name = "MY")
      a := Tiler_setMY(Manager_aMonitor, v, d)
  }
  If (name = "GapWidth") And (Tiler_isActive(Manager_aMonitor, v) Or (Config_layoutFunction_#%l% = "monocle"))
    a := View_setGapWidth(i, d)

  If a
    View_arrange(Manager_aMonitor, v)
}

View_shuffleWindow(i, d = 0) {
  Local aWndId, j, replace, v

  Debug_logMessage("DEBUG[2] View_shuffleWindow(" . i . ", " . d . ")", 2)
  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v) {
    View_getTiledWndIds(Manager_aMonitor, v)
    WinGet, aWndId, ID, A
    If InStr(View_tiledWndIds, aWndId ";") And (View_tiledWndId0 > 1) {
      Loop, % View_tiledWndId0 {
        If (View_tiledWndId%A_Index% = aWndId) {
          j := A_Index
          Break
        }
      }
      If (i = 0)
        i := j
      Else If (i = 1 And j = 1)
        i := 2
      i := Manager_loop(i, d, 1, View_tiledWndId0)
      Debug_logMessage("DEBUG[2] View_shuffleWindow: " . j . " -> " . i, 2)
      If (i != j) {
        If (i < j)
          replace := aWndId ";" View_tiledWndId%i% ";"
        Else
          replace := View_tiledWndId%i% ";" aWndId ";"
        StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, % aWndId ";",
        StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, % View_tiledWndId%i% ";", %replace%
        View_arrange(Manager_aMonitor, v)
        Manager_setCursor(aWndId)
      }
    }
  }
}

View_toggleFloatingWindow(wndId = 0) {
  Local l, v

  If (wndId = 0)
    WinGet, wndId, ID, A
  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  Debug_logMessage("DEBUG[2] View_toggleFloatingWindow; wndId: " . wndId, 2)
  If (Config_layoutFunction_#%l% And InStr(Manager_managedWndIds, wndId ";")) {
    Window_#%wndId%_isFloating := Not Window_#%wndId%_isFloating
    View_arrange(Manager_aMonitor, v)
    Bar_updateTitle()
  }
}

View_toggleMargins()
{
  Local v


  If Not (Config_viewMargins = "0;0;0;0")
  {
    v := Monitor_#%Manager_aMonitor%_aView_#1
    Debug_logMessage("DEBUG[3] View_toggleMargins(" . View_#%Manager_aMonitor%_#%v%_margin1 . ", " . View_#%Manager_aMonitor%_#%v%_margin2 . ", " . View_#%Manager_aMonitor%_#%v%_margin3 . ", " . View_#%Manager_aMonitor%_#%v%_margin4 . ")", 3)
    If (View_#%Manager_aMonitor%_#%v%_margins = "0;0;0;0")
      View_#%Manager_aMonitor%_#%v%_margins := Config_viewMargins
    Else
      View_#%Manager_aMonitor%_#%v%_margins := "0;0;0;0"
    StringSplit, View_#%Manager_aMonitor%_#%v%_margin, View_#%Manager_aMonitor%_#%v%_margins, `;
    View_arrange(Manager_aMonitor, v)
  }
}

View_toggleStackArea() {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v) And Not Config_dynamicTiling {
    Tiler_toggleStackArea(Manager_aMonitor, v)
    View_arrange(Manager_aMonitor, v)
  }
}

View_traceAreas(continuously = False) {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v) And Not Config_dynamicTiling
    Tiler_traceAreas(Manager_aMonitor, v, continuously)
}
