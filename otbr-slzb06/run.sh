#!/usr/bin/with-contenv bashio

# 1. Extract configuration using bashio
# We write these directly to the S6 environment so background services see them
echo "$(bashio::config 'rcp_host')" > /var/run/s6/container-environment/RCP_HOST
echo "$(bashio::config 'rcp_port' '6638')" > /var/run/s6/container-environment/RCP_PORT
echo "$(bashio::config 'rcp_baudrate' '460800')" > /var/run/s6/container-environment/RCP_BAUDRATE
echo "1" > /var/run/s6/container-environment/RCP_USE_TCP

# 2. Map log levels to OTBR format
LOG_LEVEL=$(bashio::config 'log_level')
case "${LOG_LEVEL}" in
    debug)   echo "7" > /var/run/s6/container-environment/OTBR_LOG_LEVEL_INT ;;
    info)    echo "6" > /var/run/s6/container-environment/OTBR_LOG_LEVEL_INT ;;
    notice)  echo "5" > /var/run/s6/container-environment/OTBR_LOG_LEVEL_INT ;;
    warning) echo "4" > /var/run/s6/container-environment/OTBR_LOG_LEVEL_INT ;;
    error)   echo "3" > /var/run/s6/container-environment/OTBR_LOG_LEVEL_INT ;;
esac

# 3. Ensure Thread network state persists (FIXED SPACES HERE)
mkdir -p /data/thread
if [! -L /var/lib/thread ]; then
    bashio::log.info "Linking /var/lib/thread to persistent /data/thread"
    rm -rf /var/lib/thread
    ln -s /data/thread /var/lib/thread
fi

bashio::log.info "Configuration complete. S6 services will now start."
# No 'exec' needed here. S6 will start the otbr-agent and socat automatically.