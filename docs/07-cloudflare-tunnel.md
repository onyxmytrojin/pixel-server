# Step 5: Cloudflare Tunnel & Custom Domain

## What This Does

Cloudflare Tunnel creates a secure outbound connection from your phone to Cloudflare's global network. Your server becomes publicly accessible at your own domain with:

- No port forwarding on your router
- No exposing your home IP address
- Free SSL/HTTPS automatically
- DDoS protection via Cloudflare
- Works even if your ISP blocks inbound connections

## Prerequisites

- Cloudflare account (free)
- A domain name (purchased from any registrar)
- `cloudflared` binary installed on the phone
- Nginx running on port 80

## Phase 1: Install cloudflared on Phone

Inside Debian proot (via SSH):

```bash
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared
cloudflared --version
# cloudflared version 2026.6.1
```

## Phase 2: Point Domain to Cloudflare

**On BigRock (or your registrar):**
1. Login → My Domains → your domain → Name Servers
2. Replace all existing nameservers with Cloudflare's:
   - `george.ns.cloudflare.com`
   - `keyla.ns.cloudflare.com`
3. Save

**On Cloudflare:**
1. Add site → Connect a domain → enter your domain → Free plan
2. Continue through setup → "I updated my nameservers"
3. Wait 5–30 mins for propagation

## Phase 3: Create Named Tunnel

1. Cloudflare dashboard → Networking → Tunnels → Create a tunnel
2. Select **Cloudflared**
3. Name: `pixel-server`
4. Select **Debian / arm64** for OS/architecture
5. Copy the tunnel token shown on screen

Run on the phone (via SSH from PC):

```bash
# Kill any existing cloudflared
pkill cloudflared

# Start named tunnel with token
nohup cloudflared tunnel --no-autoupdate run --token YOUR_TUNNEL_TOKEN > /tmp/cloudflared.log 2>&1 &

# Verify connections
cat /tmp/cloudflared.log | tr -cd '[:print:]\n' | grep 'Registered'
# Should show 4 connections to bom/blr edge nodes
```

6. Cloudflare page shows **"Tunnel connected successfully"** → click Continue

## Phase 4: Add Public Hostname

In the tunnel overview → **+ Add route** → **Published application**:

| Field | Value |
|-------|-------|
| Subdomain | *(leave blank)* |
| Domain | `shubhanmehrotra.com` |
| Path | *(leave blank)* |
| Service URL | `http://localhost:80` |

Click **Add route**.

## Phase 5: Fix DNS Records

After adding the route, go to **DNS → Records**:

- Delete any old A records pointing to `127.0.0.1`
- Cloudflare automatically creates a **Tunnel** type record pointing to `pixel-server`
- Proxy status should be **Proxied** (orange cloud)

## Phase 6: Verify

```bash
curl -s -o /dev/null -w "%{http_code}" https://shubhanmehrotra.com
# 200
```

Site is live at `https://shubhanmehrotra.com`.

## Tunnel Details

| Property | Value |
|----------|-------|
| Tunnel name | pixel-server |
| Tunnel ID | 5e18c8cb-6575-4695-a61a-dd36c3b654c2 |
| Domain | shubhanmehrotra.com |
| Origin | http://localhost:80 |
| Edge locations | bom09, blr03, bom12 (Mumbai/Bangalore) |
| Architecture | linux_arm64 |

## Auto-Start on Boot

Add to Termux:Boot script so tunnel restarts automatically:

```bash
# ~/.termux/boot/start-server.sh
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- bash -c "
  service nginx start
  nohup cloudflared tunnel --no-autoupdate run --token YOUR_TUNNEL_TOKEN > /tmp/cloudflared.log 2>&1 &
  dropbear -p 22 -F &
"
```

## Troubleshooting

**Tunnel connects but site returns 502:**
- Nginx isn't running inside proot
- Fix: `service nginx start` inside Debian

**"broken pipe" on first run:**
- Network hiccup on the phone
- Fix: kill and restart cloudflared, it usually connects on retry

**DNS still shows old IP after changing nameservers:**
- Propagation takes up to 48hrs (usually 5–30 mins)
- Test with: `nslookup yourdomain.com george.ns.cloudflare.com`

**Tunnel token:**
- Stored in `.env` file locally
- Never commit to git
- If compromised: Rotate token in Cloudflare dashboard → Tunnel → Refresh token
