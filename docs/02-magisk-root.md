# Step 2: Magisk Root Setup

## Why Root?

Root access via Magisk is needed to run Linux Deploy and other server tools that require deeper system access.

## Important: Pixel 7a Uses init_boot, Not boot

On Pixel 7a (Android 13+), Magisk must patch **`init_boot.img`**, NOT `boot.img`. This is because Android 13+ moved the generic ramdisk to `init_boot`. Patching the wrong image results in Magisk showing "Installed N/A" with no root access.

## Phase 1: Install Magisk App

```powershell
# Download Magisk APK from GitHub releases
# Push to phone
.\platform-tools\adb.exe install Magisk.apk
```

Or download directly on the phone from:
https://github.com/topjohnwu/Magisk/releases/latest

## Phase 2: Patch init_boot.img

Push the correct image to the phone:
```powershell
.\platform-tools\adb.exe push lynx-install-2026062800\init_boot.img /sdcard/Download/init_boot.img
```

On the phone in Magisk:
1. Tap **Install** next to "Magisk"
2. Tap **Select and Patch a File**
3. Navigate to Downloads → select `init_boot.img`
4. Tap **LET'S GO**
5. Wait for "All Done"

## Phase 3: Pull Patched Image

```powershell
# Find the patched file
.\platform-tools\adb.exe shell ls /sdcard/Download/magisk_patched*.img

# Pull it back to PC
.\platform-tools\adb.exe pull /sdcard/Download/magisk_patched-30700_OrNbc.img magisk_patched_init_boot.img
```

## Phase 4: Flash to Correct Slot

**Critical:** The Pixel 7a uses A/B slots. You must flash to the ACTIVE slot.

```powershell
# Check which slot is active
.\platform-tools\adb.exe shell getprop ro.boot.slot_suffix
# Returns: _a or _b

# Reboot to fastboot
.\platform-tools\adb.exe reboot bootloader

# Flash to the ACTIVE slot (both in our case)
.\platform-tools\fastboot.exe flash init_boot_a magisk_patched_init_boot.img
.\platform-tools\fastboot.exe flash init_boot_b magisk_patched_init_boot.img

# Reboot
.\platform-tools\fastboot.exe reboot
```

## Phase 5: Verify Root

```powershell
# Open Magisk app → should show version number (not N/A)
# Go to Settings → Superuser Access → set to "Apps and ADB"

# Test via ADB
.\platform-tools\adb.exe shell "su -c 'id'"
# Approve Magisk popup on phone
# Should return: uid=0(root) gid=0(root)
```

Or test in Termux:
```bash
su
id
# uid=0(root) gid=0(root) groups=0(root) context=u:r:magisk:s0
```

## Troubleshooting

**Magisk shows "Installed N/A":**
- You patched `boot.img` instead of `init_boot.img`
- Redo from Phase 2 using `init_boot.img`

**Wrong slot:**
- Run `adb shell getprop ro.boot.slot_suffix` to check active slot
- Flash patched init_boot to that specific slot (e.g., `flash init_boot_b`)

**Root not working after granting:**
- Reboot the phone
- Check Magisk Settings → Superuser Access is set to "Apps and ADB"

## Magisk Info

- Version: 30.7
- Mode: init_boot patch
- Active slot at time of setup: _b
