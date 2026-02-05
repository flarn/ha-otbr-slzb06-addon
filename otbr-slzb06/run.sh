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

# 2. Configure 'socat' Service (TCP Bridge)
# ------------------------------------------------------------------------------
# We create a new S6 service definition dynamically.
# This ensures socat is supervised (restarted if it crashes).

SOCAT_SERVICE_DIR="/etc/s6/socat"
# Check if legacy services.d exists (S6 v2 vs v3)
if [ -d "/etc/services.d" ]; then
    SOCAT_SERVICE_DIR="/etc/services.d/socat"
fi

mkdir -p "$SOCAT_SERVICE_DIR"

# The TTY we will simulate
VIRTUAL_TTY="/dev/ttyRCP"

# Create the run script for socat
cat > "$SOCAT_SERVICE_DIR/run" <<EOF
#!/usr/bin/with-contenv bashio
# Socat TCP Bridge Service
bashio::log.info "Starting socat bridge: ${RCP_HOST}:${RCP_PORT} -> ${VIRTUAL_TTY}"
exec socat -d -d pty,link=${VIRTUAL_TTY},raw,echo=0,waitslave tcp:${RCP_HOST}:${RCP_PORT},keepalive,keepidle=10,keepintvl=10,keepcnt=5
EOF

chmod +x "$SOCAT_SERVICE_DIR/run"
bashio::log.info "Registered 'socat' service."

# 3. Configure OTBR Agent
# ------------------------------------------------------------------------------
# The official otbr image uses /etc/default/otbr-agent to set OTBR_AGENT_OPTS.
# We override this to point to our virtual TTY.

# Map log level string to integer
case "${LOG_LEVEL}" in
    debug)   LOG_INT="7" ;;
    info)    LOG_INT="6" ;;
    notice)  LOG_INT="5" ;;
    warning) LOG_INT="4" ;;
    error)   LOG_INT="3" ;;
    crit)    LOG_INT="2" ;;
    alert)   LOG_INT="1" ;;
    emerg)   LOG_INT="0" ;;
    *)       LOG_INT="6" ;;
esac

# Construct the radio URL
# spinel+hdlc+uart:///dev/ttyRCP?uart-baudrate=460800
RADIO_URL="spinel+hdlc+uart://${VIRTUAL_TTY}?uart-baudrate=${RCP_BAUDRATE}"

bashio::log.info "Configuring OTBR Agent..."
bashio::log.info "  - Radio URL: ${RADIO_URL}"
bashio::log.info "  - Interface: ${BACKBONE_IF}"
bashio::log.info "  - Log Level: ${LOG_LEVEL} (${LOG_INT})"

# Write configuration
# Note: We include -B to specify backbone interface, and -d for log level
echo "OTBR_AGENT_OPTS=\"-I wpan0 -B ${BACKBONE_IF} -d ${LOG_INT} ${RADIO_URL}\"" > /etc/default/otbr-agent

# Ensure backbone interface exists/is up (simple check)
if ! ip link show "$BACKBONE_IF" > /dev/null 2>&1; then
    bashio::log.warning "Backbone interface '$BACKBONE_IF' not found! OTBR might fail."
fi

# 4. Persistence Setup
# ------------------------------------------------------------------------------
# Ensure /var/lib/thread maps to /data so datasets survive restarts.
if [ ! -L /var/lib/thread ]; then
    bashio::log.info "Setting up persistent storage..."
    mkdir -p /data/thread
    rm -rf /var/lib/thread # Remove default directory
    ln -s /data/thread /var/lib/thread
fi

# 5. Handover to Init
# ------------------------------------------------------------------------------
bashio::log.info "Setup complete. Handing over to S6 init..."
exec /init
