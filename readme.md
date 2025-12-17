# Fallback2Remove
## Advanced Safely Remove Hardware Fallback Utility for Windows 11

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/License-MIT%202.0-blue.svg)
![GitHub stars](https://img.shields.io/github/stars/danbussoni/Fallback2Remove?style=social)
![GitHub forks](https://img.shields.io/github/forks/danbussoni/Fallback2Remove?style=social)
![GitHub issues](https://img.shields.io/github/issues/danbussoni/Fallback2Remove)
![GitHub last commit](https://img.shields.io/github/last-commit/danbussoni/Fallback2Remove)

Fallback2Remove is a portable system utility designed to restore reliable “Safely Remove Hardware” functionality on Windows 11, specifically in scenarios where modern high-performance storage controllers (such as the Intel USB 3.20 eXtensible Host Controller) anchor external drives into the SCSI storage stack, breaking the native Windows ejection flow.

This tool is not a replacement for the Windows native removal system. It is a complementary fallback, intended for specific hardware behaviors where Windows fails to expose removable devices correctly.

---

## Core Purpose — A Complementary Solution

Fallback2Remove exists to handle edge cases introduced by modern storage architectures where Windows incorrectly classifies physically removable devices as fixed or internal.

### The SCSI Anchoring Issue

On modern systems, many external drives are exposed under the SCSI bus, even when physically connected via USB.  
When this happens:

- The Windows 11 Safely Remove Hardware tray icon may disappear
- The Eject option may fail or never appear
- The operating system treats the drive as a fixed internal device

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
- Logically anchored inside the SCSI / Intel controller layer

Once detected, it provides a safe and direct path to the native Windows removal dialog, while guaranteeing that all pending I/O operations are completed beforehand.

### Design Principles

- Uses Windows native hotplug.dll
- Forces explicit buffer flushing
- Avoids driver rollbacks or registry hacks
- Zero system persistence (portable)

---

## Logging and Heuristics (Debug Mode)

Fallback2Remove implements a transparent and auditable logging system.

When enabled, the utility generates the file:

SafeRemovalTray.log

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

This logging is critical for diagnosing environments where Intel controller masking causes drives to appear non-removable.

---

## Technical Notes and Safety

### Controller-Specific Behavior

Fallback2Remove was developed for systems where Intel USB 3.20 controllers (or similar vendor-specific logic) tether external drives into the system bus.

### Safe Buffer Flushing

Regardless of Windows Quick Removal policies, the utility explicitly flushes file buffers to ensure all NAND or platter operations are complete before device removal.

### Native Implementation

- Uses hotplug.dll directly
- Avoids INACCESSIBLE_BOOT_DEVICE BSOD risks
- No driver manipulation or rollback required

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
3. Run:

./CreateStartupShortcut.ps1

This creates a startup shortcut without modifying system policies.

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

