# Pixel 7a Self-Hosted Linux Server

> Turning a Google Pixel 7a into a full Debian Linux server using GrapheneOS, Magisk root, and proot-distro — accessible over WiFi or the internet via Cloudflare Tunnel.

![Platform](https://img.shields.io/badge/Device-Pixel%207a-blue)
![OS](https://img.shields.io/badge/OS-GrapheneOS-green)
![Linux](https://img.shields.io/badge/Linux-Debian%20(proot)-orange)
![SSH](https://img.shields.io/badge/SSH-Dropbear-lightgrey)
![Arch](https://img.shields.io/badge/Arch-ARM64-red)
![Live](https://img.shields.io/badge/Live-shubhanmehrotra.com-brightgreen)

---

## What This Is

Most old phones collect dust. This project repurposes a Pixel 7a into a 24/7 personal Linux server with:

- **Full Debian environment** — apt, bash, nginx, node, python, docker
- **SSH access** over WiFi (no USB required after setup)
- **Root access** via Magisk for deep system control
- **Public internet access** via Cloudflare Tunnel (no port forwarding, no static IP needed)
- **Privacy-first OS** — GrapheneOS replaces stock Android

The phone draws ~3–5W idle, runs silently, fits in your pocket, and costs nothing if you already own one.

---

## Architecture

```
┌─────────────────────────────────────────┐
│           Google Pixel 7a               │
│                                         │
│  GrapheneOS (Android base)              │
│  └── Magisk (root)                      │
│      └── Termux (terminal emulator)     │
│          └── proot-distro               │
│              └── Debian Linux           │
│                  ├── Dropbear (SSH :22) │
│                  ├── Nginx              │
│                  ├── Cloudflared        │
│                  └── Your apps...       │
└─────────────────────────────────────────┘
         │ WiFi                │ Cloudflare Tunnel
         ▼                     ▼
   Local network         Public internet
   192.168.x.x          shubhanmehrotra.com
```

---

## Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Base OS | [GrapheneOS](https://grapheneos.org) | Privacy-hardened Android |
| Root | [Magisk 30.7](https://github.com/topjohnwu/Magisk) | Systemless root via init_boot patch |
| Terminal | [Termux](https://termux.dev) | Android terminal + package manager |
| Linux | [proot-distro](https://github.com/termux/proot-distro) + Debian | Full Debian without loop mounts |
| SSH | [Dropbear](https://matt.ucc.asn.au/dropbear/dropbear.html) | Lightweight SSH server (proot-compatible) |
| Tunnel | [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) | Zero-config public access |

---

## Quick Start (SSH)

```powershell
# Connect over WiFi (no USB needed after setup)
ssh -i ~/.ssh/pixel_server -p 22 root@<phone-ip>
```

---

## Live

**[shubhanmehrotra.com](https://shubhanmehrotra.com)** — served from a Pixel 7a over Cloudflare Tunnel.

---

## Setup Guides

Full step-by-step documentation:

1. [Bootloader Unlock & GrapheneOS Install](./docs/01-grapheneos-setup.md)
2. [Magisk Root Setup](./docs/02-magisk-root.md)
3. [Debian Server via proot-distro](./docs/03-debian-server.md)
4. [SSH Key Authentication](./docs/04-ssh-setup.md)
5. [Cloudflare Tunnel & Custom Domain](./docs/07-cloudflare-tunnel.md)
6. [Next Steps & Services](./docs/06-next-steps.md)
7. [Troubleshooting Log](./docs/05-troubleshooting.md) — 12 real issues encountered and fixed

---

## Key Lessons Learned

- **init_boot, not boot** — Pixel 7a (Android 13+) requires patching `init_boot.img` for Magisk. Using `boot.img` silently fails with "Installed N/A".
- **proot over Linux Deploy** — GrapheneOS blocks loop-mounting ext4 images. proot-distro needs no loop mount and works reliably.
- **Dropbear over OpenSSH** — OpenSSH's privilege separation breaks inside proot. Dropbear has no such restriction.
- **UID ownership in proot** — Files created outside proot via `adb shell su` are owned by Android root (UID 0), not the proot user. Always create SSH keys from inside the proot session.
- **Hung fastboot processes** — A single background `fastboot.exe` holding the USB interface blocked all detection. Always kill hung fastboot processes before debugging drivers.

---

## Hardware

| Spec | Value |
|------|-------|
| Device | Google Pixel 7a (lynx) |
| SoC | Google Tensor G2 |
| RAM | 6 GB |
| Storage | 128 GB |
| Idle power draw | ~3–5W |

---

## Services You Can Run

| Service | Use Case | RAM |
|---------|----------|-----|
| Nginx | Web server / reverse proxy | ~20MB |
| Nextcloud | Personal cloud storage | ~256MB |
| Vaultwarden | Password manager | ~50MB |
| Gitea | Private git hosting | ~100MB |
| Uptime Kuma | Service monitoring dashboard | ~50MB |
| Jellyfin | Media streaming | ~300MB |
| n8n | Workflow automation | ~150MB |

See [compose/](./compose/) for ready-to-use docker-compose configs.

---

## Repo Structure

```
self_host/
├── README.md
├── docs/
│   ├── 01-grapheneos-setup.md
│   ├── 02-magisk-root.md
│   ├── 03-debian-server.md
│   ├── 04-ssh-setup.md
│   ├── 05-troubleshooting.md
│   ├── 06-next-steps.md
│   └── 07-cloudflare-tunnel.md
└── compose/
    ├── nginx/
    ├── vaultwarden/
    ├── gitea/
    └── uptime-kuma/
```

---

## License

MIT
