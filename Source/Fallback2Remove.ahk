; ========================================================================
; Fallback2Remove Tray Helper for Windows 11 (SOURCE CODE)
; Portable tray utility using native hotplug dialog

; full debug logging of heuristics | Embedded Icons | Selective Flush
; ========================================================================


;@Ahk2Exe-AddResource tray_idle.ico, 160
;@Ahk2Exe-AddResource tray_ready.ico, 170

#NoEnv
#SingleInstance force
#Persistent
SetBatchLines -1
SetWorkingDir %A_ScriptDir%

; --------------------------
; Globals
; --------------------------
global LogFile := A_ScriptDir "\Fallback2Remove.log"
global Devices := []
global DeviceCount := 0
global HotplugReadyCount := 0

global IconIdle := A_ScriptDir "\tray_idle.ico"
global IconReady := A_ScriptDir "\tray_ready.ico"

; --------------------------
; Init
; --------------------------
Log("Application started")
ScanDevices()
BuildTray()
SetTimer, RefreshDevices, 10000
return

; ==========================================================
; Tray Menu
; ==========================================================
BuildTray() {
    Menu, Tray, NoStandard
    Menu, Tray, Add, Open Safe Removal Dialog, OpenHotplug
    Menu, Tray, Add
    Menu, Tray, Add, Detected Disks:, Dummy
    Menu, Tray, Disable, Detected Disks:
    Menu, Tray, Add

    for i, dev in Devices {
        Menu, Tray, Add, % dev.Label, Dummy
        Menu, Tray, Disable, % dev.Label
    }

    Menu, Tray, Add
    Menu, Tray, Add, Refresh Device List, RefreshDevices
    Menu, Tray, Add
    Menu, Tray, Add, Exit, ExitApp

    UpdateTrayIcon()
}

UpdateTrayIcon() {
    global HotplugReadyCount, IconIdle, IconReady

    if (A_IsCompiled) {
        resID := (HotplugReadyCount > 0) ? 170 : 160
        hIcon := DllCall("LoadIcon", "Uint", DllCall("GetModuleHandle", "Uint", 0), "Uint", resID)
        if (hIcon) {
            SendMessage, 0x0080, 1, hIcon,, ahk_class Shell_TrayWnd
            Menu, Tray, Icon, HICON:%hIcon%
        }
    } else {
        if (HotplugReadyCount > 0) {
            Menu, Tray, Icon, %IconReady%
        } else {
            Menu, Tray, Icon, %IconIdle%
        }
    }

    if (HotplugReadyCount > 0) {
        Menu, Tray, Tip, % "Removable devices available: " HotplugReadyCount "`nClick to safely remove"
    } else {
        Menu, Tray, Tip, No removable devices detected
    }
}

; ==========================================================
; Device Detection
; ==========================================================
ScanDevices() {
    global Devices, DeviceCount, HotplugReadyCount

    Devices := []
    DeviceCount := 0
    HotplugReadyCount := 0

    wmi := ComObjGet("winmgmts:")
    disks := wmi.ExecQuery("SELECT DeviceID, Model, InterfaceType, MediaType, PNPDeviceID FROM Win32_DiskDrive")

    for disk in disks {
        DeviceCount++

        device := Object()
        device.Model := disk.Model
        device.DeviceID := disk.DeviceID
        device.Interface := disk.InterfaceType

        ; --------------------------
        ; Determine if eligible for hotplug
        ; --------------------------
        isExternal := InStr(disk.MediaType, "External") || InStr(disk.MediaType, "Removable")
        isUSBorSCSI := (disk.InterfaceType = "USB" || disk.InterfaceType = "SCSI")

        ; Assign class and label
        if (isExternal && isUSBorSCSI) {
            device.Class := "HOTPLUG_READY"
            device.Label := "[•] " disk.Model
            HotplugReadyCount++
        } else {
            device.Class := "INTERNAL"
            device.Label := "[X] Internal disk: " disk.Model
        }

        ; --------------------------
        ; Debug: log all heuristic-related variables
        ; --------------------------
        debugMsg := "DEBUG HEURISTIC: " disk.Model
        debugMsg .= " | DeviceID: " disk.DeviceID
        debugMsg .= " | InterfaceType: " disk.InterfaceType
        debugMsg .= " | MediaType: " disk.MediaType
        debugMsg .= " | PNPDeviceID: " disk.PNPDeviceID
        debugMsg .= " | IsExternal: " isExternal
        debugMsg .= " | IsUSBorSCSI: " isUSBorSCSI
        debugMsg .= " | Class assigned: " device.Class
        Log(debugMsg)

        Devices.Push(device)
    }

    Log("Scan complete - Total disks: " DeviceCount ", Hotplug ready: " HotplugReadyCount)
}

RefreshDevices:
    Menu, Tray, DeleteAll
    ScanDevices()
    BuildTray()
return

; ==========================================================
; Actions
; ==========================================================
OpenHotplug:
    Log("Action: Manual flush and opening native hotplug dialog")
    
    ; Garante que o cache seja gravado antes de tentar ejetar
    FlushAllVolumes()
    
    Run, rundll32.exe shell32.dll`,Control_RunDLL hotplug.dll
return

FlushAllVolumes() {
    DriveGet, DriveList, List
    Loop, Parse, DriveList
    {
        ; Ignora unidade C: para evitar lentidão desnecessária no sistema
        if (A_LoopField = "C") 
            continue

        DriveGet, DriveType, Type, %A_LoopField%:\
        if (DriveType = "Removable" || DriveType = "Fixed") {
            devicePath := "\\.\" A_LoopField ":"
            ; Abre o volume e força a gravação do cache (Flush)
            hVol := DllCall("CreateFile", "Str", devicePath, "UInt", 0xC0000000, "UInt", 3, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
            if (hVol != -1) {
                DllCall("FlushFileBuffers", "Ptr", hVol)
                DllCall("CloseHandle", "Ptr", hVol)
                Log("Flush successful for drive " A_LoopField ":")
            }
        }
    }
}

Dummy:
return

ExitApp:
    Log("Application exited")
    ExitApp
return

; ==========================================================
; Logging
; ==========================================================
Log(msg) {
    global LogFile
    FormatTime, ts,, yyyy-MM-dd HH:mm:ss
    FileAppend, % ts " - " msg "`r`n", %LogFile%, UTF-8
}
