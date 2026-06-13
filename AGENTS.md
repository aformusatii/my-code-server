# AGENTS.md

## Repository Purpose

This repository builds and runs a custom `linuxserver/code-server` Docker image:
a browser-based VS Code environment with common language toolchains installed at
image build time.

The project is Dockerfile-first. Treat the `Dockerfile` as the source of truth
for tools available inside the container.

## Key Files

- `Dockerfile` - defines the custom image and installed toolchains.
- `docker-compose.yaml` - runs the image, mounts persistent folders, and uses
  host networking.
- `.env.example` - documents expected runtime environment variables.
- `restart.sh` - convenience wrapper for `docker compose down` followed by
  `docker compose up -d --build`.
- `agents/` - instruction files for agents running inside the built container.
  These are not repository-maintenance instructions for this repo unless the
  task explicitly asks to update in-container agent guidance.

## Image Design

- Base image: `lscr.io/linuxserver/code-server:latest`.
- Runtime user: `abc`, controlled by linuxserver.io's `PUID`/`PGID` handling.
- Runtime home: `/config`, mounted from `./config` and intended to persist.
- Build steps run as root in the Dockerfile so tools are reproducible.
- Do not override the base image `ENTRYPOINT`.

## Current Toolchains

| Toolchain | Current Dockerfile state |
| --- | --- |
| Python | `python3`, `pip`, `venv`, and dev headers are installed. A virtual environment is created at `/opt/venv`, placed first on `PATH`, and owned by `abc`. |
| Node.js | Node.js 20 from NodeSource, plus global `yarn` and `pnpm` installed during the image build. |
| Java | OpenJDK 21 JDK, Maven, and Gradle. `JAVA_HOME` is set to `/usr/lib/jvm/java-21-openjdk-amd64`. |
| C / C++ | `build-essential`, `gcc`, `g++`, `make`, `cmake`, and `gdb`. |
| Utilities | `git`, `curl`, `wget`, `zip`, `unzip`, `ca-certificates`, `gnupg`, `software-properties-common`, and `pkg-config`. |

## Maintenance Guidelines

1. Add permanent tools to the `Dockerfile`; avoid documenting runtime manual
   installs as part of the image.
2. Keep Python package installs inside `/opt/venv`. Do not recommend
   `--break-system-packages` for normal use.
3. If adding language ecosystems that need writable global state, create an
   explicit writable location and `chown` it for `abc`.
4. Preserve linuxserver.io startup mechanics. Do not set a final `USER` or
   custom `ENTRYPOINT`.
5. Use `--no-install-recommends` and clean `/var/lib/apt/lists/*` in apt
   install layers.
6. Be careful with architecture-specific paths such as `JAVA_HOME`; the current
   value is for amd64.

## Quick Checks

After changing the image, rebuild and verify:

```bash
python --version && pip --version
node --version && npm --version
mvn -version
gcc --version
```
