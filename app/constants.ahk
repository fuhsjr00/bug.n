/*
:title:     bug.n/constants
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

class Constants {
  __New() {
    ;; Windows CONSTANTS
    this.S_OK := 0x0
    
    ;; Windows CONSTANTS - Monitor
    ;; enum _PROCESS_DPI_AWARENESS
    this.PROCESS_DPI_UNAWARE                        :=  0
    this.PROCESS_SYSTEM_DPI_AWARE                   :=  1
    this.PROCESS_PER_MONITOR_DPI_AWARE              :=  2
    this.DPI_AWARENESS_CONTEXT_UNAWARE              := -1
    this.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE         := -2
    this.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE    := -3
    this.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 := -4
    
    ;; Windows CONSTANTS - Monitor
    ;; enum _MONITOR_DPI_TYPE
    this.MDT_EFFECTIVE_DPI  := 0
    this.MDT_ANGULAR_DPI    := 1
    this.MDT_RAW_DPI        := 2
    this.MDT_DEFAULT        := this.MDT_EFFECTIVE_DPI
    
    ;; Windows CONSTANTS - Monitor
    this.SPI_SETWORKAREA    := 0x2F
    
    ;; Windows CONSTANTS - GUI
    this.FEATURE_DISABLE_NAVIGATION_SOUNDS := 21
    this.SET_FEATURE_ON_PROCESS            := 0x00000002
    
    ;; Windows CONSTANTS - ShellHook
    this.HSHELL_WINDOWCREATED       :=  1       ;; *
    this.HSHELL_WINDOWDESTROYED     :=  2       ;; *
    this.HSHELL_ACTIVATESHELLWINDOW :=  3
    this.HSHELL_WINDOWACTIVATED     :=  4       ;; *
    this.HSHELL_GETMINRECT          :=  5
    this.HSHELL_REDRAW              :=  6       ;; *
    this.HSHELL_TASKMAN             :=  7
    this.HSHELL_LANGUAGE            :=  8
    this.HSHELL_SYSMENU             :=  9
    this.HSHELL_ENDTASK             := 10       ;; *
    this.HSHELL_ACCESSIBILITYSTATE  := 11
    this.HSHELL_APPCOMMAND          := 12
    this.HSHELL_WINDOWREPLACED      := 13       ;; *
    this.HSHELL_WINDOWREPLACING     := 14       ;; *
    this.HSHELL_MONITORCHANGED      := 16       ;; *
    this.HSHELL_HIGHBIT             := 32768    ;; 0x8000
    this.HSHELL_RUDEAPPACTIVATED    := 32772    ;; * (HSHELL_WINDOWACTIVATED|HSHELL_HIGHBIT)
    this.HSHELL_FLASH               := 32774    ;; * (HSHELL_REDRAW|HSHELL_HIGHBIT)
    this.HSHELL_messages := []
    this.HSHELL_messages[1]     := "WINDOWCREATED"
    this.HSHELL_messages[2]     := "WINDOWDESTROYED"
    this.HSHELL_messages[3]     := "ACTIVATESHELLWINDOW"
    this.HSHELL_messages[4]     := "WINDOWACTIVATED"
    this.HSHELL_messages[5]     := "GETMINRECT"
    this.HSHELL_messages[6]     := "REDRAW"
    this.HSHELL_messages[7]     := "TASKMAN"
    this.HSHELL_messages[8]     := "LANGUAGE"
    this.HSHELL_messages[9]     := "SYSMENU"
    this.HSHELL_messages[10]    := "ENDTASK"
    this.HSHELL_messages[11]    := "ACCESSIBILITYSTATE"
    this.HSHELL_messages[12]    := "APPCOMMAND"
    this.HSHELL_messages[13]    := "WINDOWREPLACED"
    this.HSHELL_messages[14]    := "WINDOWREPLACING"
    this.HSHELL_messages[15]    := ""
    this.HSHELL_messages[16]    := "MONITORCHANGED"
    this.HSHELL_messages[17]    := ""
    this.HSHELL_messages[32768] := "HIGHBIT"
    this.HSHELL_messages[32772] := "RUDEAPPACTIVATED"
    this.HSHELL_messages[32774] := "FLASH"
    
    ;; Windows CONSTANTS - Window
    this.DWMWA_CLOAK         :=  13
    this.DWMWA_CLOAKED       :=  14
    this.DWMWA_EXTENDED_FRAME_BOUNDS := 9
    this.GW_OWNER            :=   4
    this.WM_DISPLAYCHANGE    := 126              ;; This message is sent when the display resolution has changed.
    this.WM_ENTERSIZEMOVE    := 0x00000231
    this.WM_EXITSIZEMOVE     := 0x00000232
    this.WM_NULL             := 0
    this.WS_CAPTION          := 0x00C00000
    this.WS_CHILD            := 0x40000000
    this.WS_CLIPCHILDREN     := 0x2000000
    this.WS_DISABLED         := 0x8000000
    this.WS_EX_APPWINDOW     := 0x0040000
    this.WS_EX_CONTROLPARENT := 0x0010000
    this.WS_EX_DLGMODALFRAME := 0x0000001
    this.WS_EX_TOOLWINDOW    := 0x00000080
    this.WS_EX_TOPMOST       := 0x00000008
    this.WS_POPUP            := 0x80000000
    this.WS_VSCROLL          := 0x200000
  }
}
