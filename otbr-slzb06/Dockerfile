ARG BUILD_FROM=openthread/otbr:latest
FROM ${BUILD_FROM}

ARG TARGETARCH
ARG S6_OVERLAY_VERSION="v2.2.0.3"
ARG BASHIO_VERSION="v0.16.2"

# 1. Install everything in one clean step
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl jq socat \
    && case "${TARGETARCH}" in \
        "amd64") S6_ARCH="amd64" ;; \
        "arm64") S6_ARCH="aarch64" ;; \
        *) S6_ARCH="amd64" ;; \
    esac \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" | tar zxvf - -C / \
    && mkdir -p /tmp/bashio \
    && curl -L -s "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" | tar zxvf - --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# 2. Setup startup script and entrypoint
COPY run.sh /etc/cont-init.d/otbr-setup.sh
ENTRYPOINT ["/init"]
