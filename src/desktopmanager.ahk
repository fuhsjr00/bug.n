/*
:title:     bug.n/desktopmanager
:copyright: (c) 2019 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

:bibliography:
[1] qwerty12 (2916) [Windows 10] Switch to different virtual desktop on Win+{1,9}. [source code]
    https://www.autohotkey.com/boards/viewtopic.php?f=6&t=14881
[2] Flipeador (2018) How to call a Win32 API with UUID [IVirtualDesktopManager]. [source code]
    https://www.autohotkey.com/boards/viewtopic.php?t=54202
[3] Markus Scholtes (2019) Powershell commands to manage virtual desktops of Windows 10. (version 2.2) [source code]
    https://gallery.technet.microsoft.com/scriptcenter/Powershell-commands-to-d0e79cc5
*/

/*
ImmersiveShell                  := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
IVirtualDesktopManagerInternal  := ComObjQuery(ImmersiveShell,   "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{AF8DA486-95BB-4460-B3B7-6E7A6B2962B5}")
IServiceProvider                := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")
IVirtualDesktopManagerInternal  := ComObjQuery(IServiceProvider, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{F31574D6-B682-4CDC-BD56-1827860ABEC6}")
GetCount                        := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) +  3 * A_PtrSize)
MoveViewDesktop                 := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) +  4 * A_PtrSize)
CanViewMoveDesktops             := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) +  5 * A_PtrSize)
GetCurrentDesktop               := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) +  6 * A_PtrSize)
GetDesktops                     := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) +  7 * A_PtrSize)
GetAdjacentDesktop              := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) +  8 * A_PtrSize)
SwitchDesktop                   := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) +  9 * A_PtrSize)
CreateDesktop                   := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) + 10 * A_PtrSize)
RemoveDesktop                   := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) + 11 * A_PtrSize)
FindDesktop                     := NumGet(NumGet(IVirtualDesktopManagerInternal + 0) + 12 * A_PtrSize)

IVirtualDesktopManager          := ComObjCreate("{AA509086-5CA9-4C25-8F95-589D3C07B48A}", "{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}")
IsWindowOnCurrentVirtualDesktop := NumGet(NumGet(IVirtualDesktopManager + 0) + 3 * A_PtrSize)
GetWindowDesktopId              := NumGet(NumGet(IVirtualDesktopManager + 0) + 4 * A_PtrSize)
MoveWindowToDesktop             := NumGet(NumGet(IVirtualDesktopManager + 0) + 5 * A_PtrSize)

GetCount                        := NumGet(NumGet(IObjectArray + 0) + 3 * A_PtrSize)
GetAt                           := NumGet(NumGet(IObjectArray + 0) + 4 * A_PtrSize)
*/

