Fallback2Remove for Windows 11
Advanced Safely Remove Hardware Fallback Utility
Fallback2Remove is a portable system utility designed to restore reliable "Safely Remove Hardware" functionality on Windows 11 systems. It specifically addresses scenarios where high-performance storage controllers (such as the Intel USB 3.20 eXtensible Host Controller) anchor external drives into the SCSI storage stack, often breaking the native ejection flow.

The Core Purpose: A Complementary Solution
This tool is not a replacement for the Windows native removal system, but rather a complementary fallback for specific hardware behaviors:

The SCSI Anchoring Issue: On modern architectures, external drives are often managed under the SCSI bus rather than a simple USBSTOR flow. In this scenario, the native Windows 11 "Eject" icon may disappear or fail because the system perceives the drive as a fixed component of the storage controller.

Native USB Media Support: Older devices or standard Pen Drives tend to be classified as "Storage USB Media." For these devices, the native Windows 11 "Safely Remove Hardware" typically continues to function correctly.

The Logic: Fallback2Remove identifies drives that have been "trapped" in the SCSI/Intel controller layer. It provides a direct path to the native hotplug.dll while ensuring data integrity.

Logging & Heuristics (Debug Mode)
One of the key features of this utility is its transparent logging system. It generates a SafeRemovalTray.log file in the application directory, providing a full audit of how the system perceives your hardware:

Hardware Traceability: It logs every disk's DeviceID, InterfaceType, and MediaType.

Heuristic Validation: It records exactly why a device was classified as HOTPLUG_READY or INTERNAL.

Audit Trail: Every time the "Open Safe Removal" action is triggered, it logs the manual FlushFileBuffers execution, confirming that the write cache was cleared before the dialog appeared.

This logging is vital for troubleshooting environments where the Intel controller masking makes drives appear non-removable to the OS.

Technical Troubleshooting
Controller Specifics: Developed for systems where the Intel 3.20 Controller (or similar vendor-specific logic) creates a tether between the external drive and the system bus.

Safe Buffer Flushing: Regardless of Windows "Quick Removal" policies, this utility implements a manual FlushFileBuffers call to ensure all NAND/Platter operations are complete before the removal dialog is shown.

Native Implementation: The utility utilizes the system's own hotplug.dll, avoiding the "Inaccessible Boot Device" BSOD risks associated with manual driver rollbacks.

Fallback2Remove/
├── Source/
│   ├── SafeRemovalTray.ahk    # Main source code (AutoHotkey v1.1.37.02)
│   ├── tray_idle.ico          # Resource Asset (Embedded during compile)
│   └── tray_ready.ico         # Resource Asset (Embedded during compile)
├── Scripts/
│   └── CreateStartupShortcut.ps1 # Automation for Windows Startup
├── .gitignore
├── LICENSE
└── README.md

Compilation & Portability
This is a Portable application. It does not require installation or registry modifications.

Compiler: Ahk2Exe (AutoHotkey v1.1.37.02)

Architecture: 32-bit UTF-8

Resources: Icons are embedded within the .exe using ;@Ahk2Exe-AddResource directives, allowing the binary to run as a single standalone file.

Automation
To have the utility start automatically with Windows, run the provided PowerShell script in the Scripts/ folder:
./CreateStartupShortcut.ps1

Credits & Licensing - Danilo Bussoni
Source Code
The source code is licensed under the MIT License.

Assets (Icons)
This project uses icons from the Oxygen Icons 4.3.1 (KDE) collection.

Link: http://www.oxygen-icons.org/

License: Dual-licensed under CC-BY-SA 3.0 or LGPL 2.1.

Origin: Oxygen Icon Library / Open Icon Library.
