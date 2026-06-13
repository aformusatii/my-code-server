# CLAUDE.md

## What This Environment Is

This is a **code-server** container (VS Code in the browser) based on the
`linuxserver/code-server` image, customized into a **multi-language
"Swiss-army-knife" development image**. Python, Node.js, Java, and a C/C++
toolchain are **pre-installed and ready** — you don't need to install or
verify them.

- **OS:** Ubuntu (Debian-based), `apt` available
- **User:** `abc` (non-root)
- **Shell:** bash

## Toolchain Cheat Sheet

| Language / Tool | What's available | How to use |
|-----------------|------------------|------------|
| **Python** | venv at `/opt/venv`, on PATH; `python`, `pip` | `pip install <pkg>` works directly — **no `--break-system-packages` needed** |
| **Node.js** | Node 20 LTS + `npm`, `yarn`, `pnpm` | `npm install`, `node app.js` |
| **Java** | OpenJDK 21 JDK + Maven + Gradle, `JAVA_HOME` set | `javac File.java`, `java File`, `mvn`, `gradle` |
| **C / C++** | `gcc`, `g++`, `make`, `cmake`, `gdb` | `gcc main.c -o main && ./main` |
| **Utilities** | `git`, `curl`, `wget`, `zip`, `unzip` | standard usage |

## Key Rules

1. **Python packages → use `pip install` into the active venv** (`/opt/venv`).
   - ❌ Don't `apt install python3-<lib>`.
   - ❌ Don't use `--break-system-packages` or `--user` — the venv handles it.
2. **The venv is writable** by the current user — no `sudo` needed for pip.
3. **Persistence:** Runtime installs persist for the container's life but are
   lost on container rebuild. Suggest a Dockerfile change for permanent tools.
4. **Trust the toolchain:** Everything above is guaranteed installed — avoid
   redundant `which`/`--version` checks unless debugging.

## When Adding New Tools
If a task needs a tool not listed here (e.g., Go, Rust, a system library),
note it clearly so it can be added to the **Dockerfile** for a permanent,
reproducible install rather than an ephemeral runtime install.