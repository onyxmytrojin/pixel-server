# Step 1: Bootloader Unlock & GrapheneOS Installation

## Prerequisites

- Google Pixel 7a (codename: lynx)
- Windows PC with USB cable
- Android Platform Tools (ADB + fastboot)
- Google USB Driver

## Tools Setup

Download and extract platform tools to `self_host/platform-tools/`:
- Platform Tools: https://developer.android.com/tools/releases/platform-tools
- Google USB Driver: https://dl.google.com/android/repository/usb_driver_r13-windows.zip

## Phase 1: Enable Developer Options & OEM Unlocking

On the Pixel 7a:
```
Settings → About Phone → tap "Build Number" 7 times
Settings → Developer Options → OEM Unlocking → ON
Settings → Developer Options → USB Debugging → ON
```

## Phase 2: Connect Phone via ADB

```powershell
# Verify phone is detected
.\platform-tools\adb.exe devices
# Phone shows popup → tap "Allow"
# Should show: 38301JEHN11518   device
```

## Phase 3: Install USB Driver for Fastboot Mode

When phone is in fastboot mode, Windows needs a special driver.

1. Run: `adb.exe reboot bootloader`
2. Phone boots to fastboot screen
3. Open Device Manager → look for "Pixel 7a" under Other Devices
4. Right-click → Update Driver → Browse → point to `usb_driver/` folder
5. Installs "Android Bootloader Interface"

**Important:** If fastboot.exe still can't detect the phone:
- Download Zadig from https://zadig.akeo.ie/
- Options → List All Devices → select Pixel 7a (USB ID: 18D1:4EE0)
- Set driver to **WinUSB** → Replace Driver
- Kill any hung `fastboot.exe` processes: `Stop-Process -Name "fastboot" -Force`

## Phase 4: Unlock Bootloader

```powershell
# Reboot to fastboot
.\platform-tools\adb.exe reboot bootloader

# Verify connection
.\platform-tools\fastboot.exe devices
# Should show: 38301JEHN11518   fastboot

# Unlock (WIPES ALL DATA)
.\platform-tools\fastboot.exe flashing unlock
```

On phone: use Volume Down to select "Unlock the bootloader", press Power to confirm.

Verify:
```powershell
.\platform-tools\fastboot.exe getvar unlocked
# Should show: unlocked: yes
```

## Phase 5: Flash GrapheneOS

Download factory image (already in `lynx-install-2026062800/`):
- From: https://releases.grapheneos.org/lynx-install-2026062800.zip

```powershell
# Set PATH to include platform-tools
$env:PATH = "C:\Users\hp\Desktop\Projects\self_host\platform-tools;" + $env:PATH

# Navigate to image folder
cd C:\Users\hp\Desktop\Projects\self_host\lynx-install-2026062800

# Flash everything
.\flash-all.bat
```

The script flashes:
- Bootloader (both slots A and B)
- Radio/modem firmware
- AVB custom key (GrapheneOS verification)
- All 14 super partition images (OS itself)

Total time: ~5 minutes. Phone reboots automatically when done.

## Phase 6: Initial GrapheneOS Setup

1. Phone boots to GrapheneOS welcome screen
2. Tap "Continue without locking" (needed for Magisk)
3. Connect to WiFi
4. Skip Google account, fingerprint, PIN
5. Complete minimal setup

## Verification

```powershell
# After setup, re-enable USB debugging in Developer Options
.\platform-tools\adb.exe devices
# Should show device again
```

## Key Notes

- **The hung fastboot.exe bug:** A background `fastboot.exe` process holding the USB interface was the main cause of detection failures. Always check for hung fastboot processes with `Get-Process -Name fastboot` before troubleshooting drivers.
- **Slot system:** Pixel 7a uses A/B slots. The flash script manages this automatically.
- **GrapheneOS build:** `lynx-2026062800` for Pixel 7a (lynx)
