# AGENTS.md

## Environment Overview

You are running inside a **code-server** container (browser-based VS Code)
built on the `linuxserver/code-server` image. This is a pre-provisioned
**multi-language development environment** — a "Swiss-army-knife" image with
several languages and toolchains already installed. **Do not waste steps
checking whether a tool exists — the tools below are guaranteed present.**

- **OS:** Ubuntu (Debian-based), `apt` available.
- **Runtime user:** `abc` (non-root). Use `sudo` only if explicitly available.
- **Shell:** bash.

## Available Tools & How to Use Them

### 🐍 Python
- A **pre-activated virtual environment** lives at `/config/.venv` and is **first on `PATH`**.
- `python`, `python3`, `pip`, and `pip3` all resolve to this venv.
- **Install packages directly:** `pip install <package>` — it just works.
  - ⚠️ Do NOT use `apt install python3-<pkg>` for Python libraries.
  - ⚠️ Do NOT use `pip install --user` or `--break-system-packages`; not needed.
- The venv is writable by user `abc`, so no `sudo` is required for pip.

### 🟢 Node.js / JavaScript / TypeScript
- **Node.js 24 LTS**, with `npm`, `yarn`, and `pnpm` available globally.
- Install project deps: `npm install`, `yarn`, or `pnpm install`.
- Run code: `node script.js`.

### ☕ Java
- **OpenJDK 21 (full JDK)** — `javac` (compiler) and `java` (runtime).
- `JAVA_HOME` is set. Build tools **Maven** (`mvn`) and **Gradle** (`gradle`) are installed.
- Compile: `javac File.java` → Run: `java File`.

### 🛠️ C / C++ (GCC toolchain)
- `gcc`, `g++`, `make`, `cmake`, `gdb` are available.
- Compile: `gcc main.c -o main` then `./main`.

### General Utilities
- `git`, `curl`, `wget`, `unzip`, `zip` are installed.

### 🐙 GitHub CLI
- `gh` is installed; the user authenticates it once with `gh auth login`.
- Use `gh` for GitHub work instead of raw API calls: `gh pr create`,
  `gh issue list`, `gh run watch`, `gh release create`, `gh api ...`.
- HTTPS `git push`/`pull` to github.com uses gh's credentials automatically.
- If `gh auth status` reports no login, ask the user to run `gh auth login`.
  ⚠️ Do NOT ask the user to paste tokens.

### 📄 Documents / PDF
- `pandoc` converts between Markdown, HTML, DOCX, and other formats.
- `weasyprint` renders HTML/CSS to PDF; it is also pandoc's PDF engine here
  (no LaTeX is installed).
- Markdown → PDF: `pandoc in.md -o out.pdf --pdf-engine=weasyprint`.
- HTML → PDF: `weasyprint in.html out.pdf`.

## Operating Guidelines
1. **Prefer the venv Python** — never modify the system Python.
2. **Persisting installs:** Runtime `pip` installs live inside `/config/.venv`
   and persist with the `/config` mount. Runtime global `npm` installs live
   inside the container filesystem and are lost if the container is recreated.
   For permanent tools, request a Dockerfile update.
3. **Work directory:** Use the workspace folder you are placed in.
4. **Be efficient:** The listed tools exist — skip redundant existence checks.
