#!/usr/bin/with-contenv bash
# -----------------------------------------------------------------------------
# Create the persisted Python virtual environment at container startup.
#
# /config is a bind mount and the runtime home for the linuxserver.io "abc" user,
# so the venv must be created after the mount is available instead of during the
# Docker build.
# -----------------------------------------------------------------------------
set -e

VENV=/config/.venv

if [ ! -x "$VENV/bin/python" ]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install --no-cache-dir --upgrade pip setuptools wheel
fi

chown -R abc:abc "$VENV"
chmod -R a+rwX "$VENV"

echo "[setup-python-venv] ensured Python venv exists at $VENV"
