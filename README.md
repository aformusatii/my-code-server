# code-server dev image

Custom Docker Compose setup for a browser-based VS Code environment using
`lscr.io/linuxserver/code-server`.

The image is built from the local `Dockerfile` and pre-installs common
development tools so agents and humans can work inside the container without
runtime bootstrapping.

## What is included

- Python in `/config/.venv`, first on `PATH`
- Node.js 20 with `npm`, `yarn`, and `pnpm`
- Codex CLI (`codex`) and Claude Code CLI (`claude`)
- OpenJDK 21 with Maven and Gradle
- C/C++ tools: `gcc`, `g++`, `make`, `cmake`, `gdb`
- Utilities: `git`, `curl`, `wget`, `zip`, `unzip`

## Main files

- `Dockerfile` - source of truth for installed tools
- `docker-compose.yaml` - service, volumes, environment, networking
- `.env.example` - expected environment variables
- `restart.sh` - rebuild and restart helper
- `agents/` - instruction files intended for agents running inside the image

## Volumes

| Host path | Container path | Purpose |
| --- | --- | --- |
| `./config` | `/config` | Persistent code-server home/config |
| `./scripts` | `/opt/scripts` | Optional helper scripts |
| `/home/aform/` | `/opt/workspace` | Workspace mount |

`./config`, `./scripts`, `.env`, and `backup/` are ignored by git.

## Run

Create `.env` from `.env.example`, then start the container:

```bash
docker compose up -d --build
```

Or rebuild and restart with:

```bash
./restart.sh
```

The compose file uses `network_mode: host`, so access depends on the
code-server bind/port settings stored under `./config`.

## AI coding CLIs

Codex is installed globally through npm; Claude Code uses Anthropic's signed
apt repository on the stable release channel. Both are installed in the image,
outside the `/config` mount, and are available on `PATH`.

After rebuilding, run `codex` or `claude` from a project directory in the
code-server terminal. From the Docker host, open a shell as the runtime user:

```bash
docker compose exec --user abc code-server bash
```

Follow each CLI's sign-in prompts on first use. Run them as `abc` so their
settings and file-based login state live in the persistent `/config` home.

The VS Code extensions normally use their own bundled executables; installing
these terminal commands does not switch the extensions to them. See the
[Codex extension settings](https://developers.openai.com/codex/ide/settings/)
and [Claude Code extension documentation](https://code.claude.com/docs/en/vs-code).

To fetch newer CLI releases, rebuild without Docker's cached install layers:

```bash
docker compose build --no-cache code-server
docker compose up -d code-server
```

For a specific Codex release, pass `--build-arg CODEX_VERSION=<version>` to the
build command. Claude Code follows the apt repository's stable channel.

## Maintenance notes

- Add permanent tools to the `Dockerfile`, not by hand inside a running
  container.
- Do not override the linuxserver.io base image `ENTRYPOINT`.
- Keep `/config` persistent; it is the runtime user's home directory and stores
  the Python venv at `/config/.venv`.
- After Dockerfile changes, sanity-check the key tools:

```bash
python --version && pip --version
node --version && npm --version
codex --version && claude --version
mvn -version
gcc --version
```
