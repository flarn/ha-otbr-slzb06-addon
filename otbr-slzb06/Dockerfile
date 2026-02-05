ARG BUILD_FROM=openthread/otbr:latest
FROM ${BUILD_FROM}

ARG TARGETARCH
ARG S6_OVERLAY_VERSION="v2.2.0.3"
ARG BASHIO_VERSION="v0.16.2"

# 1. Install system tools, S6, and Bashio
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl jq socat iproute2 \
    && case "${TARGETARCH}" in \
        "amd64") S6_ARCH="amd64" ;; \
        "arm64") S6_ARCH="aarch64" ;; \
        *) S6_ARCH="amd64" ;; \
    esac \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" | tar zxvf - -C / \
    && mkdir -p /usr/lib/bashio \
    && curl -L -s "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" | tar zxvf - --strip 1 -C /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bin/bashio /usr/bin/bashio \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy startup script
COPY run.sh /etc/cont-init.d/otbr-setup.sh
ENTRYPOINT ["/init"]
