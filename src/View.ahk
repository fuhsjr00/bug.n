/**
 *	bug.n - tiling window management
 *	Copyright (c) 2010-2012 joten
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *	@version 8.3.0
 */

View_init(m, v) {
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
	View_#%m%_#%v%_wndIds         := ""
}

View_activateWindow(d) {
	Local aWndId, i, j, v, wndId, wndId0, wndIds, failure, direction
	
	Log_dbg_msg(1, "View_activateWindow(" . d . ")")
	
	If (d = 0)
		Return
	
	WinGet, aWndId, ID, A
	Log_dbg_bare(2, "Active Windows ID: " . aWndId)
	v := Monitor_#%Manager_aMonitor%_aView_#1
	Log_dbg_bare(2, "View (" . v . ") wndIds: " . View_#%Manager_aMonitor%_#%v%_wndIds)
	StringTrimRight, wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, 1
	StringSplit, wndId, wndIds, `;
	Log_dbg_bare(2, "wndId count: " . wndId0)
	If (wndId0 > 1) {
		If Manager_#%aWndId%_isFloating
			Manager_winSet("Bottom", "", aWndId)
		Loop, % wndId0
			If (wndId%A_Index% = aWndId) {
				i := A_Index
				Break
			}
		If (d > 0) 
			direction = 1
		Else
			direction = -1
		Log_dbg_bare(2, "Current wndId index: " . i)
		j := Manager_loop(i, d, 1, wndId0)
		Loop, % wndId0 {
			Log_dbg_bare(2, "Next wndId index: " . j)
			wndId := wndId%j%
			Manager_winSet("AlwaysOnTop", "On", wndId)
			Manager_winSet("AlwaysOnTop", "Off", wndId)
			; This is a lot of extra work in case there are hung windows on the screen.
			; We still want to be able to cycle through them.
			failure := Manager_winActivate(wndId)
			If Not failure {
				Break
			}
			
			j := Manager_loop(j, direction, 1, wndId0)
		}
		
	}
}

View_updateLayout(m, v) {
	Local fn, l, wndIds
	l := View_#%m%_#%v%_layout_#1
	fn := Config_layoutFunction_#%l%
	View_updateLayout_%fn%(m, v)
}

; Add a window to the view in question.
View_addWnd(m, v, wndId) {
	Local l, msplit, i, wndIds, n
	
	l := View_#%m%_#%v%_layout_#1
	If (Config_layoutFunction_#%l% = "tile") And ((Config_newWndPosition = "masterBottom") Or (Config_newWndPosition = "stackTop")) {
		n := View_getTiledWndIds(m, v, wndIds)
		msplit := View_#%m%_#%v%_layoutMX * View_#%m%_#%v%_layoutMY
		If ( msplit = 1 And Config_newWndPosition="masterBottom" ) {
			View_#%m%_#%v%_wndIds := wndId ";" . View_#%m%_#%v%_wndIds
		}
		Else If ( (Config_newWndPosition="masterBottom" And n < msplit) Or (Config_newWndPosition="stackTop" And n <= msplit) ) {
			View_#%m%_#%v%_wndIds .= wndId ";"
		}
		Else {
			If (Config_newWndPosition="masterBottom")
				i := msplit - 1
			Else
				i := msplit
			StringSplit, wndId, wndIds, `;
			search  := wndId%i% ";"
			replace := search wndId ";"
			StringReplace, View_#%m%_#%v%_wndIds, View_#%m%_#%v%_wndIds, %search%, %replace%
		}
	}
	Else If (Config_newWndPosition = "bottom")
		View_#%m%_#%v%_wndIds .= wndId ";"
	Else
		View_#%m%_#%v%_wndIds := wndId ";" View_#%m%_#%v%_wndIds
}

View_ghostWnd(m, v, bodyWndId, ghostWndId) {
	Local search, replace
	
	search := bodyWndId ";"
	replace := search ghostWndId ";"
	StringReplace, View_#%m%_#%v%_wndIds, View_#%m%_#%v%_wndIds, %search%, %replace%
}

; Remove a window from the view in question.
View_delWnd(m, v, wndId) {
	StringReplace, View_#%m%_#%v%_wndIds, View_#%m%_#%v%_wndIds, %wndId%`;, 
}

