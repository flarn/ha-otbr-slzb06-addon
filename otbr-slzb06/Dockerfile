ARG BUILD_FROM=openthread/otbr:latest
FROM ${BUILD_FROM}

# Install only what is strictly necessary
RUN apt-get update && apt-get install -y --no-install-recommends \
    socat iproute2 \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh
ENTRYPOINT ["/run.sh"]
