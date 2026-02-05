ARG BUILD_FROM=openthread/otbr:latest
FROM ${BUILD_FROM}

# 1. Install dependencies
# 'socat' for TCP bridging
# 'curl', 'jq' for Bashio (HA config helper)
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    socat \
    && rm -rf /var/lib/apt/lists/*

# 2. Install S6 Overlay
# Critical for process supervision (keeping socat and otbr running)
ARG S6_OVERLAY_VERSION=3.2.1.0
RUN set -eux; \
    # Detect architecture for S6
    if [ -z "${TARGETARCH:-}" ]; then \
        if command -v dpkg >/dev/null 2>&1; then \
            TARGETARCH="$(dpkg --print-architecture)"; \
        else \
            TARGETARCH="$(uname -m)"; \
        fi; \
    fi; \
    case "${TARGETARCH}" in \
        amd64|x86_64) S6_ARCH=x86_64 ;; \
        arm64|aarch64) S6_ARCH=aarch64 ;; \
        *) echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    # Download and install
    curl -L -sS "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" -o /tmp/s6-noarch.tar.xz && \
    curl -L -sS "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" -o /tmp/s6-arch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-arch.tar.xz && \
    rm -f /tmp/s6-*.tar.xz

# 3. Install Bashio
# This makes the addon fully compatible with Home Assistant's config system
ARG BASHIO_VERSION="v0.16.2"
RUN curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# 3. Copy our setup script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# 4. Entrypoint
# We use our script to initialize the environment (socat) before
# handing over to the S6 init system provided by the base image.
ENTRYPOINT ["/run.sh"]
