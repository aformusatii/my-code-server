FROM lscr.io/linuxserver/code-server:latest

# =============================================================================
# SWISS-ARMY-KNIFE DEV IMAGE FOR AI AGENTS (Codex / Claude Code)
# Base: linuxserver/code-server (Ubuntu-based, runs as user "abc", PUID/PGID)
# =============================================================================

# ---- All build steps run as root so they persist in the image ----
USER root

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# 1. Core OS tooling + build essentials + Python + GCC toolchain
# -----------------------------------------------------------------------------
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        # General utilities
        curl \
        wget \
        git \
        unzip \
        zip \
        ca-certificates \
        gnupg \
        software-properties-common \
        pkg-config \
        # Build / compiler toolchain (GCC, make, etc.)
        build-essential \
        gcc \
        g++ \
        gdb \
        make \
        cmake \
        # Python
        python3 \
        python3-pip \
        python3-venv \
        python3-dev && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 2. Python virtual environment (solves PEP 668 "externally-managed" error)
#    The venv lives under /config, which is the runtime user's persisted home.
#    A startup hook creates it after the /config bind mount is available.
# -----------------------------------------------------------------------------
ENV VIRTUAL_ENV=/config/.venv

# Put the venv first on PATH so `python`, `pip`, etc. resolve to it everywhere.
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# -----------------------------------------------------------------------------
# 3. Node.js (LTS) + npm + common global package managers
#    Installed via NodeSource for an up-to-date version.
# -----------------------------------------------------------------------------
ENV NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g yarn pnpm && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 4. Java (JDK) — OpenJDK via the Adoptium-friendly default packages
#    Installs a full JDK (compiler + runtime), not just the JRE.
# -----------------------------------------------------------------------------
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        openjdk-21-jdk \
        maven \
        gradle && \
    rm -rf /var/lib/apt/lists/*

# Expose JAVA_HOME so build tools find it reliably.
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# -----------------------------------------------------------------------------
# 5. Runtime initialization hooks
#    /config is a bind mount, so files copied straight into it are shadowed at
#    runtime. s6 startup hooks in /custom-cont-init.d run after the mount is
#    available, so they can create persisted runtime files there.
# -----------------------------------------------------------------------------
COPY agents/IMG_AGENTS.md /opt/agent-templates/AGENTS.md
COPY agents/IMG_CLAUDE.md /opt/agent-templates/CLAUDE.md
COPY container-init/setup-python-venv.sh /custom-cont-init.d/98-setup-python-venv
COPY container-init/seed-agent-docs.sh /custom-cont-init.d/99-seed-agent-docs
RUN chmod +x \
        /custom-cont-init.d/98-setup-python-venv \
        /custom-cont-init.d/99-seed-agent-docs

# -----------------------------------------------------------------------------
# 6. (Future expansion) Add more languages/tools below this line.
#    e.g. Go, Rust, .NET, databases clients, etc.
# -----------------------------------------------------------------------------
# RUN ...

# Reset frontend (good practice; image still runs as the LSIO entrypoint)
ENV DEBIAN_FRONTEND=

# NOTE: Do NOT change USER or ENTRYPOINT — the linuxserver.io base image uses
# s6-overlay and drops privileges to "abc" via PUID/PGID automatically.
