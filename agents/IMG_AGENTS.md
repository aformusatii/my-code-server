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
- **Node.js 20 LTS**, with `npm`, `yarn`, and `pnpm` available globally.
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

## Operating Guidelines
1. **Prefer the venv Python** — never modify the system Python.
2. **Persisting installs:** Runtime `pip` installs live inside `/config/.venv`
   and persist with the `/config` mount. Runtime global `npm` installs live
   inside the container filesystem and are lost if the container is recreated.
   For permanent tools, request a Dockerfile update.
3. **Work directory:** Use the workspace folder you are placed in.
4. **Be efficient:** The listed tools exist — skip redundant existence checks.
