# code-server

Containerized [VS Code Server](https://github.com/coder/code-server) (browser-based IDE) with AI assistants and development tooling, running via Docker Compose.

## Stack

- **Image**: `lscr.io/linuxserver/code-server:latest` (LinuxServer.io)
- **Networking**: Host mode, connected to external `common-network`
- **Auto-update**: Enabled via `homelab.image.auto.update: true` (Watchtower-compatible)

## Directory Structure

```
code-server/
├── docker-compose.yaml   # Service definition
├── .env                  # Environment variables (PUID, PGID, TZ, sudo password)
├── config/               # Persisted container home directory (/config)
│   ├── .config/          # App config (code-server bind/auth, VS Code settings)
│   ├── .claude/          # Claude CLI config, sessions, memory, plugins
│   ├── extensions/       # Installed VS Code extensions
│   ├── data/             # Runtime data, logs, IPC socket
│   ├── .nvm/             # Node Version Manager + installed Node versions
│   └── install.sh        # Post-setup script (apt, python3, ffmpeg, yt-dlp, git)
├── scripts/              # Mounted to /opt/scripts inside container (currently empty)
└── backup/               # Backup copies of shell init files and install script
```

## Volumes

| Host Path          | Container Path   | Purpose                          |
|--------------------|------------------|----------------------------------|
| `./config`         | `/config`        | Persistent user config and data  |
| `./scripts`        | `/opt/scripts`   | Custom host/setup scripts        |
| `/home/aform/`     | `/opt/workspace` | Developer's home / workspace     |

## Environment Variables (`.env`)

| Variable            | Value                | Notes                        |
|---------------------|----------------------|------------------------------|
| `PUID`              | `1000`               | Run as user `abc` (UID 1000) |
| `PGID`              | `1000`               | Group ID                     |
| `TZ`                | `Europe/Chisinau`    | Timezone                     |
| `SUDO_PASSWORD`     | *(set in .env)*      | Sudo access inside container |
| `DEFAULT_WORKSPACE` | `/opt/workspace`     | Default folder on open       |
| `PWA_APPNAME`       | `code-server`        | Browser PWA name             |

## Networking

- **Mode**: Host (inherits host network stack)
- **External network**: `common-network` (must be pre-created)
- **code-server listens on**: `127.0.0.1:8080` (localhost only, no TLS)
- Commented-out port mappings: `8039→8443`, `8041→3000`

## Installed VS Code Extensions

| Extension                         | Purpose                  |
|-----------------------------------|--------------------------|
| `anthropic.claude-code` v2.1.117  | Claude AI assistant      |
| `github.copilot` v1.388.0         | GitHub Copilot           |
| `openai.chatgpt` v26.417          | ChatGPT integration      |
| `vue.volar` v3.2.7                | Vue.js language support  |
| `jebbs.plantuml` v2.18.1          | PlantUML diagrams        |

## Development Tools (installed via `config/install.sh`)

- **Python 3** + pip
- **FFmpeg**
- **yt-dlp** (YouTube/media downloader)
- **Node.js** via NVM
- **Git** (pre-configured for user `aformusatii`)

## Initial Setup

```bash
# Create the external network if it doesn't exist
docker network create common-network

# Start the container
docker compose up -d

# Run the setup script inside the container (first time only)
docker exec -it code-server bash /config/install.sh
```

Access the IDE at `http://localhost:8080` (or via reverse proxy on your homelab).

## Notes

- The `config/` directory is the full home directory of the container user — treat it as stateful. Do not delete it.
- `scripts/host` and `scripts/setup` are empty placeholders for future automation.
- The `backup/` directory holds old copies of shell init files — not used at runtime.
- `.env` contains a plaintext sudo password — keep this file private and out of version control.