View_arrange(m, v) {
	Local fn, l, wndIds
	Log_dbg_msg(1, "View_arrange(" . m . ", " . v . ")")
	; All window actions are performed on independent windows. A delay won't help.
	SetWinDelay, 0
	l := View_#%m%_#%v%_layout_#1
	fn := Config_layoutFunction_#%l%
	View_getTiledWndIds(m, v, wndIds)
	View_arrange_%fn%(m, v, wndIds)
	View_updateLayout(m, v)
	Bar_updateLayout(m)
	SetWinDelay, 10
}

View_getTiledWndIds(m, v, ByRef tiledWndIds) {
	Local n, wndIds
	
	StringTrimRight, wndIds, View_#%m%_#%v%_wndIds, 1
	Loop, PARSE, wndIds, `;
	{
		If Not Manager_#%A_LoopField%_isFloating And WinExist("ahk_id " A_LoopField) and Not Manager_isHung(A_LoopField) {
			n += 1
			tiledWndIds .= A_LoopField ";"
		}
	}
	
	Return, n
}

View_updateLayout_(m, v)
{
	View_#%m%_#%v%_layoutSymbol := "><>"
}

View_arrange_(m, v)
{
	; Place-holder
}

View_updateLayout_monocle(m, v)
{
	Local wndIds, wndId, wndId0
	StringTrimRight, wndIds, View_#%m%_#%v%_wndIds, 1
	StringSplit, wndId, wndIds, `;
	View_#%m%_#%v%_layoutSymbol := "[" wndId0 "]"
}

