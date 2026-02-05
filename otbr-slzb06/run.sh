#!/usr/bin/env bashio

# --- 1. Persistence ---
mkdir -p /data/otbr
ln -sfn /data/otbr /var/lib/thread

# --- 2. Load Config ---
RCP_HOST=$(bashio::config 'rcp_host')
RCP_PORT=$(bashio::config 'rcp_port')
RCP_BAUDRATE=$(bashio::config 'rcp_baudrate')
BACKBONE_IF=$(bashio::config 'backbone_interface')
LOG_LEVEL=$(bashio::config 'log_level')

if [[ -z "$RCP_HOST" ]]; then
    bashio::log.error "Config Error: 'rcp_host' is empty. Please provide the IP of your SLZB-06."
    exit 1
fi

# --- 3. Start TCP Bridge (Socat) ---
# We run this in the background to create the virtual TTY
VIRTUAL_TTY="/dev/ttyRCP"
bashio::log.info "Connecting to SLZB-06 at ${RCP_HOST}:${RCP_PORT}..."

socat pty,link=${VIRTUAL_TTY},raw,echo=0,waitslave \
    tcp:${RCP_HOST}:${RCP_PORT},keepalive,keepidle=10,keepintvl=10,keepcnt=5 &

# Wait for the virtual device to be ready
while [ ! -e "$VIRTUAL_TTY" ]; do sleep 0.5; done

# --- 4. Start OTBR Services ---
bashio::log.info "Starting OTBR Agent and Web UI..."

# Start the Web UI in the background (required for Ingress)
otbr-web -I wpan0 &

# Start the Agent in the foreground
# This is the main process of the container
RADIO_URL="spinel+hdlc+uart://${VIRTUAL_TTY}?uart-baudrate=${RCP_BAUDRATE}"

exec otbr-agent -I wpan0 -B "${BACKBONE_IF}" \
    -d "${LOG_LEVEL}" "${RADIO_URL}"
