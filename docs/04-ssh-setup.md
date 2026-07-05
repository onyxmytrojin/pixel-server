# Step 4: SSH Configuration

## Overview

SSH access to the Pixel 7a server uses **key-based authentication** with **Dropbear** as the SSH server. Password authentication alone didn't work due to TTY limitations in the proot environment.

## SSH Key Generation (on PC)

```bash
# Generate ED25519 key pair
ssh-keygen -t ed25519 -f ~/.ssh/pixel_server -N ""

# Key files created:
# ~/.ssh/pixel_server      (private key - keep secret)
# ~/.ssh/pixel_server.pub  (public key - goes on server)
```

Public key (yours will differ):
```
ssh-ed25519 AAAA...your-key-here... user@hostname
```

## Adding Key to Server

The authorized_keys file must be created FROM INSIDE the proot environment to have correct ownership. Creating it from outside (via ADB + su) causes a UID mismatch.

Inside the Debian proot session:
```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "YOUR_PUBLIC_KEY_HERE" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```

## Starting SSH Server

Inside Debian proot:
```bash
# Start Dropbear in background
dropbear -p 22 -F &
```

Dropbear flags:
- `-p 22` — listen on port 22
- `-F` — don't fork to background (required with `&` for job control)

## Connecting from PC

### Over WiFi (recommended, no USB needed)
```powershell
ssh -i C:\Users\hp\.ssh\pixel_server -p 22 root@192.168.68.115
```

### Over USB via ADB port forwarding
```powershell
adb forward tcp:2222 tcp:22
ssh -i C:\Users\hp\.ssh\pixel_server -p 2222 root@127.0.0.1
```

## Phone Network Details

- **WiFi IP:** `192.168.68.115` (may change — check Settings → About → Status)
- **SSH Port:** 22
- **User:** root
- **Auth:** Key-based (private key at `C:\Users\hp\.ssh\pixel_server`)

## Troubleshooting SSH

**"Connection refused":**
- Dropbear isn't running
- Start it: `dropbear -p 22 -F &` inside Debian proot

**"Connection closed by remote host" during key exchange:**
- SSH host keys not generated
- Fix: `ssh-keygen -A` inside Debian proot

**"Permission denied (publickey,password)":**
- authorized_keys file has wrong ownership (created by Android root, not proot user)
- Fix: Delete and recreate from inside proot session

**"sshd requires execution with an absolute path":**
- OpenSSH sshd doesn't work in proot environments
- Fix: Use Dropbear instead (`apt install dropbear`)

**TTY/password issues:**
- When SSH client can't open /dev/tty, password prompts fail silently
- Fix: Use key-based authentication instead

## Why Dropbear Instead of OpenSSH?

OpenSSH's `sshd` performs privilege separation which requires re-executing itself with a verified absolute path. proot intercepts exec calls in a way that breaks this check, causing the error:
```
sshd: requires execution with an absolute path
```

Dropbear is a lightweight SSH server that doesn't use privilege separation and works fine in proot environments.