class DesktopManager {
  __New(funcObject) {
    Global logger
    
    this.desktops := []
    
    ImmersiveShell   := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
    IServiceProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")
    
    this.IVirtualDesktopManagerInternal := ComObjQuery(IServiceProvider, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{F31574D6-B682-4CDC-BD56-1827860ABEC6}")
    If (!this.IVirtualDesktopManagerInternal) {
      logger.warning("Could not query IVirtualDesktopManagerInternal from IServiceProvider, trying ImmersiveShell.", "DesktopManager.__New")
      this.IVirtualDesktopManagerInternal := ComObjQuery(ImmersiveShell,   "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{AF8DA486-95BB-4460-B3B7-6E7A6B2962B5}")
    }
    this.getDesktops()
    
    OnMessage(DllCall("RegisterWindowMessage", "Str", "TaskbarCreated"), funcObject)
    logger.info("'TaskbarCreated' message registered to function " . funcObject.Name, "DesktopManager.__New")
    ObjRelease(ImmersiveShell)
    ObjRelease(IServiceProvider)
  }
  
  __Delete() {
    If (this.IVirtualDesktopManagerInternal) {
      ObjRelease(this.IVirtualDesktopManagerInternal)
    }
  }
  
  createDesktop() {
    Global logger
    
    IVirtualDesktop := ""
    ICreateDesktop := NumGet(NumGet(this.IVirtualDesktopManagerInternal + 0) + 10 * A_PtrSize)
    DllCall(ICreateDesktop, "UPtr", this.IVirtualDesktopManagerInternal, "UPtrP", IVirtualDesktop, "UInt")
    GUID := this.getDesktopId(IVirtualDesktop)
    this.desktops.push({GUID: GUID, IVirtualDesktop: IVirtualDesktop})
    logger.info("New desktop created with GUID " . GUID . ".", "DesktopManager.createDesktop")
  }
  
  getCurrentDesktop() {
    IVirtualDesktop := ""
    IGetCurrentDesktop := NumGet(NumGet(this.IVirtualDesktopManagerInternal + 0) +  6 * A_PtrSize)
    DllCall(IGetCurrentDesktop, "UPtr", this.IVirtualDesktopManagerInternal, "UPtr", IVirtualDesktop, "UInt")
    Return, IVirtualDesktop
  }
  
  getCurrentDesktopIndex(winId := 0) {
    Global logger
    
    If (winId != 0) {
      GUID := this.getWindowDesktopId(winId)
    } Else {
      GUID := this.getDesktopId(this.getCurrentDesktop())
    }
    index := 0
    For i, desktop in this.desktops {
      If (desktop.GUID == GUID) {
        index := i
        Break
      }
    }
    logger.info("Current desktop found at index " . index . ".", "DesktopManager.getCurrentDesktopIndex")
    Return, index
  }
  
  getDesktopId(IVirtualDesktop) {
    GUID := 0
    IGetId := NumGet(NumGet(IVirtualDesktop + 0) + 4 * A_PtrSize)
    DllCall(IGetId, "UPtr", IVirtualDesktop, "UPtr", &GUID, "UInt")
    VarSetCapacity(strGUID, (38 + 1) * 2)
    DllCall("Ole32.dll\StringFromGUID2", "UPtr", &GUID, "UPtr", &strGUID, "Int", 38 + 1)
    GUID := StrGet(&strGUID, "UTF-16")
    
    Return, GUID
  }
  
  getDesktops() {
    Global logger
    
    this.desktops := []
    IObjectArray  := 0
    IGetDesktops  := NumGet(NumGet(this.IVirtualDesktopManagerInternal + 0) +  7 * A_PtrSize)
    DllCall(IGetDesktops, "UPtr", this.IVirtualDesktopManagerInternal, "UPtrP", IObjectArray, "UInt")
    
    n := 0
    IGetCount := NumGet(NumGet(IObjectArray + 0) + 3 * A_PtrSize)
    DllCall(IGetCount, "UPtr", IObjectArray, "UIntP", n, "UInt")
    logger.info(n . " desktop" . (n == 1 ? "" : "s") . " found.", "DesktopManager.getDesktops")
    
    IVirtualDesktop := 0
    VarSetCapacity(GUID, 16)
    Loop % n {
        ; https://github.com/nullpo-head/Windows-10-Virtual-Desktop-Switching-Shortcut/blob/master/VirtualDesktopSwitcher/VirtualDesktopSwitcher/VirtualDesktops.h
        DllCall("Ole32.dll\CLSIDFromString", "Str", "{FF72FFDD-BE7E-43FC-9C03-AD81681E88E4}", "UPtr", &GUID)
        IGetAt := NumGet(NumGet(IObjectArray + 0) + 4 * A_PtrSize)
        DllCall(IGetAt, "UPtr", IObjectArray, "UInt", A_Index - 1, "UPtr", &GUID, "UPtrP", IVirtualDesktop, "UInt")
        
        GUID := this.getDesktopId(IVirtualDesktop)
        this.desktops[A_Index] := {GUID: GUID, IVirtualDesktop: IVirtualDesktop}
        logger.info("Desktop with GUID " . GUID . " added at index " . A_Index . ".", "DesktopManager.getDesktops")
    }
  }
  
  getWindowDesktopId(winId) {
    Global logger
    
    VarSetCapacity(GUID, 16)
    IVirtualDesktopManager := ComObjCreate("{AA509086-5CA9-4C25-8F95-589D3C07B48A}", "{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}")
    IGetWindowDesktopId := NumGet(NumGet(IVirtualDesktopManager + 0) + 4 * A_PtrSize)
    DllCall(IGetWindowDesktopId, "UPtr", IVirtualDesktopManager, "UInt", winId, "UPtr", &GUID, "UInt")
    
    VarSetCapacity(strGUID, (38 + 1) * 2)
    DllCall("Ole32.dll\StringFromGUID2", "UPtr", &GUID, "UPtr", &strGUID, "Int", 38 + 1)
    GUID := StrGet(&strGUID, "UTF-16")
    
    ObjRelease(IVirtualDesktopManager)
    logger.debug("Window with id " . winId . " found on desktop with GUID " . GUID . ".", "DesktopManager.getWindowDesktopId")
    
    Return, GUID
  }
  
  removeDesktop() {
    Global logger
    
    i := this.getCurrentDesktopIndex()
    j := (i == 1 ? 2 : i - 1)
    removeIVirtualDesktop   := this.desktops[i].IVirtualDesktop
    fallbackIVirtualDesktop := this.desktops[j].IVirtualDesktop
    IRemoveDesktop := NumGet(NumGet(this.IVirtualDesktopManagerInternal + 0) + 11 * A_PtrSize)
    DllCall(IRemoveDesktop, "UPtr", this.IVirtualDesktopManagerInternal, "UPtr", removeIVirtualDesktop, "UPtr", fallbackIVirtualDesktop, "UInt")
    this.desktops.RemoveAt(i)
    logger.warning("Desktop removed at index " . i . " switching to desktop at index " . j . ".", "DesktopManager.removeDesktop")
  }
  
  switchDesktop(index) {
    Global logger
    
    If (index <= this.desktops.Length()) {
      ISwitchDesktop := NumGet(NumGet(this.IVirtualDesktopManagerInternal + 0) +  9 * A_PtrSize)
      DllCall(ISwitchDesktop, "UPtr", this.IVirtualDesktopManagerInternal, "UPtr", this.desktops[index].IVirtualDesktop, "UInt")
      logger.info("Switched to desktop at index " . index . ".", "DesktopManager.switchDesktop")
    }
  }
}
