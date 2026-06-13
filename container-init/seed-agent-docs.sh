#!/usr/bin/with-contenv bash
# -----------------------------------------------------------------------------
# Seed agent instruction docs into /config at container startup.
#
# /config is a bind mount, so files baked into it via the Dockerfile are
# shadowed by the host folder. linuxserver.io's s6-overlay runs scripts in
# /custom-cont-init.d AFTER the mount is in place, so this hook copies the
# image-baked templates into /config on every boot.
#
# The repo's agents/IMG_*.md files are the source of truth, so we overwrite
# on each start to keep the deployed copies in sync with the image.
# -----------------------------------------------------------------------------
set -e

# Codex -> /config/.codex/AGENTS.md
mkdir -p /config/.codex
cp /opt/agent-templates/AGENTS.md /config/.codex/AGENTS.md
chown abc:abc /config/.codex/AGENTS.md

# Claude -> /config/.claude/CLAUDE.md
mkdir -p /config/.claude
cp /opt/agent-templates/CLAUDE.md /config/.claude/CLAUDE.md
chown abc:abc /config/.claude/CLAUDE.md

echo "[seed-agent-docs] seeded .codex/AGENTS.md and .claude/CLAUDE.md into /config"
