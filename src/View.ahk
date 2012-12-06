/*
  bug.n -- tiling window management
  Copyright (c) 2010-2012 Joshua Fuhs, joten

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.

  @version 8.4.0
*/

View_init(m, v)
{
  Global

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
    If Manager_#%aWndId%_isFloating
      Manager_winSet("Bottom", "", aWndId)
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
      Manager_winSet("AlwaysOnTop", "On", wndId)
      Manager_winSet("AlwaysOnTop", "Off", wndId)

      ;; If there are hung windows on the screen, we still want to be able to cycle through them.
      failure := Manager_winActivate(wndId)
      If Not failure
        Break
      j := Manager_loop(j, direction, 1, wndId0)
    }
  }
}

View_addWindow(m, v, wndId)
{
  Local i, l, mSplit, n, replace, search

  l := View_#%m%_#%v%_layout_#1
  If (Config_layoutFunction_#%l% = "tile") And ((Config_newWndPosition = "masterBottom") Or (Config_newWndPosition = "stackTop"))
  {
    n := View_getTiledWndIds(m, v)
    mSplit := View_#%m%_#%v%_layoutMX * View_#%m%_#%v%_layoutMY
    If (mSplit = 1 And Config_newWndPosition = "masterBottom")
      View_#%m%_#%v%_wndIds := wndId ";" . View_#%m%_#%v%_wndIds
    Else If ((Config_newWndPosition = "masterBottom" And n < mSplit) Or (Config_newWndPosition = "stackTop" And n <= mSplit))
      View_#%m%_#%v%_wndIds .= wndId ";"
    Else
    {
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

View_arrange(m, v)
{
  Local fn, h, l, w, x, y

  Debug_logMessage("DEBUG[1] View_arrange(" . m . ", " . v . ")", 1)

  l := View_#%m%_#%v%_layout_#1
  fn := Config_layoutFunction_#%l%
  If fn
  {
    x := Monitor_#%m%_x + View_#%m%_#%v%_layoutGapWidth + View_#%m%_#%v%_margin4
    y := Monitor_#%m%_y + View_#%m%_#%v%_layoutGapWidth + View_#%m%_#%v%_margin1
    w := Monitor_#%m%_width - 2 * View_#%m%_#%v%_layoutGapWidth - View_#%m%_#%v%_margin4 - View_#%m%_#%v%_margin2
    h := Monitor_#%m%_height - 2 * View_#%m%_#%v%_layoutGapWidth - View_#%m%_#%v%_margin1 - View_#%m%_#%v%_margin3

    ;; All window actions are performed on independent windows. A delay won't help.
    SetWinDelay, 0
    View_getTiledWndIds(m, v)
    View_arrange_%fn%(m, v, x, y, w, h)
    SetWinDelay, 10
  }
  Else    ;; floating layout (no 'View_arrange_', following is 'View_getLayoutSymbol_')'
    View_#%m%_#%v%_layoutSymbol := Config_layoutSymbol_#%l%

  Bar_updateLayout(m)
}

View_arrange_monocle(m, v, x, y, w, h)
{
  Global

  ;; 'View_getLayoutSymbol_monocle'
  View_#%m%_#%v%_layoutSymbol := "[" View_tiledWndId0 "]"
  ;; 'View_arrange_monocle'
  View_stackWindows("View_tiledWndId", 1, View_tiledWndId0, +1, 3, x, y, w, h, 0)
}

View_arrange_tile(m, v, x, y, w, h)
{
  Local axis1, axis2, axis3, flipped, gapW, h1, h2, mFact, mSplit, mWndCount, mXSet, mYActual, mYSet, stackLen, subAreaCount, subAreaWndCount, subH1, subW1, subX1, subY1, w1, w2, x1, x2, y1, y2

  View_#%m%_#%v%_layoutSymbol := View_getLayoutSymbol_tile(m, v, View_tiledWndId0)

  Debug_logMessage("DEBUG[1] View_arrange_tile: (" . View_tiledWndId0 . ") ", 1)
  If (View_tiledWndId0 = 0)
    Return

  axis1   := Abs(View_#%m%_#%v%_layoutAxis_#1)
  axis2   := View_#%m%_#%v%_layoutAxis_#2
  axis3   := View_#%m%_#%v%_layoutAxis_#3
  flipped := View_#%m%_#%v%_layoutAxis_#1 < 0
  gapW    := View_#%m%_#%v%_layoutGapWidth
  mFact   := View_#%m%_#%v%_layoutMFact
  mXSet   := (axis2 = 1) ? View_#%m%_#%v%_layoutMX : View_#%m%_#%v%_layoutMY
  mYSet   := (axis2 = 1) ? View_#%m%_#%v%_layoutMY : View_#%m%_#%v%_layoutMX
  mSplit  := mXSet * mYSet
  If (mSplit > View_tiledWndId0)
    mSplit := View_tiledWndId0

  ;; Areas (master and stack)
  x1 := x
  y1 := y
  w1 := w
  h1 := h
  If (View_tiledWndId0 > mSplit)
  {    ;; There is a stack area.
    If flipped
      View_splitArea(axis1 - 1, 1 - mFact, x1, y1, w1, h1, gapW, x2, y2, w2, h2, x1, y1, w1, h1)
    Else
      View_splitArea(axis1 - 1, mFact, x1, y1, w1, h1, gapW, x1, y1, w1, h1, x2, y2, w2, h2)
  }

  ;; Master
  If (axis2 = 3)
    View_stackWindows("View_tiledWndId", 1, mSplit, +1, 3, x1, y1, w1, h1, 0)
  Else
  {
    mYActual := Ceil(mSplit / mXSet)
    subAreaCount := mYActual
    mWndCount := mSplit
    Loop, % mYActual
    {
      View_splitArea(Not (axis2 - 1), 1 / subAreaCount, x1, y1, w1, h1, gapW, subX1, subY1, subW1, subH1, x1, y1, w1, h1)
      subAreaWndCount := mXSet
      If (mWndCount < subAreaWndCount)
        subAreaWndCount := mWndCount
      View_stackWindows("View_tiledWndId", mSplit - mWndCount + 1, subAreaWndCount, +1, axis2, subX1, subY1, subW1, subH1, gapW)
      mWndCount -= subAreaWndCount
      subAreaCount -= 1
    }
  }

  ;; Stack
  If (View_tiledWndId0 <= mSplit)
    Return

  stackLen := View_tiledWndId0 - mSplit
  ;; 161 is the minimal width of an Windows-Explorer window, below which it cannot be resized.
  ;; The minimal height is 243, but this seems too high for being a limit here;
  ;; therefor '2 * Bar_height' is used for the minimal height of a window.
  If (axis3 = 3 Or (axis3 = 1 And (w2 - (stackLen - 1) * gapW) / stackLen < 161) Or (axis3 = 2 And (h2 - (stackLen - 1) * gapW) / stackLen < 2 * Bar_height))
    View_stackWindows("View_tiledWndId", mSplit + 1, stackLen, +1, 3, x2, y2, w2, h2, 0)
  Else
    View_stackWindows("View_tiledWndId", mSplit + 1, stackLen, +1, axis3, x2, y2, w2, h2, gapW)
}

View_getActiveWindow(m, v)
{
  Local aWndClass, aWndId, aWndTitle

  WinGet, aWndId, ID, A
  If WinExist("ahk_id" aWndId) And InStr(View_#%m%_#%v%_wndIds, aWndId ";")
  {
    WinGetClass, aWndClass, ahk_id %aWndId%
    WinGetTitle, aWndTitle, ahk_id %aWndId%
    If Not (aWndClass = "Progman") And Not (aWndClass = "AutoHotkeyGui" And SubStr(aWndTitle, 1, 10) = "bug.n_BAR_") And Not (aWndClass = "DesktopBackgroundClass")
      Return, aWndId
  }
  Return, 0
}

View_getLayoutSymbol_tile(m, v, n)
{
  Local axis1, axis2, axis3, masterDim, masterDiv, mx, my, stackSym

  ;; Main axis
  ;;  1 - vertical divider, master left
  ;;  2 - horizontal divider, master top
  ;; -1 - vertical divider, master right
  ;; -2 - horizontal divider, master bottom
  axis1 := View_#%m%_#%v%_layoutAxis_#1
  ;; Master axis
  ;;  1 - vertical divider
  ;;  2 - horizontal divider
  ;;  3 - monocle
  axis2 := View_#%m%_#%v%_layoutAxis_#2
  ;; Stack axis
  ;;  1 - vertical divider
  ;;  2 - horizontal divider
  ;;  3 - monocle
  axis3 := View_#%m%_#%v%_layoutAxis_#3
  mx := View_#%m%_#%v%_layoutMX
  my := View_#%m%_#%v%_layoutMY

  If (Abs(axis1) = 1)
    masterDiv := "|"
  Else
    masterDiv := "-"
  If (axis2 = 1)
    masterDim := mx . "x" . my
  Else If (axis2 = 2)
    masterDim := mx . "x" . my
  Else
    masterDim := "[" . (mx * my) . "]"

  If (axis3 = 1)
    stackSym := "|"
  Else If (axis3 = 2)
    stackSym := "="
  Else
    stackSym := n - (mx * my)

  If (axis1 > 0)
    Return, masterDim . masterDiv . stackSym
  Else
    Return, stackSym . masterDiv . masterDim
}

View_getTiledWndIds(m, v)
{
  Local n, tiledWndIds, wndIds

  StringTrimRight, wndIds, View_#%m%_#%v%_wndIds, 1
  Loop, PARSE, wndIds, `;
  {
    If Not Manager_#%A_LoopField%_isFloating And WinExist("ahk_id " A_LoopField) and Not Manager_isHung(A_LoopField)
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

View_rotateLayoutAxis(i, d)
{
  Local f, l, n, tmp, v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If (Config_layoutFunction_#%l% = "tile") And (i = 1 Or i = 2 Or i = 3)
  {
    If (i = 1)
    {
      If (d = +2)
        View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% *= -1
      Else
      {
        f := View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% / Abs(View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%)
        View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% := f * Manager_loop(Abs(View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%), d, 1, 2)
      }
    }
    Else
    {
      n := Manager_loop(View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%, d, 1, 3)
      ;; When we rotate the axis, we may need to swap the X and Y dimensions.
      ;; We only need to check this when the master axis changes (i = 2)
      ;; If the original axis was 1 (X) or the new axis is 1 (X)  (Y and Z are defined to be the same)
      If (i = 2) And Not (n = View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%) And (n = 1 Or View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% = 1)
      {
        tmp := View_#%Manager_aMonitor%_#%v%_layoutMX
        View_#%Manager_aMonitor%_#%v%_layoutMX := View_#%Manager_aMonitor%_#%v%_layoutMY
        View_#%Manager_aMonitor%_#%v%_layoutMY := tmp
      }
      View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% := n
    }
    View_arrange(Manager_aMonitor, v)
  }
}

View_setGapWidth(d)
{
  Local l, v, w

  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If (Config_layoutFunction_#%l% = "tile" Or Config_layoutFunction_#%l% = "monocle")
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
    View_arrange(Manager_aMonitor, v)
  }
}

View_setMFactor(d)
{
  Local l, mFact, v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If (Config_layoutFunction_#%l% = "tile")
  {
    mFact := 0
    If (d >= 1.05)
      mFact := d
    Else
      mFact := View_#%Manager_aMonitor%_#%v%_layoutMFact + d
    If (mFact >= 0.05 And mFact <= 0.95)
    {
      View_#%Manager_aMonitor%_#%v%_layoutMFact := mFact
      View_arrange(Manager_aMonitor, v)
    }
  }
}

View_setMX(d)
{
  Local l, n, v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If Not (Config_layoutFunction_#%l% = "tile")
    Return

  n := View_#%Manager_aMonitor%_#%v%_layoutMX + d
  If (n >= 1) And (n <= 9)
  {
    View_#%Manager_aMonitor%_#%v%_layoutMX := n
    View_arrange(Manager_aMonitor, v)
  }
}

View_setMY(d)
{
  Local l, n, v

  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If Not (Config_layoutFunction_#%l% = "tile")
    Return

  n := View_#%Manager_aMonitor%_#%v%_layoutMY + d
  If (n >= 1) And (n <= 9)
  {
    View_#%Manager_aMonitor%_#%v%_layoutMY := n
    View_arrange(Manager_aMonitor, v)
  }
}

View_shuffleWindow(d)
{
  Local aWndHeight, aWndId, aWndWidth, aWndX, aWndY, i, j, l, search, v

  WinGet, aWndId, ID, A
  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If (Config_layoutFunction_#%l% = "tile" And InStr(Manager_managedWndIds, aWndId ";"))
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

View_splitArea(axis, splitRatio, x, y, w, h, gapW, ByRef x1, ByRef y1, ByRef w1, ByRef h1, ByRef x2, ByRef y2, ByRef w2, ByRef h2)
{
  x1 := x
  y1 := y
  If (splitRatio = 1)
  {
    w1 := w
    w2 := 0
    h1 := h
    h2 := 0
    x2 := x + w1
    y2 := y + h1
  }
  Else If (axis = 0)
  {
    w1 := w * splitRatio - gapW / 2
    w2 := w - w1 - gapW
    h1 := h
    h2 := h
    x2 := x + w1 + gapW
    y2 := y
  }
  Else
  {
    w1 := w
    w2 := w
    h1 := h * splitRatio - gapW / 2
    h2 := h - h1 - gapW
    x2 := x
    y2 := y + h1 + gapW
  }
}

;; ARRAY SPECIFICATION
;;   arrayName - Name of a globally stored array of windows:
;;     %arrayName%1, %arrayName%2, ...
;;    startPos - First entry of the array, which should be used.
;;         len - Number of entries from the array, which should be used.
;;           d - +1/-1: In-/Decrement (direction) for traversing through the array.
;; STACKING SPECIFICATION
;;        axis - 1/2/3: Stacking axis (X/Y/Z)
;; AREA SPECIFICATION
;;           x - X-position of the stacking area
;;           y - Y-position of the stacking area
;;           w - Width of the stacking area
;;           h - Height of the stacking area
;;     padding - Number of pixels to put between the windows.
View_stackWindows(arrayName, startPos, len, d, axis, x, y, w, h, padding)
{
  Local dx, dy, i, wndH, wndW, wndX, wndY

  ;; d = +1: Left-to-right and top-to-bottom, depending on axis
  i := startPos
  ;; d = -1: Right-to-left and bottom-to-top, depending on axis
  If (d < 0)
    i += len - 1

  wndX := x
  wndY := y
  wndW := w
  wndH := h
  dx := 0
  dy := 0
  If (axis = 1)
  {
    wndW := (w - (len - 1) * padding) / len
    dx := wndW + padding
  }
  Else If (axis = 2)
  {
    wndH := (h - (len - 1) * padding) / len
    dy := wndH + padding
  }
  ;; Else (axis = 3) and nothing to do

  Loop, % len
  {
    Manager_winMove(%arrayName%%i%, wndX, wndY, wndW, wndH)
    i += d
    wndX += dx
    wndY += dy
  }
}

View_toggleFloating()
{
  Local aWndId, l, v

  WinGet, aWndId, ID, A
  v := Monitor_#%Manager_aMonitor%_aView_#1
  l := View_#%Manager_aMonitor%_#%v%_layout_#1
  If (Config_layoutFunction_#%l% And InStr(Manager_managedWndIds, aWndId ";"))
  {
    Manager_#%aWndId%_isFloating := Not Manager_#%aWndId%_isFloating
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
