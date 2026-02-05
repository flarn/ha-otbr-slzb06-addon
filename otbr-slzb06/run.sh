#!/bin/bash

# --- HARDCODED VALUES ---
RCP_HOST="192.168.1.50"   # <--- PUT YOUR SLZB-06 IP HERE
RCP_PORT="6638"
RCP_BAUDRATE="460800"
BACKBONE_IF="eth0"
LOG_LEVEL="6"             # 6 = info, 7 = debug
# ------------------------

echo "Starting OTBR TCP Bridge for SLZB-06..."

VIRTUAL_TTY="/dev/ttyRCP"
RADIO_URL="spinel+hdlc+uart://${VIRTUAL_TTY}?uart-baudrate=${RCP_BAUDRATE}"

# 1. Persistence
mkdir -p /data/otbr
ln -sfn /data/otbr /var/lib/thread

# 2. Start Socat in the background
echo "Connecting to ${RCP_HOST}:${RCP_PORT}..."
socat pty,link=${VIRTUAL_TTY},raw,echo=0,waitslave tcp:${RCP_HOST}:${RCP_PORT},keepalive,keepidle=10,keepintvl=10,keepcnt=5 &

# 3. Wait for TTY to be ready
sleep 2

# 4. Start OTBR Agent (Foreground)
echo "Starting OTBR Agent..."
exec otbr-agent -I wpan0 -B "${BACKBONE_IF}" -d "${LOG_LEVEL}" "${RADIO_URL}"
