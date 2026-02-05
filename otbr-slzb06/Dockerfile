ARG BUILD_FROM=openthread/otbr:latest
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG BUILD_VERSION

# 1. Install Dependencies (Bashio + Socat for TCP bridging)
ARG BASHIO_VERSION="v0.16.2"
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl jq socat iproute2 \
    && mkdir -p /usr/lib/bashio \
    && curl -L -s "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" \
        | tar zxvf - --strip 1 -C /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bin/bashio /usr/bin/bashio \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy startup script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# 3. Add Labels (Standard OCI labels used by HA)
LABEL \
    io.hass.name="OTBR TCP (SLZB-06)" \
    io.hass.description="Robust OpenThread Border Router for TCP-connected adapters" \
    maintainer="Anton Dahlberg"

ENTRYPOINT ["/run.sh"]
