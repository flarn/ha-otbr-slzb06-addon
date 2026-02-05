#!/usr/bin/with-contenv bashio

# 1. Extract and validate configuration
if ! bashio::config.has_value 'rcp_host'; then
    bashio::log.error "Configuration Error: 'rcp_host' is missing! Please enter the IP address of your serial bridge."
    exit 1
fi

RCP_HOST=$(bashio::config 'rcp_host')
RCP_PORT=$(bashio::config 'rcp_port' '6638')
RCP_BAUDRATE=$(bashio::config 'rcp_baudrate' '460800')
LOG_LEVEL=$(bashio::config 'log_level' 'info')

# 2. Map log levels to OTBR format
case "${LOG_LEVEL}" in
    debug)  OTBR_INT="7" ;;
    info)   OTBR_INT="6" ;;
    notice) OTBR_INT="5" ;;
    warning) OTBR_INT="4" ;;
    error)  OTBR_INT="3" ;;
    *)      OTBR_INT="6" ;;
esac

# 3. Export variables so the S6 services see them
# Using bashio::var.export is the standard way for HA Add-ons
bashio::var.export "RCP_HOST" "$RCP_HOST"
bashio::var.export "RCP_PORT" "$RCP_PORT"
bashio::var.export "RCP_BAUDRATE" "$RCP_BAUDRATE"
bashio::var.export "RCP_USE_TCP" "1"
bashio::var.export "OTBR_LOG_LEVEL_INT" "$OTBR_INT"

# 4. Ensure Thread network state persists
mkdir -p /data/thread
# FIXED: Added spaces around the brackets and the !
if [ ! -L /var/lib/thread ]; then
    bashio::log.info "Linking /var/lib/thread to persistent /data/thread"
    # Ensure the target exists and link it
    rm -rf /var/lib/thread
    ln -s /data/thread /var/lib/thread
fi

bashio::log.info "Configuration complete. Starting OTBR for $RCP_HOST:$RCP_PORT"