# Fallback2Remove
## Safely Remove Fallback Utility for Windows 11 using hotplug.dll

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/License-MIT%202.0-blue.svg)
![GitHub stars](https://img.shields.io/github/stars/danbussoni/Fallback2Remove?style=social)
![GitHub forks](https://img.shields.io/github/forks/danbussoni/Fallback2Remove?style=social)
![GitHub issues](https://img.shields.io/github/issues/danbussoni/Fallback2Remove)
![GitHub last commit](https://img.shields.io/github/last-commit/danbussoni/Fallback2Remove)

Fallback2Remove is a portable system utility designed to restore reliable “Safely Remove Hardware” functionality on Windows 11, specifically in scenarios where modern high-performance storage controllers (such as the Intel USB 3.20 eXtensible Host Controller) anchor external drives into the SCSI storage stack, breaking the native Windows ejection flow.

This tool is not a replacement for the Windows native removal system. It is a complementary fallback, intended for specific hardware behaviors where Windows fails to expose removable devices correctly.

---

## Core Purpose — A Complementary Solution and ROOT CAUSE

Fallback2Remove exists to handle edge cases introduced by modern storage architectures where Windows incorrectly classifies physically removable devices as fixed or internal.

ROOT CAUSE: Windows UPDATE (wuauserv) plus DEVICE VENDOR changed the "eXtensible Host Controller" driver within an AHCI NVMe capable machine that is intrinsically linked with the BIOS (could be RAID, SATA etc), resulting in no rollback scenario. Forcibly manipulating registry entries to enable device ejection can result in a BSOD (Inaccessible Boot Device), as Windows may lose access to critical system volumes or the paging file. In modern hardware, especially laptops, storage control is integrated into the BIOS/UEFI via firmware (such as Intel VMD) for certificate validation and security. Interfering with the bus taxonomy at the registry level can generate a state conflict between the firmware and the kernel, resulting in critical instability or boot failure.

The exact mechanism of the disaster: the convergence between a software update (Windows Update), a bus driver change (xHCI), and the firmware infrastructure (BIOS/RAID/VMD).

The xHCI Conflict: When changing the eXtensible host controller driver, Windows redefines how the bus reports the topology of connected devices. If the primary drive is encapsulated (mapped) by the controller, a failure to identify the "Parent Device" causes the disk to appear as removable. Or the reverse, an external drive recognized as internal.

The "No Rollback Scenario": When Windows Update replaces a critical bus driver on a machine with Intel VMD or RAID, it often overwrites the base binary and updates the PnP (Plug and Play) database. Attempting a manual rollback can leave the system without a boot driver, as the registry pointer points to a version that no longer communicates correctly with the BIOS memory mapping.

 State Fault (Firmware vs. Kernel): On laptops with Secure Boot and TPM enabled, the firmware expects the disk to be in a "Standardized" state. By forcing an ejection via the registry, you break the Chain of Trust. The Kernel attempts to "unmount" something that the Firmware says is "static," generating the inconsistency that triggers Bug Check 0x7B. With this technical basis, it's clear that the script is a security workaround, not a system modification. It acts at the user interface (UI) and diagnostic layer to prevent the user from making the fatal mistake of trying to eject their own system without touching the dangerous registry keys that would cause the aforementioned BSOD.

### The SCSI Anchoring Issue

On modern systems, many external drives are exposed under the SCSI bus, even when physically connected via USB.  
When this happens:

- The Windows 11 Safely Remove Hardware tray icon may disappear
- The Eject option may fail or never appear
- The operating system treats the drive as a fixed internal device
- No local removing policy works (Regardless of Windows Quick Removal or Performance Removal as observed in device manager)

This behavior is commonly observed with:

- NVMe USB enclosures
- USB-C docks
- High-performance external SSDs
- Intel vendor-specific USB controller logic

### Native USB Media Support

Traditional USB pen drives and older devices classified as Storage USB Media (USBSTOR) usually continue to work correctly with the native Windows removal flow and do not require this utility.

---

## How Fallback2Remove Works

Fallback2Remove identifies drives that are:

- Physically external
- Logically anchored inside the SCSI / Intel (or similar vendor) controller layer

Once detected, it provides a safe and direct path to the native Windows removal dialog, while guaranteeing that all pending I/O operations are completed beforehand.

---

## Logging and Heuristics (Debug Mode)

Fallback2Remove implements a transparent and auditable logging system.

When enabled, the utility generates the file:

Fallback2Remove.log

in the application directory.

### Logged Information

Hardware Traceability:
- DeviceID
- InterfaceType
- MediaType

Heuristic Classification:
- HOTPLUG_READY
- INTERNAL

The exact reason for each classification is recorded.

Safe Removal Audit Trail:
- Every Open Safe Removal action logs a manual FlushFileBuffers execution
- Confirms write cache clearance before the removal dialog appears

---

## Technical Notes and Safety

### Controller-Specific Behavior

Fallback2Remove was developed for systems where Intel USB 3.20 controllers (or similar vendor-specific logic) tether external drives into the system bus.

### Safe Buffer Flushing

The utility explicitly flushes file buffers to ensure all NAND or platter operations are complete before device removal.
The Windows ejection flow is logically independent of the Indexing Service; however, active indexing creates persistent file handles and pending I/O operations that prevent the OS from dismounting the volume, a conflict exacerbated by the controller's tendency to anchor the device to the SCSI bus.

### Native Implementation

- Uses hotplug.dll directly
- Can be executed in the startup with simple shortcut
- Keeps dynamic icon in tray and can be placed close to the native ejection icon (for better usability)
- Forces explicit buffer flushing
- Zero system persistence (portable)
- Avoids driver rollbacks or registry hacks

---

## Project Structure
```tree
Fallback2Remove/
├── Source/
│   ├── Fallback2Remove.ahk
│   ├── tray_idle.ico
│   └── tray_ready.ico
├── Scripts/
│   └── CreateStartupShortcut.ps1
│   └── CreateTaskSchedule.ps1
├── .gitignore
├── LICENSE
└── README.md
```
---

## Compilation and Portability

Fallback2Remove is a portable application.
It requires no installation and performs no registry modifications.

Build details:

- Compiler: Ahk2Exe
- AutoHotkey version: v1.1.37.02
- Architecture: 32-bit UTF-8

Icons are embedded directly into the executable using Ahk2Exe resource directives, allowing the binary to run as a single standalone file.

---

## Automation (Startup)

To automatically start Fallback2Remove with Windows:

1. Open PowerShell
2. Navigate to the Scripts directory
3. Place the .exe release in the same folder (assuming this is your portable installation folder or choose anyone)
4. Run:

./CreateStartupShortcut.ps1 or CreateTaskSchedule.ps1

This creates a startup shortcut/ taskschedule job without modifying system policies.

---

## Licensing and Credits

Source Code  
Copyright (c) Danilo Bussoni  
Licensed under the MIT License  
See the LICENSE file for details.

---

## Icons and Assets

This project uses icons from the Oxygen Icons 4.3.1 (KDE) collection.

Project: Oxygen Icon Library / Open Icon Library  
Link: http://www.oxygen-icons.org/  

License:  
Dual-licensed under:
- CC-BY-SA 3.0
- LGPL 2.1

All asset licenses are respected and compatible with this project.

---

## Intended Audience

- Power users
- Developers
- IT professionals
- Users affected by Windows 11 removable drive misclassification

---

## Disclaimer

Fallback2Remove does not bypass Windows safety mechanisms.
It strictly invokes native Windows APIs and ensures data integrity before removal.

Use at your own discretion.

---

## Final Notes

Modern hardware evolved faster than legacy operating system assumptions.
Fallback2Remove safely bridges that gap without hacks, persistence, or driver manipulation.

Contributions, audits, and feedback are welcome.

