#!/usr/bin/with-contenv bashio

# Extract configuration using bashio
export RCP_HOST=$(bashio::config 'rcp_host')
export RCP_PORT=$(bashio::config 'rcp_port' '6638')
export RCP_BAUDRATE=$(bashio::config 'rcp_baudrate' '460800')
export RCP_USE_TCP=1

# Map log levels to OTBR format
LOG_LEVEL=$(bashio::config 'log_level')
case "${LOG_LEVEL}" in
    debug)   export OTBR_LOG_LEVEL_INT=7 ;;
    info)    export OTBR_LOG_LEVEL_INT=6 ;;
    notice)  export OTBR_LOG_LEVEL_INT=5 ;;
    warning) export OTBR_LOG_LEVEL_INT=4 ;;
    error)   export OTBR_LOG_LEVEL_INT=3 ;;
esac

# Ensure Thread network state persists in the /data volume
mkdir -p /data/thread
if [! -L /var/lib/thread ]; then
    rm -rf /var/lib/thread
    ln -s /data/thread /var/lib/thread
fi

bashio::log.info "Starting bridge to remote RCP at ${RCP_HOST}:${RCP_PORT}"

# Execute the original image entrypoint
exec /app/entrypoint.sh