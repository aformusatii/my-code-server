#!/usr/bin/with-contenv bash
# -----------------------------------------------------------------------------
# Let "abc" run docker/docker compose without sudo.
#
# The host's /var/run/docker.sock is bind-mounted in, but its group GID is
# host-specific and abc's group memberships are (re)built by the linuxserver.io
# init from PUID/PGID, so a static `group_add` in compose isn't reliably kept.
# Instead, create/reuse a group matching the socket's GID and add abc to it
# after the mount is available.
# -----------------------------------------------------------------------------
set -e

SOCKET=/var/run/docker.sock

if [ ! -S "$SOCKET" ]; then
    echo "[setup-docker-group] $SOCKET not mounted, skipping"
    exit 0
fi

SOCKET_GID=$(stat -c '%g' "$SOCKET")
GROUP_NAME=$(getent group "$SOCKET_GID" | cut -d: -f1)

if [ -z "$GROUP_NAME" ]; then
    GROUP_NAME=docker
    groupadd -g "$SOCKET_GID" "$GROUP_NAME"
fi

usermod -aG "$GROUP_NAME" abc

echo "[setup-docker-group] added abc to group '$GROUP_NAME' (gid $SOCKET_GID)"
