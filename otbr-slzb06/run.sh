#!/usr/bin/with-contenv bashio

# ==============================================================================
# OTBR TCP Add-on Startup Script
# ==============================================================================

bashio::log.info "Preparing OpenThread Border Router for TCP..."

# 1. Load Configuration
# ------------------------------------------------------------------------------
RCP_HOST=$(bashio::config 'rcp_host')
RCP_PORT=$(bashio::config 'rcp_port')
RCP_BAUDRATE=$(bashio::config 'rcp_baudrate')
BACKBONE_IF=$(bashio::config 'backbone_interface')
LOG_LEVEL=$(bashio::config 'log_level')

# Validation
if ! bashio::config.has_value 'rcp_host' || [[ -z "$RCP_HOST" ]]; then
    bashio::log.error "Config Error: 'rcp_host' is empty. Please provide the IP of your SLZB-06/Adapter."
    exit 1
fi

VIRTUAL_TTY="/dev/ttyRCP"
RADIO_URL="spinel+hdlc+uart://${VIRTUAL_TTY}?uart-baudrate=${RCP_BAUDRATE}"

# 2. Map Log Level
# ------------------------------------------------------------------------------
declare -A LOG_MAP=( [debug]=7 [info]=6 [notice]=5 [warning]=4 [error]=3 )
LOG_INT=${LOG_MAP[$LOG_LEVEL]:-6}

# 3. Create S6 Services
# ------------------------------------------------------------------------------
bashio::log.info "Registering supervised services..."

# Socat Service
mkdir -p /etc/services.d/socat
cat > /etc/services.d/socat/run <<EOF
#!/usr/bin/with-contenv bashio
exec socat -d -d pty,link=${VIRTUAL_TTY},raw,echo=0,waitslave tcp:${RCP_HOST}:${RCP_PORT},keepalive,keepidle=10,keepintvl=10,keepcnt=5
EOF

# OTBR Agent Service
mkdir -p /etc/services.d/otbr-agent
cat > /etc/services.d/otbr-agent/run <<EOF
#!/usr/bin/with-contenv bashio
# Wait for socat to create the TTY
while [ ! -e "${VIRTUAL_TTY}" ]; do sleep 1; done
exec otbr-agent -I wpan0 -B "${BACKBONE_IF}" -d "${LOG_INT}" "${RADIO_URL}"
EOF

chmod +x /etc/services.d/socat/run /etc/services.d/otbr-agent/run

# Ensure backbone interface exists/is up (simple check)
if ! ip link show "$BACKBONE_IF" > /dev/null 2>&1; then
    bashio::log.warning "Backbone interface '$BACKBONE_IF' not found! OTBR might fail."
fi

# 4. Persistence
# ------------------------------------------------------------------------------
bashio::log.info "Setting up persistent storage..."
mkdir -p /data/otbr
ln -sfn /data/otbr /var/lib/thread

bashio::log.info "Setup complete. S6 will now start services."
