# Minecraft Script Launcher (MCSL)

[![Bash](https://img.shields.io/badge/Bash-4%2B-brightgreen?style=for-the-badge)](https://www.gnu.org/software/bash/) [![tmux](https://img.shields.io/badge/tmux-required-blue?style=for-the-badge)](https://github.com/tmux/tmux) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)

---

## 📝 Description

**MCSL** is a lightweight Bash-based Minecraft server launcher that runs the server inside a `tmux` session.
It provides commands to start, stop, restart, attach to the console, query status, and self-update the launcher.

---

## ✨ Features

- Start, stop, and restart a Minecraft server using a simple CLI wrapper
- Attach to the Minecraft server console through `tmux`
- Query online/offline status via TCP
- Automatic crash-restart support with retry limits
- Prevent duplicate `tmux` sessions for the same server
- Built-in help and version reporting

---

## ⚙️ Requirements

- **Bash** (4.4+ recommended)
- **tmux** (available in `PATH`)
- **git** (required for `selfupdate`)
- Minecraft server startup script or command (for example `run.sh`)

> **Note:** MCSL is intended for Unix-like environments. On Windows, use WSL, Cygwin, MSYS2, or another compatible shell with `tmux`.

---

## 🚀 Installation

1. Install `tmux`:

   - Ubuntu/Debian: `sudo apt-get install tmux`
   - CentOS/Fedora: `sudo dnf install tmux`
   - macOS (Homebrew): `brew install tmux`

2. Clone or download the repository:

   ```bash
   git clone https://github.com/NoveIX/mcsl.git
   cd mcsl
   ```

3. Make the launcher executable:

   ```bash
   chmod +x mcsl.sh
   ```

---

## 📦 Usage

Run the launcher with a command:

```bash
./mcsl.sh <command> [options]
```

### Commands

- `help`, `-h`, `--help` — show help information
- `version`, `-v`, `--version` — show the installed MCSL version
- `start` — start the Minecraft server
- `stop` — stop the Minecraft server gracefully
- `restart` — restart the Minecraft server gracefully
- `console`, `-c`, `--console` — attach to the server `tmux` console
- `status` — display the server status
- `selfupdate` — update MCSL from the Git repository

### Options

- `-s`, `--session <name>` — tmux session name (default derived from server root)
- `-t`, `--time <seconds>` — delay in seconds for stop/restart operations
- `-c`, `--console` — attach to the tmux session after starting or restarting
- `-h`, `--host <host>` — host to query for status (default: `localhost`)
- `-p`, `--port <port>` — port to query for status (default: `25565`)

### Examples

```bash
./mcsl.sh start
./mcsl.sh stop --time 30
./mcsl.sh restart --time 60 --console
./mcsl.sh console
./mcsl.sh status --host localhost --port 25565
./mcsl.sh selfupdate
```

---

## ⚙️ Configuration

The runtime controller is `src/script/mcslctl.sh`.
It loads configuration from `cfg/mcsl-behavior.ini` and generates a default config if missing.

Default config values:

```ini
StartCommand=run.sh
CrashHandle=true
MaxRestart=3
```

- `StartCommand` — startup script or command used to launch the Minecraft server
- `CrashHandle` — `true` to restart automatically after a crash; `false` to stop instead
- `MaxRestart` — maximum crash restart attempts before stopping (use `-1` for unlimited retries)

---

## 🧠 Behavior notes

- `start` launches `src/script/mcslctl.sh` inside a detached `tmux` session.
- If the session already exists, `start` logs a warning and does not create a duplicate.
- `stop` sends an in-game warning before issuing the `stop` command, honoring the configured delay.
- `restart` stops the server, waits for the `tmux` session to terminate, then starts it again.
- `status` checks TCP connectivity; for `localhost`, it reads `server.properties` to detect the actual server port.
- `selfupdate` runs `git restore -- .` and `git pull` inside the MCSL directory.

---

## 📁 Project structure

- `mcsl.sh` — main CLI entrypoint
- `src/script/mcslctl.sh` — runtime controller loop
- `src/lib/core/` — shared module utilities (`logger`, `config`, `tmux`, etc.)
- `src/lib/commands/` — command handlers (`start`, `stop`, `restart`, `status`, `selfupdate`, `help`, `version`)
- `src/runtime/` — runtime state files such as `restartctl`
- `cfg/` — generated configuration directory
- `logs/` — log files

---

## 📜 License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
