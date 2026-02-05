ARG BUILD_FROM=openthread/otbr:latest
FROM ${BUILD_FROM}

ENV LANG C.UTF-8
ARG TARGETARCH
ARG S6_OVERLAY_VERSION="v2.2.0.3"
ARG BASHIO_VERSION="v0.16.2"

# 1. Install Dependencies, S6 Overlay, and Bashio in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl jq socat \
    && case "${TARGETARCH}" in \
        "amd64") S6_ARCH="amd64" ;; \
        "arm64") S6_ARCH="aarch64" ;; \
        *) S6_ARCH="amd64" ;; \
    esac \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" | tar zxvf - -C / \
    && curl -L -s "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" | tar zxvf - --strip 1 -C /tmp \
    && mv /tmp/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# 2. Copy rootfs (scripts)
COPY run.sh /etc/cont-init.d/otbr-setup.sh
RUN chmod +x /etc/cont-init.d/otbr-setup.sh

# 3. Entrypoint
# S6 Overlay v2 uses /init to manage services
ENTRYPOINT ["/init"]
