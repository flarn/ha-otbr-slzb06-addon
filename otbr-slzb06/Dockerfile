ARG BUILD_FROM=bnutzer/otbr-tcp:latest
FROM ${BUILD_FROM}

# Hardcoded configurations from bnutzer/otbr-tcp docs
ENV RCP_HOST="192.168.2.22"
ENV RCP_PORT="6638"
ENV RCP_BAUDRATE="460800"
ENV OTBR_WEB_ENABLE=1

COPY run.sh /run.sh
RUN chmod a+x /run.sh
ENTRYPOINT ["/run.sh"]
