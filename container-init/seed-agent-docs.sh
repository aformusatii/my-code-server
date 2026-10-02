#!/usr/bin/with-contenv bash
# -----------------------------------------------------------------------------
# Seed agent instruction docs and skills into /config at container startup.
#
# /config is a bind mount, so files baked into it via the Dockerfile are
# shadowed by the host folder. linuxserver.io's s6-overlay runs scripts in
# /custom-cont-init.d AFTER the mount is in place, so this hook copies the
# image-baked templates into /config on every boot.
#
# The repo's agents/IMG_*.md files and agents/skills/ are the source of truth.
# Matching files are overwritten on each start. Other installed skills are
# preserved; files removed from the image are not automatically deleted.
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

mkdir -p "/config/.codex/skills"
cp -R /opt/agent-templates/skills/. "/config/.codex/skills/"
chown -R abc:abc "/config/.codex/skills"

mkdir -p "/config/.claude/skills"
cp -R /opt/agent-templates/skills/. "/config/.claude/skills/"
chown -R abc:abc "/config/.claude/skills"

echo "[seed-agent-docs] seeded instruction docs and skills for Codex and Claude into /config"
