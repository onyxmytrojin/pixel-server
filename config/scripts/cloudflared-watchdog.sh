#!/bin/bash
while true; do
    sleep 300
    if ! curl -sf --max-time 10 https://shubhanmehrotra.in > /dev/null 2>&1; then
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) site unreachable, restarting cloudflared" >> /var/log/watchdog.log
        supervisorctl restart cloudflared >> /var/log/watchdog.log 2>&1
    fi
done
