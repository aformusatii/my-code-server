# code-server dev image

Custom Docker Compose setup for a browser-based VS Code environment using
`lscr.io/linuxserver/code-server`.

The image is built from the local `Dockerfile` and pre-installs common
development tools so agents and humans can work inside the container without
runtime bootstrapping.

## What is included

- Python in `/config/.venv`, first on `PATH`
- Node.js 24 LTS with `npm`, `yarn`, and `pnpm`
- Codex CLI (`codex`), Claude Code CLI (`claude`), and OpenCode (`opencode`)
- GitHub CLI (`gh`), also used as git's credential helper for github.com
- Document/PDF tools: `pandoc` and `weasyprint` (HTML/CSS to PDF)
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

Create `.env` from `.env.example` and ensure the external `common-network`
Docker network exists, then pull and start the published image:

```bash
docker compose pull code-server
docker compose up -d code-server
```

Compose uses the ECR image and publishes port 8443. It has no `build:` section;
`docker compose up --build` does not build this Dockerfile.

Pushes to `main` trigger `.github/workflows/build_and_push_image.yml`, which
builds the image and publishes it to ECR. After that workflow succeeds, use
the commands above to deploy the new image.

## AI coding CLIs

Codex and OpenCode are installed globally through npm (`@openai/codex` and
`@opencode/cli`); Claude Code uses Anthropic's signed apt repository on the
stable release channel. All three are installed in the image,
outside the `/config` mount, and are available on `PATH`.

After deploying the updated image, run `codex`, `claude`, or `opencode` from a
project directory in the code-server terminal. From the Docker host, open a shell as the runtime user:

```bash
docker compose exec --user abc code-server bash
```

Follow each CLI's sign-in prompts on first use. Run them as `abc` so their
settings and file-based login state live in the persistent `/config` home.

The VS Code extensions normally use their own bundled executables; installing
these terminal commands does not switch the extensions to them. See the
[Codex extension settings](https://developers.openai.com/codex/ide/settings/)
and [Claude Code extension documentation](https://code.claude.com/docs/en/vs-code).

To fetch newer CLI releases, rebuild without Docker's cached install layers.
For a local build using the same tag as Compose:

```bash
docker build --no-cache -t public.ecr.aws/f3w7h7x2/code-server:latest .
docker compose up -d --pull never code-server
```

To pin a release, pass `--build-arg CODEX_VERSION=<version>` or
`--build-arg OPENCODE_VERSION=<version>` to `docker build`. Both default to
`latest`; Claude Code follows the apt repository's stable channel.

### OpenCode with DeepSeek

1. Run `opencode` from your app's project directory in the code-server terminal.
2. Enter `/connect`, select DeepSeek, and enter your DeepSeek API key.
3. Select an available DeepSeek model and start your coding task.

Credentials and settings stored under the runtime user's `/config` home persist
across container recreation. Do not put API keys in the Dockerfile or commit
them to the repository. Terminal use needs no extra service, port, or GPU.

The startup hook seeds global instructions at
`/config/.config/opencode/AGENTS.md` and bundled skills under
`/config/.config/opencode/skills/`, owned by `abc`. Matching template files are
overwritten at startup, while other user files are preserved. Project-specific
`AGENTS.md` files provide additional guidance.

See [OpenCode installation](https://opencode.ai/docs/),
[global instructions](https://opencode.ai/docs/instructions/), and
[DeepSeek integration](https://api-docs.deepseek.com/quick_start/agent_integrations/opencode/).

## GitHub CLI

`gh` is installed from GitHub's signed apt repository so agents can manage
repositories, pull requests, issues, releases, and Actions runs. The image's
system git config (`/etc/gitconfig`) routes `https://github.com` credentials
through `gh`, so HTTPS clone/push works once `gh` is logged in. SSH remotes are
unaffected.

Log in once as `abc` from the code-server terminal:

```bash
gh auth login -h github.com -p https -s workflow --insecure-storage
gh auth status
```

- The token is stored in `/config/.config/gh/hosts.yml`, so it survives image
  rebuilds and container recreation. `--insecure-storage` skips the system
  keyring, which does not exist in the container.
- The `workflow` scope lets agents edit `.github/workflows/*`. Add other scopes
  later only if needed, e.g. `gh auth refresh -s delete_repo`.
- To revoke access, run `gh auth logout` and remove the authorization under
  GitHub → Settings → Applications.

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
codex --version && claude --version && opencode --version
gh --version
pandoc --version && weasyprint --version
mvn -version
gcc --version
```
