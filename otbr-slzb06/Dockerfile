ARG BUILD_FROM
FROM $BUILD_FROM

# Copy the script to the S6 initialization folder
# This makes it run automatically before services start
COPY run.sh /etc/cont-init.d/01-otbr-config
RUN chmod a+x /etc/cont-init.d/01-otbr-config

# We do not define a CMD here, so the base image's 
# internal S6 init system runs by default.