View_arrange_monocle(m, v, wndIds) {
	Local gw
	
	gw := View_#%m%_#%v%_layoutGapWidth
	
	StringTrimRight, wndIds, wndIds, 1
	StringSplit, View_arrange_monocle_wndId, wndIds, `;
	View_draw_stack("View_arrange_monocle_wndId", 1, View_arrange_monocle_wndId0, 0, Monitor_#%m%_x, Monitor_#%m%_y, Monitor_#%m%_width, Monitor_#%m%_height, gw/2)
}

View_rotateLayoutAxis(i, d) {
	Local f, l, v, n, tmp
	
	v := Monitor_#%Manager_aMonitor%_aView_#1
	l := View_#%Manager_aMonitor%_#%v%_layout_#1
	If (Config_layoutFunction_#%l% = "tile") And (i = 1 Or i = 2 Or i = 3) {
		If (i = 1) {
			If (d = +2)
				View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% *= -1
			Else {
				f := View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% / Abs(View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%)
				View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% := f * Manager_loop(Abs(View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%), d, 1, 2)
			}
		} Else {
			n := Manager_loop(View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%, d, 1, 3)
			; When we rotate the axis, we may need to swap the X and Y dimensions.
			; We only need to check this when the master axis changes (i = 2)
			; If the axis doesn't change, there's no need to adjust (Not (n = View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%))
			; If the original axis was 1 (X) or the new axis is 1 (X)  (Y and Z are defined to be the same)
			If (i = 2) And Not (n = View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i%) And ((n = 1) Or (View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% = 1)) {
				tmp := View_#%Manager_aMonitor%_#%v%_layoutMX
				View_#%Manager_aMonitor%_#%v%_layoutMX := View_#%Manager_aMonitor%_#%v%_layoutMY
				View_#%Manager_aMonitor%_#%v%_layoutMY := tmp
			}
			View_#%Manager_aMonitor%_#%v%_layoutAxis_#%i% := n
		}
		View_arrange(Manager_aMonitor, v)
	}
}

View_setGapWidth(d) {
	Local l, v, w
	
	v := Monitor_#%Manager_aMonitor%_aView_#1
	l := View_#%Manager_aMonitor%_#%v%_layout_#1
	If (Config_layoutFunction_#%l% = "tile") {
        If (d < 0)
            d := Floor(d / 2) * 2
        Else
            d := Ceil(d / 2) * 2
        w := View_#%Manager_aMonitor%_#%v%_layoutGapWidth + d
		If (w < Monitor_#%Manager_aMonitor%_height And w < Monitor_#%Manager_aMonitor%_width) {
			View_#%Manager_aMonitor%_#%v%_layoutGapWidth := w
			View_arrange(Manager_aMonitor, v)
		}
	}
}

View_setLayout(l) {
	Local v
	
	v := Monitor_#%Manager_aMonitor%_aView_#1
	If (l = -1)
		l := View_#%Manager_aMonitor%_#%v%_layout_#2
	If (l = ">")
		l := Manager_loop(View_#%Manager_aMonitor%_#%v%_layout_#1, +1, 1, Config_layoutCount)
	If (l > 0) And (l <= Config_layoutCount) {
		If Not (l = View_#%Manager_aMonitor%_#%v%_layout_#1) {
			View_#%Manager_aMonitor%_#%v%_layout_#2 := View_#%Manager_aMonitor%_#%v%_layout_#1
			View_#%Manager_aMonitor%_#%v%_layout_#1 := l
		}
		View_arrange(Manager_aMonitor, v)
	}
}

View_setMFactor(d) {
	Local l, mfact, v
	
	v := Monitor_#%Manager_aMonitor%_aView_#1
	l := View_#%Manager_aMonitor%_#%v%_layout_#1
	If (Config_layoutFunction_#%l% = "tile") {
		mfact := View_#%Manager_aMonitor%_#%v%_layoutMFact + d
		If (mfact >= 0.05 And mfact <= 0.95) {
			View_#%Manager_aMonitor%_#%v%_layoutMFact := mfact
			View_arrange(Manager_aMonitor, v)
		}
	}
}

View_setMX(d) {
	Local l, n, m, v
	
	m := Manager_aMonitor
	v := Monitor_#%m%_aView_#1
	l := View_#%m%_#%v%_layout_#1
	If Not (Config_layoutFunction_#%l% = "tile")
		Return
	
	n := View_#%m%_#%v%_layoutMX + d
	If (n >= 1) And (n <= 9) {
		View_#%m%_#%v%_layoutMX := n
		View_arrange(m, v)
	}
}

View_setMY(d) {
	Local l, n, m, v
	
	m := Manager_aMonitor
	v := Monitor_#%m%_aView_#1
	l := View_#%m%_#%v%_layout_#1
	If Not (Config_layoutFunction_#%l% = "tile")
		Return
	
	n := View_#%m%_#%v%_layoutMY + d
	If (n >= 1) And (n <= 9) {
		View_#%m%_#%v%_layoutMY := n
		View_arrange(m, v)
	}
}

View_shuffleWindow(d) {
	Local aWndHeight, aWndId, aWndWidth, aWndX, aWndY, i, j, l, search, v, wndId0, wndIds
	
	WinGet, aWndId, ID, A
	v := Monitor_#%Manager_aMonitor%_aView_#1
	l := View_#%Manager_aMonitor%_#%v%_layout_#1
	If (Config_layoutFunction_#%l% = "tile" And InStr(Manager_managedWndIds, aWndId ";")) {
		View_getTiledWndIds(Manager_aMonitor, v, wndIds)
		StringTrimRight, wndIds, wndIds, 1
		StringSplit, wndId, wndIds, `;
		If (wndId0 > 1) {
			Loop, % wndId0
				If (wndId%A_Index% = aWndId) {
					i := A_Index
					Break
				}
			If (d = 0 And i = 1)
				j := 2
			Else
				j := Manager_loop(i, d, 1, wndId0)
			If (j > 0 And j <= wndId0) {
				If (j = i) {
					StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, %aWndId%`;, 
					View_#%Manager_aMonitor%_#%v%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%v%_wndIds
				} Else {
					search := wndId%j%
					StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, %aWndId%, SEARCH
					StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, %search%, %aWndId%
					StringReplace, View_#%Manager_aMonitor%_#%v%_wndIds, View_#%Manager_aMonitor%_#%v%_wndIds, SEARCH, %search%
				}
				View_arrange(Manager_aMonitor, v)
				
				If Config_mouseFollowsFocus {
					WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
					DllCall("SetCursorPos", "Int", Round(aWndX + aWndWidth / 2), "Int", Round(aWndY + aWndHeight / 2))
				}
			}
		}
	}
}

View_updateLayout_tile(m, v) {
	Local axis1, axis2, axis3, mp, ms, sym1, sym3, master_div, master_dim, master_sym, stack_sym
	
	; Main axis
	; 1 - vertical divider, master left
	; 2 - horizontal divider, master top
	; -1 - vertical divider, master right
	; -2 - horizontal divider, master bottom
	axis1  := View_#%m%_#%v%_layoutAxis_#1
	; Master axis
	; 1 - vertical divider
	; 2 - horizontal divider
	; 3 - monocle
	axis2  := View_#%m%_#%v%_layoutAxis_#2
	; Stack axis
	; 1 - vertical divider
	; 2 - horizontal divider
	; 3 - monocle
	axis3  := View_#%m%_#%v%_layoutAxis_#3
	mx := View_#%m%_#%v%_layoutMX
	my := View_#%m%_#%v%_layoutMY
	
	If ( Abs(axis1) = 1 )
		master_div := "|"
	Else
		master_div := "="
	
	If ( axis2 = 1 ) {
		master_sym := "|"
		master_dim := mx . "x" . my
		}
	Else If ( axis2 = 2 ) {
		master_sym := "-"
		master_dim := mx . "x" . my
	}
	Else 
		master_sym := "[" . (mx * my) . "]"
	
	If ( axis3 = 1 )
		stack_sym := "|"
	Else If ( axis3 = 2 )
		stack_sym := "-"
	Else
		stack_sym := "o"
	
	If ( axis1 > 0 )
		View_#%m%_#%v%_layoutSymbol := master_dim . master_sym . master_div . stack_sym
	Else
		View_#%m%_#%v%_layoutSymbol := stack_sym . master_div . master_sym . master_dim
}

; Stack a bunch of windows on top of each other.
;
; arrName - Name of a globally stored array of windows:
;   %arrName%1, %arrName%2, ...
; off - Offset into the array from which to start drawing.
; len - Number of windows from the array to draw.
; dir - Determines the direction through which we traverse arrName
; x - View x-position
; y - View y-position
; w - View width
; h - View height
; margin - Number of pixels to put between the windows.
View_draw_stack( arrName, off, len, dir, x, y, w, h, margin ) {
	Local base, inc
	If (dir = 0) {
		base := off
		inc := 1
	}
	Else {
		base := off + len - 1
		inc := -1
	}
	x += margin
	y += margin
	w -= 2 * margin
	h -= 2 * margin
	
	Loop, % len {
		Manager_winMove(%arrName%%base%, x, y, w, h)
		base += inc
	}
}

; Draw a row of windows.
; 
; arrName - Name of a globally stored array of windows:
;   %arrName%1, %arrName%2, ...
; off - Offset into the array from which to start drawing.
; len - Number of windows from the array to draw.
; dir - Determines the direction through which we traverse arrName
; axis - X/Y <=> 0/1
; x - View x-position
; y - View y-position
; w - View width
; h - View height
; margin - Number of pixels to put between the windows.
View_draw_row( arrName, off, len, dir, axis, x, y, w, h, margin ) {
	Local base, inc, x_inc, y_inc, wHeight, wWidth
	;Log_bare("View_draw_row(" . arrName . ", " . off . ", " . len . ", " . dir . ", " . axis . ", " . x . ", " . y . ", " . w . ", " . h . ", " . margin . ")")
	If (dir = 0) {
		; Left-to-right and top-to-bottom, depending on axis
		base := off
		inc := 1
	}
	Else {
		; Right-to-left and bottom-to-top, depending on axis
		base := off + len - 1
		inc := -1
	}
	If (axis = 0) {
		; Create row along X
		x_inc := w / len
		y_inc := 0
		wWidth := x_inc - 2 * margin
		wHeight := h - 2 * margin
	}
	Else {
		; Create row along Y
		x_inc := 0
		y_inc := h / len
		wWidth := w - 2 * margin
		wHeight := y_inc - 2 * margin
	}
	
	; Set original positions with respect to the margins.
	x += margin
	y += margin
	
	Loop, % len {
		Manager_winMove(%arrName%%base%, x, y, wWidth, wHeight)
		x += x_inc
		y += y_inc
		base += inc
	}
}

View_arrange_tile_action(arrName, off, len, bugn_axis, x, y, w, h, m) {
	; 161 is a magic number determined somewhere. Maybe make this configurable.
	; Same with 2*Bar_height.
	If (bugn_axis = 3 Or (bugn_axis = 1 And w/len < 161) Or (bugn_axis = 2 And h/len < (2*Bar_height))) 
		View_draw_stack(arrName, off, len, 0, x, y, w, h, m)
	Else
		View_draw_row(arrName, off, len, 0, bugn_axis - 1, x, y, w, h, m)
}

View_split_region(axis, split_point, x, y, w, h, ByRef x1, ByRef y1, ByRef w1, ByRef h1, ByRef x2, ByRef y2, ByRef w2, ByRef h2) {
	x1 := x
	y1 := y
	If(axis = 0) {
		w1 := w * split_point
		w2 := w - w1
		h1 := h
		h2 := h
		x2 := x + w1
		y2 := y
	}
	Else
	{
		w1 := w
		w2 := w
		h1 := h * split_point
		h2 := h - h1
		x2 := x
		y2 := y + h1
	}
}

View_arrange_tile(m, v, wndIds) {
	Local axis1, axis2, axis3, gapW_2, h1, h2, i, mfact, mp, ms, mx2, my2, mw2, mh2, msplit, n1, n2, w1, w2, x1, x2, y1, y2, flipped, stack_len, secondary_areas, areas_remaining, draw_windows
	
	StringTrimRight, wndIds, wndIds, 1
	StringSplit, View_arrange_tile_wndId, wndIds, `;
	Log_dbg_msg(1, "View_arrange_tile: (" . View_arrange_tile_wndId0 . ") " . wndIds)
	If (View_arrange_tile_wndId0 = 0)
		Return

	axis1  := Abs(View_#%m%_#%v%_layoutAxis_#1)
	axis2  := View_#%m%_#%v%_layoutAxis_#2
	axis3  := View_#%m%_#%v%_layoutAxis_#3
	flipped := View_#%m%_#%v%_layoutAxis_#1 < 0
	gapW_2 := View_#%m%_#%v%_layoutGapWidth/2
	mfact  := View_#%m%_#%v%_layoutMFact
	dimAligned := (axis2 = 1) ? View_#%m%_#%v%_layoutMX : View_#%m%_#%v%_layoutMY
	dimOrtho := (axis2 = 1) ? View_#%m%_#%v%_layoutMY : View_#%m%_#%v%_layoutMX
	msplit := dimAligned * dimOrtho

	If (msplit > View_arrange_tile_wndId0) {
		msplit := View_arrange_tile_wndId0
	}
	
	; master and stack area
	If( View_arrange_tile_wndId0 > msplit) {
		If( flipped = 0)
			View_split_region( axis1 - 1, mfact, Monitor_#%m%_x, Monitor_#%m%_y, Monitor_#%m%_width, Monitor_#%m%_height, x1, y1, w1, h1, x2, y2, w2, h2)
		Else
			View_split_region( axis1 - 1, 1 - mfact, Monitor_#%m%_x, Monitor_#%m%_y, Monitor_#%m%_width, Monitor_#%m%_height, x2, y2, w2, h2, x1, y1, w1, h1)
	}
	Else {
		x1 := Monitor_#%m%_x
		y1 := Monitor_#%m%_y
		w1 := Monitor_#%m%_width
		h1 := Monitor_#%m%_height
	}
	
	; master
	; Number 
	If( axis2 = 3 )
	{
		View_draw_stack("View_arrange_tile_wndId", 1, msplit, 0, x1, y1, w1, h1, gapW_2)
	}
	Else
	{
		secondary_areas := Ceil(msplit / dimAligned)
		areas_remaining := secondary_areas
		windows_remaining := msplit
		;Log_bare("msplit: " . msplit . "; layoutMX/Y: " . dimAligned . "; secondary_areas: " . secondary_areas . "; areas_remaining: " . areas_remaining . "; windows_remaining: " . windows_remaining)
		Loop, % secondary_areas {
			View_split_region(Not (axis2 - 1), (1/areas_remaining), x1, y1, w1, h1, mx1, my1, mw1, mh1, x1, y1, w1, h1)
			draw_windows := dimAligned
			If (windows_remaining < dimAligned) {
				draw_windows := windows_remaining
			}
			View_draw_row("View_arrange_tile_wndId", msplit - windows_remaining + 1, draw_windows, 0, axis2 - 1, mx1, my1, mw1, mh1, gapW_2)
			windows_remaining -= draw_windows
			areas_remaining -= 1
		}
	}
	
	; stack
	If (View_arrange_tile_wndId0 <= msplit) 
		Return
	
	stack_len := View_arrange_tile_wndId0 - msplit
	View_arrange_tile_action("View_arrange_tile_wndId", msplit + 1, stack_len, axis3, x2, y2, w2, h2, gapW_2)
}

View_toggleFloating() {
	Local aWndId, l, v
	
	WinGet, aWndId, ID, A
	v := Monitor_#%Manager_aMonitor%_aView_#1
	l := View_#%Manager_aMonitor%_#%v%_layout_#1
	If (Config_layoutFunction_#%l% And InStr(Manager_managedWndIds, aWndId ";")) {
		Manager_#%aWndId%_isFloating := Not Manager_#%aWndId%_isFloating
		View_arrange(Manager_aMonitor, v)
		Bar_updateTitle()
	}
}
