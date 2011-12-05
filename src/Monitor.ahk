/**
 *	bug.n - tiling window management
 *	Copyright (c) 2010-2011 joten
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
 *	@version 8.2.1.02 (18.09.2011)
 */

Monitor_init(m) {
	Global
	
	Monitor_#%m%_aView_#1 := 1
	Monitor_#%m%_aView_#2 := 1
	Monitor_#%m%_showBar  := Config_showBar
	Loop, % Config_viewCount
		View_init(m, A_Index)
	Config_restore("Monitor", m)
	Monitor_getWorkArea(m)
	Bar_init(m)
}

Monitor_activateView(v) {
	Local aView, aWndClass, aWndId, aWndTitle, m, n, wndId, wndIds
	
	If (v = -1)
		v := Monitor_#%Manager_aMonitor%_aView_#2
	Else If (v = ">")
		v := Manager_loop(Monitor_#%Manager_aMonitor%_aView_#1, +1, 1, Config_viewCount)
	Else If (v = "<")
		v := Manager_loop(Monitor_#%Manager_aMonitor%_aView_#1, -1, 1, Config_viewCount)
	If (v > 0) And (v <= Config_viewCount) And Not Manager_hideShow And Not (v = Monitor_#%Manager_aMonitor%_aView_#1) {
		aView := Monitor_#%Manager_aMonitor%_aView_#1
		WinGet, aWndId, ID, A
		If WinExist("ahk_id" aWndId) {
			WinGetClass, aWndClass, ahk_id %aWndId%
			WinGetTitle, aWndTitle, ahk_id %aWndId%
			If Not (aWndClass = "Progman") And Not (aWndClass = "AutoHotkeyGui" And SubStr(aWndTitle, 1, 10) = "bug.n_BAR_") And Not (aWndClass = "DesktopBackgroundClass")
				View_#%Manager_aMonitor%_#%aView%_aWndId := aWndId
		}
		
		n := Config_syncMonitorViews
		If (n = 1)
			n := Manager_monitorCount
		Else If (n < 1)
			n := 1
		Loop, % n {
			If (n = 1)
				m := Manager_aMonitor
			Else
				m := A_Index
			
			Monitor_#%m%_aView_#2 := aView
			Monitor_#%m%_aView_#1 := v
			
			Manager_hideShow := True
			StringTrimRight, wndIds, View_#%m%_#%aView%_wndIds, 1
			Loop, PARSE, wndIds, `;
				If Not (Manager_#%A_LoopField%_tags & (1 << v - 1))
					WinHide, ahk_id %A_LoopField%
			StringTrimRight, wndIds, View_#%m%_#%v%_wndIds, 1
			Loop, PARSE, wndIds, `;
				WinShow, ahk_id %A_LoopField%
			Manager_hideShow := False
			
			Bar_updateView(m, aView)
			Bar_updateView(m, v)
			
			View_arrange(m, v)
		}
		
		wndId := View_#%Manager_aMonitor%_#%v%_aWndId
		If Not (wndId And WinExist("ahk_id" wndId)) {
			If View_#%Manager_aMonitor%_#%v%_wndIds
				wndId := SubStr(View_#%Manager_aMonitor%_#%v%_wndIds, 1, InStr(View_#%Manager_aMonitor%_#%v%_wndIds, ";")-1)
			Else
				wndId := 0
		}
		Manager_winActivate(wndId)
	}
}

Monitor_get(x, y) {
	Local m
	
	m := 0
	Loop, % Manager_monitorCount	; Check if the window is on this monitor.
		If (x >= Monitor_#%A_Index%_x && x <= Monitor_#%A_Index%_x+Monitor_#%A_Index%_width && y >= Monitor_#%A_Index%_y && y <= Monitor_#%A_Index%_y+Monitor_#%A_Index%_height) {
			m := A_Index
			Break
		}
	
	Return, m
}

Monitor_getWorkArea(m) {
	Local bTop, x, y
	Local monitor, monitorBottom, monitorLeft, monitorRight, monitorTop
	Local wndClasses, wndHeight, wndId, wndWidth, wndX, wndY
	
	SysGet, monitor, Monitor, %m%
	
	wndClasses := "Shell_TrayWnd"
	If Config_bbCompatibility
		wndClasses .= ";bbLeanBar;bbSlit;BBToolbar;SystemBarEx"
	Loop, PARSE, wndClasses, `;
	{
		wndId := WinExist("ahk_class " A_LoopField)
		If wndId {
			WinGetPos, wndX, wndY, wndWidth, wndHeight, ahk_id %wndId%
			x := wndX + wndWidth / 2
			y := wndY + wndHeight / 2
			If (x >= monitorLeft && x <= monitorRight && y >= monitorTop && y <= monitorBottom) {
				If (A_LoopField = "Shell_TrayWnd")
					Manager_taskBarMonitor := m
				
				If (wndHeight < wndWidth) {			; Horizontal
					If (wndY <= monitorTop) {			; Top
						wndHeight += wndY - monitorTop
						monitorTop += wndHeight
					} Else {							; Bottom
						wndHeight := monitorBottom - wndY
						monitorBottom -= wndHeight
					}
				} Else {							; Vertical
					If (wndX <= monitorLeft) {			; Left
						wndWidth += wndX
						monitorLeft += wndWidth
					} Else {							; Right
						wndWidth := monitorRight - wndX
						monitorRight -= wndWidth
					}
				}
			}
		}
	}
	If Monitor_#%m%_showBar {
		If (Config_verticalBarPos = "top" Or (Config_verticalBarPos = "tray" And Not m = Manager_taskBarMonitor)) {
			bTop := monitorTop
			monitorTop += Bar_height
		} Else If (Config_verticalBarPos = "bottom") {
			bTop := monitorBottom - Bar_height
			monitorBottom -= Bar_height
		}
	}
	
	Monitor_#%m%_height := monitorBottom - monitorTop
	Monitor_#%m%_width  := monitorRight - monitorLeft
	Monitor_#%m%_x      := monitorLeft
	Monitor_#%m%_y      := monitorTop
	Monitor_#%m%_barY   := bTop
}

Monitor_moveWindow(m, wndId) {
	Local fX, fY, monitor, wndHeight, wndWidth, wndX, wndY
	
	WinGetPos, wndX, wndY, wndWidth, wndHeight, ahk_id %wndId%
	monitor := Monitor_get(wndX+wndWidth/2, wndY+wndHeight/2)
	If Not (m = monitor) {
		; move the window to the target monitor and scale it, if it does not fit on the monitor
		fX := Monitor_#%m%_width / Monitor_#%monitor%_width
		fY := Monitor_#%m%_height / Monitor_#%monitor%_height
		If (wndX-Monitor_#%monitor%_x+wndWidth > Monitor_#%m%_width) Or (wndY-Monitor_#%monitor%_y+wndHeight > Monitor_#%m%_height)
			Manager_winMove(wndId, Monitor_#%m%_x+fX*(wndX-Monitor_#%monitor%_x), Monitor_#%m%_y+fY*(wndY-Monitor_#%monitor%_y), fX*wndWidth, fY*wndHeight)
		Else
			Manager_winMove(wndId, Monitor_#%m%_x+(wndX-Monitor_#%monitor%_x), Monitor_#%m%_y+(wndY-Monitor_#%monitor%_y), wndWidth, wndHeight)
	}
}

Monitor_setWindowTag(t) {
	Local aView, aWndId, wndId
	
	If (t = ">")
		t := Manager_loop(Monitor_#%Manager_aMonitor%_aView_#1, +1, 1, Config_viewCount)
	Else If (t = "<")
		t := Manager_loop(Monitor_#%Manager_aMonitor%_aView_#1, -1, 1, Config_viewCount)
	
	WinGet, aWndId, ID, A
	If (InStr(Manager_managedWndIds, aWndId ";") And t >= 0 And t <= Config_viewCount) {
		If (t = 0) {
			Loop, % Config_viewCount
				If Not (Manager_#%aWndId%_tags & (1 << A_Index - 1)) {
					View_#%Manager_aMonitor%_#%A_Index%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%A_Index%_wndIds
					View_#%Manager_aMonitor%_#%A_Index%_aWndId := aWndId
					Bar_updateView(Manager_aMonitor, A_Index)
					Manager_#%aWndId%_tags += 1 << A_Index - 1
				}
		} Else {
			Loop, % Config_viewCount
				If Not (A_index = t) {
					StringReplace, View_#%Manager_aMonitor%_#%A_Index%_wndIds, View_#%Manager_aMonitor%_#%A_Index%_wndIds, %aWndId%`;, 
					View_#%Manager_aMonitor%_#%A_Index%_aWndId := 0
					Bar_updateView(Manager_aMonitor, A_Index)
				}
			
			If Not (Manager_#%aWndId%_tags & (1 << t - 1))
				View_#%Manager_aMonitor%_#%t%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%t%_wndIds
			View_#%Manager_aMonitor%_#%t%_aWndId := aWndId
			Manager_#%aWndId%_tags := 1 << t - 1
			
			aView := Monitor_#%Manager_aMonitor%_aView_#1
			If Not (t = aView) {
				Manager_hideShow := True
				wndId := SubStr(View_#%Manager_aMonitor%_#%aView%_wndIds, 1, InStr(View_#%Manager_aMonitor%_#%aView%_wndIds, ";")-1)
				Manager_winActivate(wndId)
				Manager_hideShow := False
				If Config_viewFollowsTagged
					Monitor_activateView(t)
				Else {
					Manager_hideShow := True
					WinHide, ahk_id %aWndId%
					Manager_hideShow := False
					View_arrange(Manager_aMonitor, aView)
					Bar_updateView(Manager_aMonitor, t)
				}
			}
		}
	}
}

Monitor_toggleBar() {
	Global
	
	Monitor_#%Manager_aMonitor%_showBar := Not Monitor_#%Manager_aMonitor%_showBar
	Bar_toggleVisibility(Manager_aMonitor)
	Monitor_getWorkArea(Manager_aMonitor)
	View_arrange(Manager_aMonitor, Monitor_#%Manager_aMonitor%_aView_#1)
	Manager_winActivate(Bar_aWndId)
}

Monitor_toggleTaskBar() {
	Local m
	
	m := Manager_aMonitor
	If (m = Manager_taskBarMonitor) {
		Manager_showTaskBar := Not Manager_showTaskBar
		Manager_hideShow := True
		If Not Manager_showTaskBar {
			WinHide, Start ahk_class Button
			WinHide, ahk_class Shell_TrayWnd
		} Else {
			WinShow, Start ahk_class Button
			WinShow, ahk_class Shell_TrayWnd
		}
		Manager_hideShow := False
		Monitor_getWorkArea(m)
		Bar_move(m)
		View_arrange(m, Monitor_#%m%_aView_#1)
	}
}

Monitor_toggleWindowTag(t) {
	Local aWndId, wndId
	
	WinGet, aWndId, ID, A
	If (InStr(Manager_managedWndIds, aWndId ";") And t >= 0 And t <= Config_viewCount) {
		If (Manager_#%aWndId%_tags & (1 << t - 1)) {
			If Not ((Manager_#%aWndId%_tags - (1 << t - 1)) = 0) {
				Manager_#%aWndId%_tags -= 1 << t - 1
				StringReplace, View_#%Manager_aMonitor%_#%t%_wndIds, View_#%Manager_aMonitor%_#%t%_wndIds, %aWndId%`;, 
				Bar_updateView(Manager_aMonitor, t)
				If (t = Monitor_#%Manager_aMonitor%_aView_#1) {
					Manager_hideShow := True
					WinHide, ahk_id %aWndId%
					Manager_hideShow := False
					wndId := SubStr(View_#%Manager_aMonitor%_#%t%_wndIds, 1, InStr(View_#%Manager_aMonitor%_#%t%_wndIds, ";")-1)
					Manager_winActivate(wndId)
					View_arrange(Manager_aMonitor, t)
				}
			}
		} Else {
			View_#%Manager_aMonitor%_#%t%_wndIds := aWndId ";" View_#%Manager_aMonitor%_#%t%_wndIds
			View_#%Manager_aMonitor%_#%t%_aWndId := aWndId
			Bar_updateView(Manager_aMonitor, t)
			Manager_#%aWndId%_tags += 1 << t - 1
		}
	}
}
