# Next Steps & Server Management

## Daily Use

### SSH into server
```powershell
ssh -i C:\Users\hp\.ssh\pixel_server -p 22 root@192.168.68.115
```

### Start server after phone reboot
1. Open Termux on phone
2. Run: `proot-distro login debian`
3. Inside Debian: `dropbear -p 22 -F &`

## Auto-Start on Boot (Termux:Boot)

Install Termux:Boot from F-Droid, then:

```bash
# In Termux (NOT inside Debian):
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-server.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- /usr/sbin/dropbear -p 22 -R -F &
EOF
chmod +x ~/.termux/boot/start-server.sh
```

## Installing Software (inside Debian)

```bash
# Web server
apt install -y nginx
systemctl start nginx  # Note: use service nginx start in proot

# Node.js
apt install -y nodejs npm

# Python
apt install -y python3 python3-pip

# Database
apt install -y mariadb-server

# Docker (may have limitations in proot)
apt install -y docker.io
```

## Setting Up Cloudflare Tunnel (Internet Access)

Expose your server to the internet without port forwarding:

```bash
# Inside Debian, download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# Login to Cloudflare (opens browser link)
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create pixel-server

# Run tunnel (exposes port 80 publicly)
cloudflared tunnel run --url http://localhost:80 pixel-server
```

You get a `*.trycloudflare.com` URL or your own domain.

## Setting Up Nginx Web Server

```bash
apt install -y nginx
service nginx start

# Test
curl http://localhost
```

Edit site config:
```bash
nano /etc/nginx/sites-available/default
service nginx reload
```

## Recommended Self-Hosted Apps

| App | Use Case | RAM Usage |
|-----|----------|-----------|
| Nextcloud | Personal cloud storage | ~256MB |
| Vaultwarden | Password manager | ~50MB |
| Gitea | Private git hosting | ~100MB |
| Uptime Kuma | Service monitoring | ~50MB |
| Jellyfin | Media streaming | ~300MB+ |
| Home Assistant | Smart home hub | ~200MB |
| n8n | Workflow automation | ~150MB |

The Pixel 7a has 6GB RAM. Reserve ~2GB for Android/GrapheneOS, leaving ~4GB for server workloads.

## Keeping the Phone Running 24/7

- **Power:** Keep plugged in permanently. Use a USB-C cable + charger.
- **Battery protection:** Install a Magisk module to limit charge to 80% to preserve battery health.
- **Screen:** Enable developer option "Stay awake" or use a screen timeout app.
- **Heat:** Remove the phone case for better airflow. Mount vertically.
- **Battery optimization:** Go to Settings → Battery → disable optimization for Termux.

## Phone Details

- **Model:** Google Pixel 7a (lynx)
- **Chip:** Google Tensor G2
- **RAM:** 6GB
- **Storage:** 128GB
- **OS:** GrapheneOS 2026062800
- **SSH IP:** 192.168.68.115 (check if changed after router restart)
