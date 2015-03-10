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

Tiler_addSubArea(m, v, i, areaX, areaY, areaW, areaH) {
  Global

  Debug_logMessage("DEBUG[2] Tiler_addSubArea: areaX = " areaX ", areaY = " areaY ", areaW = " areaW ", areaH = " areaH, 2)
  View_#%m%_#%v%_area_#0 += 1
  View_#%m%_#%v%_area_#%i%_x := Round(areaX)
  View_#%m%_#%v%_area_#%i%_y := Round(areaY)
  View_#%m%_#%v%_area_#%i%_width  := Round(areaW)
  View_#%m%_#%v%_area_#%i%_height := Round(areaH)
}

Tiler_getLayoutSymbol(m, v, n) {
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

Tiler_getMFactorD(m, v, d, dFact) {
  Local callD, minD
  Static lastCall, mFactD

  callD := A_TickCount - lastCall
  lastCall := A_TickCount

  ;; The minimum d, which is reached in 5 steps. maxD is d.
  If (dFact < 1)
    minD := d * dFact**5
  Else
    minD := d / dFact**5

  If (callD < Config_mFactCallInterval And d * mFactD > 0) {
    ;; Accelerate mFactD, if the last call is inside the time frame and went in the same direction.
    mFactD *= dFact
    ;; Reset mFactD, if it is out of bounds (d).
    If (dFact < 1 And Abs(mFactD) < Abs(minD))
      mFactD := minD
    Else If (Abs(mFactD) > Abs(d))
      mFactD := d
    Debug_logMessage("DEBUG[2] View_getMFactorD [on]: callD: " callD ", d: " d ", dFact: " dFact ", mFactD: " mFactD, 2)
  } Else {
    ;; Reset after a timeout or a change of direction.
    If (dFact > 1)
      mFactD := minD
    Else
      mFactD := d
    Debug_logMessage("DEBUG[2] View_getMFactorD [off]: callD: " callD ", d: " d ", dFact: " dFact ", mFactD: " mFactD, 2)
  }

  Return, mFactD
}

Tiler_isActive(m, v) {
  Local l

  l := View_#%m%_#%v%_layout_#1
  Return, (Config_layoutFunction_#%l% = "tile")
}

Tiler_layoutTiles(m, v, x, y, w, h, type = "") {
  Local axis1, axis2, axis3, gapW, hasStackArea, mFact, mSplit, mXSet, mYSet, mYActual, n
  Local h1, h2, mWndCount, stackLen, subAreaCount, subAreaWndCount, subH1, subW1, subX1, subY1, w1, w2, x1, x2, y1, y2

  axis1  := Abs(View_#%m%_#%v%_layoutAxis_#1)
  axis2  := View_#%m%_#%v%_layoutAxis_#2
  axis3  := View_#%m%_#%v%_layoutAxis_#3
  gapW   := View_#%m%_#%v%_layoutGapWidth
  mFact  := View_#%m%_#%v%_layoutMFact
  mXSet  := (axis2 = 1) ? View_#%m%_#%v%_layoutMX : View_#%m%_#%v%_layoutMY
  mYSet  := (axis2 = 1) ? View_#%m%_#%v%_layoutMY : View_#%m%_#%v%_layoutMX
  mSplit := mXSet * mYSet
  hasStackArea := (type = "blank") ? View_#%m%_#%v%_showStackArea : (View_tiledWndId0 > mSplit)
  n := (type = "blank") ? mSplit : View_tiledWndId0

  Debug_logMessage("DEBUG[1] Tiler_layoutTiles: mX = " mXSet ", mY = " mYSet ", mSplit = " mSplit " / " View_tiledWndId0, 1)

  View_#%m%_#%v%_layoutSymbol := Tiler_getLayoutSymbol(m, v, n)

  If (type = "blank")
    View_#%m%_#%v%_area_#0 := 0
  Else {
    If (View_tiledWndId0 = 0)
      Return
    If (mSplit > View_tiledWndId0)
      mSplit := View_tiledWndId0
  }

  ;; Areas (master and stack)
  x1 := x
  y1 := y
  w1 := w
  h1 := h
  If hasStackArea {
    If (View_#%m%_#%v%_layoutAxis_#1 < 0)
      Tiler_splitArea(axis1 - 1, 1 - mFact, x1, y1, w1, h1, gapW, x2, y2, w2, h2, x1, y1, w1, h1)
    Else
      Tiler_splitArea(axis1 - 1, mFact, x1, y1, w1, h1, gapW, x1, y1, w1, h1, x2, y2, w2, h2)
  }

  ;; Master
  If (axis2 = 3)
    Tiler_stackTiles(m, v, 1, mSplit, +1, 3, x1, y1, w1, h1, 0, type)
  Else {
    mYActual := (type = "blank") ? mYSet : Ceil(mSplit / mXSet)
    subAreaCount := mYActual
    mWndCount := mSplit
    Loop, % mYActual {
      Tiler_splitArea(Not (axis2 - 1), 1 / subAreaCount, x1, y1, w1, h1, gapW, subX1, subY1, subW1, subH1, x1, y1, w1, h1)
      subAreaWndCount := mXSet
      If (mWndCount < subAreaWndCount)
        subAreaWndCount := mWndCount
      Debug_logMessage("DEBUG[2] Tiler_layoutTiles: Master subArea #" A_Index, 2)
      Tiler_stackTiles(m, v, mSplit - mWndCount + 1, subAreaWndCount, +1, axis2, subX1, subY1, subW1, subH1, gapW, type)
      mWndCount -= subAreaWndCount
      subAreaCount -= 1
    }
  }

  ;; Stack
  If hasStackArea {
    If (type = "blank") {
      Debug_logMessage("DEBUG[2] Tiler_layoutTiles: Stack subArea #" A_Index, 2)
      Tiler_stackTiles(m, v, mSplit + 1, 1, +1, 3, x2, y2, w2, h2, 0, type)
    } Else {
      stackLen := View_tiledWndId0 - mSplit
      ;; 161 is the minimal width of an Windows-Explorer window, below which it cannot be resized.
      ;; The minimal height is 243, but this seems too high for being a limit here;
      ;; therefor '2 * Bar_height' is used for the minimal height of a window.
      If (axis3 = 3 Or (axis3 = 1 And (w2 - (stackLen - 1) * gapW) / stackLen < 161) Or (axis3 = 2 And (h2 - (stackLen - 1) * gapW) / stackLen < 2 * Bar_height))
        Tiler_stackTiles(m, v, mSplit + 1, stackLen, +1, 3, x2, y2, w2, h2, 0, type)
      Else
        Tiler_stackTiles(m, v, mSplit + 1, stackLen, +1, axis3, x2, y2, w2, h2, gapW, type)
    }
  }
}

Tiler_setAxis(m, v, id, d) {
  Local f, n, tmp

  If (id = 1 Or id = 2 Or id = 3) {
    If (id = 1) {
      If (d = +2)
        View_#%m%_#%v%_layoutAxis_#%id% *= -1
      Else {
        f := View_#%m%_#%v%_layoutAxis_#%id% / Abs(View_#%m%_#%v%_layoutAxis_#%id%)
        View_#%m%_#%v%_layoutAxis_#%id% := f * Manager_loop(Abs(View_#%m%_#%v%_layoutAxis_#%id%), d, 1, 2)
      }
    } Else {
      n := Manager_loop(View_#%m%_#%v%_layoutAxis_#%id%, d, 1, 3)
      ;; When we rotate the axis, we may need to swap the X and Y dimensions.
      ;; We only need to check this when the master axis changes (id = 2)
      ;; If the original axis was 1 (X) or the new axis is 1 (X)  (Y and Z are defined to be the same)
      If (id = 2) And Not (n = View_#%m%_#%v%_layoutAxis_#%id%) And (n = 1 Or View_#%m%_#%v%_layoutAxis_#%id% = 1) {
        tmp := View_#%m%_#%v%_layoutMX
        View_#%m%_#%v%_layoutMX := View_#%m%_#%v%_layoutMY
        View_#%m%_#%v%_layoutMY := tmp
      }
      View_#%m%_#%v%_layoutAxis_#%id% := n
    }
    Return, 1
  } Else
    Return, 0
}

Tiler_setMFactor(m, v, i, d, dFact) {
  Local mFact

  If (i > 0)
    mFact := i
  Else
    mFact := View_#%m%_#%v%_layoutMFact
  If (View_#%m%_#%v%_layoutAxis_#1 < 0)
    d *= -1
  mFact += Tiler_getMFactorD(m, v, d, dFact)
  If (mFact > 0 And mFact < 1) {
    View_#%m%_#%v%_layoutMFact := mFact
    Return, 1
  } Else
    Return, 0
}

Tiler_setMX(m, v, d) {
  Local n

  n := View_#%m%_#%v%_layoutMX + d
  If (n >= 1) And (n <= 9) {
    View_#%m%_#%v%_layoutMX := n
    Return, 1
  } Else
    Return, 0
}

Tiler_setMY(m, v, d) {
  Local n

  n := View_#%m%_#%v%_layoutMY + d
  If (n >= 1) And (n <= 9) {
    View_#%m%_#%v%_layoutMY := n
    Return, 1
  } Else
    Return, 0
}

Tiler_splitArea(axis, splitRatio, x, y, w, h, gapW, ByRef x1, ByRef y1, ByRef w1, ByRef h1, ByRef x2, ByRef y2, ByRef w2, ByRef h2) {
  x1 := x
  y1 := y
  If (splitRatio = 1) {
    w1 := w
    w2 := 0
    h1 := h
    h2 := 0
    x2 := x + w1
    y2 := y + h1
  } Else If (axis = 0) {
    w1 := w * splitRatio - gapW / 2
    w2 := w - w1 - gapW
    h1 := h
    h2 := h
    x2 := x + w1 + gapW
    y2 := y
  } Else {
    w1 := w
    w2 := w
    h1 := h * splitRatio - gapW / 2
    h2 := h - h1 - gapW
    x2 := x
    y2 := y + h1 + gapW
  }
}

;; ARRAY SPECIFICATION
;;   arrayName - Name of a globally stored array of areas/windows:
;;     %arrayName%1, %arrayName%2, ...
;;           i - First entry of the array, which should be used.
;;         len - Number of entries from the array, which should be used.
;;           d - +1/-1: In-/Decrement (direction) for traversing through the array.
;; STACKING SPECIFICATION
;;        axis - 1/2/3: Stacking axis (X/Y/Z)
;; AREA SPECIFICATION
;;           x - X-position of the stacking area
;;           y - Y-position of the stacking area
;;           w - Width of the stacking area
;;           h - Height of the stacking area
;;     padding - Number of pixels to put between areas/windows.
Tiler_stackTiles(m, v, i, len, d, axis, x, y, w, h, padding, type = "") {
  Local dx, dy, tileH, tileW, tileX, tileY

  ;; d = +1: Left-to-right and top-to-bottom, depending on axis
  ;; d = -1: Right-to-left and bottom-to-top, depending on axis
  If (d < 0)
    i += len - 1

  tileX := x
  tileY := y
  tileW := w
  tileH := h
  dx := 0
  dy := 0
  If (axis = 1) {
    tileW := (w - (len - 1) * padding) / len
    dx := tileW + padding
  } Else If (axis = 2) {
    tileH := (h - (len - 1) * padding) / len
    dy := tileH + padding
  }
  ;; Else (axis = 3) and nothing to do

  Debug_logMessage("DEBUG[2] Tiler_stackTiles: start = " i ", length = " len, 2)
  Loop, % len {
    If (type = "blank")
      Tiler_addSubArea(m, v, i, tileX, tileY, tileW, tileH)
    Else
      Window_move(View_tiledWndId%i%, tileX, tileY, tileW, tileH)
    i += d
    tileX += dx
    tileY += dy
  }
}

Tiler_toggleStackArea(m ,v) {
  Global

  View_#%m%_#%v%_showStackArea := Not View_#%m%_#%v%_showStackArea
  If Not View_#%m%_#%v%_showStackArea
    View_#%m%_#%v%_layoutAxis_#3 := 3
}

Tiler_traceAreas(m, v, continuously) {
  Local h1, h2, n, w1, w2, wndTitle, x1, x2, y1, y2, y3

  x1 := Monitor_#%m%_x + View_#%m%_#%v%_layoutGapWidth + View_#%m%_#%v%_margin4
  y1 := Monitor_#%m%_y + View_#%m%_#%v%_layoutGapWidth + View_#%m%_#%v%_margin1
  w1 := Monitor_#%m%_width - 2 * View_#%m%_#%v%_layoutGapWidth - View_#%m%_#%v%_margin4 - View_#%m%_#%v%_margin2
  h1 := Monitor_#%m%_height - 2 * View_#%m%_#%v%_layoutGapWidth - View_#%m%_#%v%_margin1 - View_#%m%_#%v%_margin3
  wndTitle := "bug.n_TRACE_" m "_" v
  Gui, 98: Default
  Gui, Destroy
  Gui, -Caption +Disabled +ToolWindow
  Gui, +AlwaysOnTop
  Gui, Color, %Config_foreColor_#2_#1%
  Gui, Font, c%Config_fontColor_#1_#3% s%Config_largeFontSize%, %Config_fontName%

  n := View_#%m%_#%v%_area_#0
  Loop, % n {
    x2 := View_#%m%_#%v%_area_#%A_Index%_x - x1 + Config_borderWidth + Config_borderPadding
    y2 := View_#%m%_#%v%_area_#%A_Index%_y - y1 + Config_borderWidth + Config_borderPadding
    w2 := View_#%m%_#%v%_area_#%A_Index%_width - 2 * (Config_borderWidth + Config_borderPadding)
    h2 := View_#%m%_#%v%_area_#%A_Index%_height - 2 * (Config_borderWidth + Config_borderPadding)
    y3 := y2 + (h2 - Config_largeFontSize) / 2
    Gui, Add, Progress, x%x2% y%y2% w%w2% h%h2% Background%Config_backColor_#1_#3%
    Gui, Add, Text, x%x2% y%y3% w%w2% BackgroundTrans Center, % A_Index
    Debug_logMessage("DEBUG[2] View_traceAreas: i = " A_Index " / " n ", x = " x2 ", y = " y2 ", w = " w2 ", h = " h2, 2)
  }

  Gui, Show, NoActivate x%x1% y%y1% w%w1% h%h1%, %wndTitle%
  WinSet, Transparent, 191, % wndTitle
  If Not continuously {
    Sleep, % Config_areaTraceTimeout
    If Not Config_continuouslyTraceAreas
      Gui, Destroy
    Else
      WinSet, Bottom,, % wndTitle
  } Else
    WinSet, Bottom,, % wndTitle
}

;; vim:sts=2 ts=2 sw=2 et
