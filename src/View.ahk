/*
  bug.n -- tiling window management
  Copyright (c) 2010-2015 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.0
*/

View_init(m, v)
{
  Global

  View_#%m%_#%v%_area_#0        := 0
  View_#%m%_#%v%_aWndId         := 0
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

View_activateWindow(d)
{
  Local aWndId, direction, failure, i, j, v, wndId, wndId0, wndIds

  Debug_logMessage("DEBUG[1] View_activateWindow(" . d . ")", 1)
  If (d = 0)
    Return

  WinGet, aWndId, ID, A
  Debug_logMessage("DEBUG[2] Active Windows ID: " . aWndId, 2, False)
  v := Monitor_#%Manager_aMonitor%_aView_#1
  Debug_logMessage("DEBUG[2] View (" . v . ") wndIds: " . View_#%Manager_aMonitor%_#%v%_wndIds, 2, False)
  StringTrimRight, wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, 1
  StringSplit, wndId, wndIds, `;
  Debug_logMessage("DEBUG[2] wndId count: " . wndId0, 2, False)
  If (wndId0 > 1)
  {
    If Window_#%aWndId%_isFloating
      Window_set(aWndId, "Bottom", "")
    Loop, % wndId0
    {
      If (wndId%A_Index% = aWndId)
      {
        i := A_Index
        Break
      }
    }
    Debug_logMessage("DEBUG[2] Current wndId index: " . i, 2, False)

    If (d > 0)
      direction = 1
    Else
      direction = -1
    j := Manager_loop(i, d, 1, wndId0)
    Loop, % wndId0
    {
      Debug_logMessage("DEBUG[2] Next wndId index: " . j, 2, False)
      wndId := wndId%j%
      Window_set(wndId, "AlwaysOnTop", "On")
      Window_set(wndId, "AlwaysOnTop", "Off")

      ;; If there are hung windows on the screen, we still want to be able to cycle through them.
      failure := Manager_winActivate(wndId)
      If Not failure
        Break
      j := Manager_loop(j, direction, 1, wndId0)
    }
  }
}

View_addWindow(m, v, wndId) {
  Local i, mSplit, n, replace, search

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
  Local aWndId

  WinGet, aWndId, ID, A
  If WinExist("ahk_id" aWndId) And InStr(View_#%m%_#%v%_wndIds, aWndId ";") And Window_isProg(aWndId)
    Return, aWndId
  Else
    Return, 0
}

View_getTiledWndIds(m, v)
{
  Local n, tiledWndIds, wndIds

  StringTrimRight, wndIds, View_#%m%_#%v%_wndIds, 1
  Loop, PARSE, wndIds, `;
  {
    If Not Window_#%A_LoopField%_isFloating And WinExist("ahk_id " A_LoopField) and Not Window_isHung(A_LoopField)
    {
      n += 1
      tiledWndIds .= A_LoopField ";"
    }
  }
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

View_moveWindow(i=0, d=0) {
  Local aWndId, m, v

  WinGet, aWndId, ID, A
  m := Manager_aMonitor
  v := Monitor_#%m%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v) And InStr(Manager_managedWndIds, aWndId ";") And Not (i = 0 And d = 0) And (i <= View_#%m%_#%v%_area_#0) {
    If (i = 0)
      i := Manager_loop(Window_#%aWndId%_area, d, 1, View_#%m%_#%v%_area_#0)
    Window_move(aWndId, View_#%m%_#%v%_area_#%i%_x, View_#%m%_#%v%_area_#%i%_y, View_#%m%_#%v%_area_#%i%_width, View_#%m%_#%v%_area_#%i%_height)
    Window_#%aWndId%_area := i
    If Config_mouseFollowsFocus {
      WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
      DllCall("SetCursorPos", "Int", Round(aWndX + aWndWidth / 2), "Int", Round(aWndY + aWndHeight / 2))
    }
  }
}

View_rotateLayoutAxis(i, d) {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v) And (i = 1 Or i = 2 Or i = 3) {
    Tiler_rotateAxis(Manager_aMonitor, v, i, d)
    View_arrange(Manager_aMonitor, v)
  }
}

View_setGapWidth(d)
{
  Local l, v, w

  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If Tiler_isActive(Manager_aMonitor, v) Or (Config_layoutFunction_#%l% = "monocle")
  {
    If (d < 0)
      d := Floor(d / 2) * 2
    Else
      d := Ceil(d / 2) * 2
    w := View_#%Manager_aMonitor%_#%v%_layoutGapWidth + d
    If (w < Monitor_#%Manager_aMonitor%_height And w < Monitor_#%Manager_aMonitor%_width)
    {
      View_#%Manager_aMonitor%_#%v%_layoutGapWidth := w
      View_arrange(Manager_aMonitor, v)
    }
  }
}

View_setLayout(l)
{
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If (l = -1)
    l := View_#%Manager_aMonitor%_#%v%_layout_#2
  If (l = ">")
    l := Manager_loop(View_#%Manager_aMonitor%_#%v%_layout_#1, +1, 1, Config_layoutCount)
  If (l > 0) And (l <= Config_layoutCount)
  {
    If Not (l = View_#%Manager_aMonitor%_#%v%_layout_#1)
    {
      View_#%Manager_aMonitor%_#%v%_layout_#2 := View_#%Manager_aMonitor%_#%v%_layout_#1
      View_#%Manager_aMonitor%_#%v%_layout_#1 := l
    }
    View_arrange(Manager_aMonitor, v, True)
  }
}

View_setMFactor(d, dFact = 1) {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v)
    If Tiler_setMFactor(Manager_aMonitor, v, d, dFact)
      View_arrange(Manager_aMonitor, v)
}

View_setMX(d) {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v)
    If Tiler_setMX(Manager_aMonitor, v, d)
      View_arrange(Manager_aMonitor, v)
}

View_setMY(d) {
  Local v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v)
    If Tiler_setMY(Manager_aMonitor, v, d)
      View_arrange(Manager_aMonitor, v)
}

View_shuffleWindow(d)
{
  Local aWndHeight, aWndId, aWndWidth, aWndX, aWndY, i, j, search, v

  WinGet, aWndId, ID, A
  v := Monitor_#%Manager_aMonitor%_aView_#1
  If Tiler_isActive(Manager_aMonitor, v) And InStr(Manager_managedWndIds, aWndId ";")
  {
    View_getTiledWndIds(Manager_aMonitor, v)
    If (View_tiledWndId0 > 1)
    {
      Loop, % View_tiledWndId0
      {
        If (View_tiledWndId%A_Index% = aWndId)
        {
          i := A_Index
          Break
        }
      }
      If (d = 0 And i = 1)
        j := 2
      Else
        j := Manager_loop(i, d, 1, View_tiledWndId0)
      If (j > 0 And j <= View_tiledWndId0)
      {
        If (j = i)
        {
          StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, %aWndId%`;,
          View_#%Manager_aMonitor%_#%v%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%v%_wndIds
        }
        Else
        {
          search := View_tiledWndId%j%
          StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, %aWndId%, SEARCH
          StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, %search%, %aWndId%
          StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, SEARCH, %search%
        }
        View_arrange(Manager_aMonitor, v)

        If Config_mouseFollowsFocus
        {
          WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
          DllCall("SetCursorPos", "Int", Round(aWndX + aWndWidth / 2), "Int", Round(aWndY + aWndHeight / 2))
        }
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
  If (Config_layoutFunction_#%l% And InStr(Manager_managedWndIds, wndId ";")) {
    Window_#%wndId%_isFloating := Not Window_#%wndId%_isFloating
    View_arrange(Manager_aMonitor, v)
    Bar_updateTitle()
  }
}

View_toggleMargins()
{
  Local v

  Debug_logMessage("DEBUG[3] View_toggleMargins(" . View_#%Manager_aMonitor%_#%v%_margin1 . ", " . View_#%Manager_aMonitor%_#%v%_margin2 . ", " . View_#%Manager_aMonitor%_#%v%_margin3 . ", " . View_#%Manager_aMonitor%_#%v%_margin4 . ")", 3)

  If Not (Config_viewMargins = "0;0;0;0")
  {
    v := Monitor_#%Manager_aMonitor%_aView_#1
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
