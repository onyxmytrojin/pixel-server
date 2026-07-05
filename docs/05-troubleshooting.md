# Troubleshooting Log

Real issues encountered and how they were fixed during setup.

---

## Issue 1: fastboot.exe Not Detecting Phone

**Symptom:** `fastboot devices` returns empty even though phone is on fastboot screen and Device Manager shows "Android Bootloader Interface".

**Root Cause:** A previous `fastboot.exe` process was still running in the background, holding the USB interface and blocking new connections.

**Fix:**
```powershell
# Check for hung fastboot processes
Get-Process -Name "fastboot" -ErrorAction SilentlyContinue

# Kill them
Stop-Process -Name "fastboot" -Force -ErrorAction SilentlyContinue

# In admin cmd if needed
taskkill /F /PID <pid>
```

**Secondary fix:** Install WinUSB driver via Zadig (https://zadig.akeo.ie/):
- Options → List All Devices
- Select Pixel 7a (USB ID: 18D1:4EE0)
- Set driver to WinUSB → Replace Driver

---

## Issue 2: Web Installer Progress Bar Stuck

**Symptom:** GrapheneOS web installer downloads the zip but progress bar stops partway.

**Cause:** Browser extracting 1.5GB zip in memory is very slow or runs out of memory.

**Fix:** Download factory images directly and flash manually:
```powershell
# Download
Invoke-WebRequest -Uri "https://releases.grapheneos.org/lynx-install-2026062800.zip" -OutFile "lynx.zip"

# Extract and run flash-all.bat from admin cmd
```

---

## Issue 3: Web Installer "claimInterface" Error

**Symptom:** `Error: Failed to execute 'claimInterface' on 'USBDevice': Unable to claim interface`

**Cause:** A hung `fastboot.exe` process was holding the WinUSB interface, preventing the browser's WebUSB from claiming it.

**Fix:** Kill all fastboot.exe processes (see Issue 1), then retry.

---

## Issue 4: Web Installer "Key already exists in the object store"

**Symptom:** Web installer throws IndexedDB error on Download.

**Fix:** Clear site data for grapheneos.org:
- F12 → Application tab → Storage → Clear site data
- Or use InPrivate/Incognito window for fresh storage

---

## Issue 5: Magisk Shows "Installed N/A"

**Symptom:** Magisk app shows Magisk as installed but version is N/A and root doesn't work.

**Cause:** `boot.img` was patched instead of `init_boot.img`. On Pixel 7a (Android 13+), Magisk must patch `init_boot.img`.

**Fix:** Redo patching with `init_boot.img`:
```powershell
adb push lynx-install-2026062800\init_boot.img /sdcard/Download/init_boot.img
# Patch in Magisk app → Select init_boot.img
adb pull /sdcard/Download/magisk_patched-*.img magisk_patched_init_boot.img
fastboot flash init_boot_a magisk_patched_init_boot.img
fastboot flash init_boot_b magisk_patched_init_boot.img
```

---

## Issue 6: Root Flashed to Wrong Slot

**Symptom:** Magisk installed but `su` returns "Permission denied". Magisk shows installed but root doesn't work.

**Cause:** Patched init_boot flashed to slot A but phone is running slot B (or vice versa).

**Fix:**
```powershell
# Check active slot
adb shell getprop ro.boot.slot_suffix
# Returns _a or _b

# Flash to both slots to be safe
fastboot flash init_boot_a magisk_patched_init_boot.img
fastboot flash init_boot_b magisk_patched_init_boot.img
```

---

## Issue 7: Linux Deploy SSH "Connection closed by remote host"

**Symptom:** SSH connects at TCP level but immediately closes during key exchange.

**Cause:** SSH host keys were not generated during Linux Deploy installation (the "fail" messages during install indicated SSH setup failed).

**Fix:** Switch from Linux Deploy to proot-distro in Termux (more reliable on GrapheneOS).

---

## Issue 8: Linux Deploy Loop Mount Failing

**Symptom:** Linux Deploy shows "/ ... fail" when starting.

**Cause:** GrapheneOS restricts loop-mounting ext4 image files from external storage (/sdcard).

**Attempted Fix:** Changed TARGET_PATH to /data/local/linux and TARGET_TYPE to directory.

**Final Fix:** Abandoned Linux Deploy entirely. Used proot-distro in Termux instead which doesn't need loop mounting.

---

## Issue 9: OpenSSH sshd Fails in proot

**Symptom:** `/usr/sbin/sshd` gives "sshd requires execution with an absolute path"

**Cause:** proot intercepts exec() calls in a way that breaks OpenSSH's privilege separation check, even when called with an absolute path.

**Fix:** Use Dropbear SSH server instead:
```bash
apt install dropbear
dropbear -p 22 -F &
```

---

## Issue 10: SSH authorized_keys Permission Denied

**Symptom:** Writing to `/root/.ssh/authorized_keys` gives "Permission denied" from inside proot.

**Cause:** File was created from outside proot using `adb shell su`, giving it Android root (UID 0) ownership. Inside proot, the root user maps to the Termux app UID (u0_a199), which can't write to Android root-owned files.

**Fix:** Delete the file from outside, then create it from inside the proot session:
```bash
# From inside proot-distro login debian:
echo "YOUR_PUBLIC_KEY" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```

---

## Issue 11: Termux pkg Command Not Found

**Symptom:** Opening Termux and running `pkg` gives "inaccessible or not found".

**Cause:** Installed Termux debug APK which doesn't include the bootstrap. Also signature mismatch prevented upgrading to F-Droid version.

**Fix:**
```powershell
# Uninstall debug version
adb uninstall com.termux

# Install from F-Droid
adb install fdroid.apk
# Then install Termux from within F-Droid
```

---

## Issue 12: USB Driver Lost After Reboot

**Symptom:** After PC restart, fastboot doesn't detect phone again.

**Cause:** Windows sometimes loses USB device driver state.

**Fix:** Unplug/replug USB while on fastboot screen, or reinstall WinUSB via Zadig.
