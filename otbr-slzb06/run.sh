#!/bin/bash

# 1. Handle Persistence
# Ensure Thread datasets survive add-on restarts/updates
mkdir -p /data/otbr
ln -sfn /data/otbr /var/lib/thread

# 2. Hand over to the base image's entrypoint
# This starts socat and otbr-agent using the ENV variables set in Dockerfile
exec /entrypoint.sh
