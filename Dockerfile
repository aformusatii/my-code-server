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
#    Agents can freely `pip install` into this venv.
# -----------------------------------------------------------------------------
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "$VIRTUAL_ENV" && \
    "$VIRTUAL_ENV/bin/pip" install --no-cache-dir --upgrade pip setuptools wheel

# Put the venv first on PATH so `python`, `pip`, etc. resolve to it everywhere.
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Convenience symlink so bare `python` works too.
RUN ln -sf "$VIRTUAL_ENV/bin/python" /usr/local/bin/python

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
# 5. Permissions: ensure the runtime user ("abc") can write to the venv
#    so agents can install Python packages at runtime without sudo.
# -----------------------------------------------------------------------------
RUN chown -R abc:abc "$VIRTUAL_ENV"

# -----------------------------------------------------------------------------
# 6. Agent instruction docs
#    /config is a bind mount, so files copied straight into it are shadowed at
#    runtime. Instead we bake the templates into a non-mounted path and let an
#    s6 startup hook (/custom-cont-init.d) seed them into /config after the
#    mount is in place. Source of truth lives in agents/IMG_*.md.
# -----------------------------------------------------------------------------
COPY agents/IMG_AGENTS.md /opt/agent-templates/AGENTS.md
COPY agents/IMG_CLAUDE.md /opt/agent-templates/CLAUDE.md
COPY container-init/seed-agent-docs.sh /custom-cont-init.d/99-seed-agent-docs
RUN chmod +x /custom-cont-init.d/99-seed-agent-docs

# -----------------------------------------------------------------------------
# 7. (Future expansion) Add more languages/tools below this line.
#    e.g. Go, Rust, .NET, databases clients, etc.
# -----------------------------------------------------------------------------
# RUN ...

# Reset frontend (good practice; image still runs as the LSIO entrypoint)
ENV DEBIAN_FRONTEND=

# NOTE: Do NOT change USER or ENTRYPOINT — the linuxserver.io base image uses
# s6-overlay and drops privileges to "abc" via PUID/PGID automatically.