# Step 3: Debian Server Setup

## Approach: proot-distro in Termux

We use **Termux + proot-distro** to run Debian. This is more reliable on GrapheneOS than Linux Deploy because:
- No loop-mounting of disk images (avoids GrapheneOS restrictions)
- No kernel-level chroot needed
- Works without modifying system partitions
- Actively maintained and compatible with modern Android

**Linux Deploy** was attempted but had persistent issues:
- Loop-mounting ext4 images failed on GrapheneOS
- SSH host keys weren't generated
- Architecture set to armhf by default (should be arm64)

## Phase 1: Install Termux

Install from F-Droid (NOT Play Store — Play Store version is outdated):

```powershell
# Download F-Droid
Invoke-WebRequest -Uri "https://f-droid.org/F-Droid.apk" -OutFile "fdroid.apk"
.\platform-tools\adb.exe install fdroid.apk
```

Open F-Droid on phone → search "Termux" → install.

Or download Termux APK directly from F-Droid:
https://f-droid.org/en/packages/com.termux/

**Note:** Do NOT install from Play Store. The Play Store version is frozen and doesn't receive updates.

## Phase 2: Initialize Termux

Open Termux on the phone. It will automatically download and install the bootstrap (~50MB). Wait for the `$` prompt.

```bash
# Update package lists
pkg update

# Upgrade all packages (73 packages updated in our setup)
pkg upgrade
```

## Phase 3: Install proot-distro

```bash
pkg install proot-distro
```

## Phase 4: Install Debian

```bash
proot-distro install debian
```

Downloads Debian stable rootfs (~200MB). Takes a few minutes.

## Phase 5: Enter Debian

```bash
proot-distro login debian
# Prompt changes to: root@localhost:~#
```

## Phase 6: Set Up Debian

Inside the Debian proot session:

```bash
# Update package lists and upgrade
apt update && apt upgrade -y

# Install essentials
apt install -y openssh-server curl wget git nano dropbear passwd

# Set root password
passwd root
# Enter a strong password when prompted
```

## Phase 7: Configure SSH

```bash
# Allow root login and password auth in SSH config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Create SSH directory
mkdir -p /root/.ssh
chmod 700 /root/.ssh
```

**Note:** OpenSSH sshd doesn't work in proot due to privilege separation restrictions. Use **Dropbear** instead:

```bash
# Start Dropbear SSH server
dropbear -p 22 -F &
# Returns a PID number — server is running
```

## Debian Rootfs Location

The Debian filesystem lives at:
```
/data/data/com.termux/files/usr/var/lib/proot-distro/containers/debian/rootfs/
```

## Making It Persistent

To keep Debian running after closing Termux, add to Termux startup:

```bash
# In Termux (not inside Debian):
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-debian.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- /usr/sbin/dropbear -p 22 -F &
EOF
chmod +x ~/.termux/boot/start-debian.sh
```

Also install Termux:Boot from F-Droid.

## System Info

```
Kernel: 6.17.0-PRoot-Distro
Architecture: aarch64 (ARM64)
Distribution: Debian GNU/Linux (stable)
Init: proot (no systemd)
SSH: Dropbear on port 22
```
