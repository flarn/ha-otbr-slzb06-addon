ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies if they aren't in your base image
# (socat is usually needed for TCP-to-Serial bridging in OTBR)
RUN apt-get update && apt-get install -y socat && apt-get clean

# Copy the script to the S6 initialization folder
COPY run.sh /etc/cont-init.d/01-otbr-config
RUN chmod a+x /etc/cont-init.d/01-otbr-config

# Ensure the persistent data directory exists
RUN mkdir -p /data/thread

# Labels for Home Assistant
LABEL \
    io.hass.name="OTBR TCP" \
    io.hass.description="OpenThread Border Router for network-attached (TCP) serial bridges" \
    io.hass.type="addon" \
    io.hass.version="1.0.3"