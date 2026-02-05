# We use the specific image you want as the base
FROM bnutzer/otbr-tcp:latest

# Home Assistant Add-ons require bashio and s6-overlay to function
# Since bnutzer/otbr-tcp is a standard Debian/Ubuntu image, 
# we must ensure the environment matches what your run.sh expects.

# 1. Install bashio (Required for your run.sh to work)
RUN apt-get update && apt-get install -y curl jq \
    && curl -J -L -o /tmp/bashio.tar.gz "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# 2. Copy your fixed configuration script
COPY run.sh /etc/cont-init.d/01-otbr-config
RUN chmod a+x /etc/cont-init.d/01-otbr-config

# Labels for Home Assistant
LABEL \
    io.hass.name="OTBR TCP" \
    io.hass.description="OpenThread Border Router for network-attached (TCP) serial bridges" \
    io.hass.type="addon" \
    io.hass.version="1.0.3"