#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
sleep 5
proot-distro login debian -- bash -c "pkill -9 -f 'cache-node' 2>/dev/null; pkill -9 -f uvicorn 2>/dev/null; pkill -9 -f sshd 2>/dev/null; fuser -k 6001/tcp 6002/tcp 6003/tcp 8000/tcp 22/tcp 2>/dev/null; supervisord -c /etc/supervisor/supervisord.conf; sleep infinity"
