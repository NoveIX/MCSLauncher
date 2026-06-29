# Minecraft Script Launcher (MCSL)

[![Bash](https://img.shields.io/badge/Bash-4%2B-brightgreen?style=for-the-badge)](https://www.gnu.org/software/bash/) [![tmux](https://img.shields.io/badge/tmux-required-blue?style=for-the-badge)](https://github.com/tmux/tmux) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)

Last updated: 2026-06-19

---

## 📝 Description


- Tested on Ubuntu 24.04 and Debian 13; WSL2 on Windows is supported.
**MCSL** is a lightweight Bash-based Minecraft server launcher that simplifies server management using `tmux` sessions.

---

## ✨ Features

- ⚡ **Simple CLI** — Start, stop, restart servers with one command
- 🔄 **Automatic Crash Recovery** — Configurable auto-restart on crashes with retry limits
- 💬 **Console Access** — Attach to the server console anytime via `tmux`
- 📊 **Server Status** — Query online/offline status and uptime
- 🔁 **Multi-Server Support** — Manage multiple servers from one launcher
- 📝 **Detailed Logging** — Comprehensive logs for debugging and monitoring
- 🛡️ **Graceful Shutdown** — Configurable warnings before stopping the server
- 🔧 **Self-Update** — Keep MCSL updated from Git

---

## 🧠 How It Works

MCSL follows a simple architecture:

1. **CLI Layer** (`mcsl.sh`) — Parses commands and options, delegates to command modules
2. **Command Modules** (`src/lib/commands/`) — Handle individual operations (start, stop, status, etc.)
3. **Runtime Controller** (`src/script/mcslctl.sh`) — Runs inside a `tmux` session and:
   - Executes the Minecraft server startup command
   - Monitors the process and detects crashes
   - Automatically restarts the server if configured
   - Maintains detailed logs of all operations
   - Gracefully handles shutdown requests

### Command Flow

```
User Input
    ↓
mcsl.sh (CLI parsing)
    ↓
Command Module (start/stop/restart/status/etc.)
    ↓
For 'start' command:
  ├→ Creates a tmux session
  └→ Spawns mcslctl.sh inside
       ↓
    mcslctl.sh (runtime loop)
       ├→ Reads config (`cfg/mcslctl.conf` and `cfg/mcslctl-notify.conf`)
       ├→ Executes StartCommand (run.sh or custom script)
       ├→ Monitors server process
       ├→ Auto-restarts on crash (if enabled)
       └→ Logs all events
```

---

## ⚙️ Requirements

- **Bash** (4.4+ recommended)
- **tmux** (available in `PATH`)
- **git** (required for `selfupdate`)
- Minecraft server startup script or command (e.g., `run.sh` or `java -jar server.jar`)

---

## 🚀 Quick Start (3 Steps)

### 1️⃣ Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install bash tmux git
```

**CentOS/RHEL/Fedora:**
```bash
sudo dnf install bash tmux git
```

**macOS (Homebrew):**
```bash
brew install bash tmux git
```

### 2️⃣ Clone MCSL into Your Server Directory

Navigate to your Minecraft server directory and clone MCSL:

```bash
cd ~/minecraft-server          # Your server root directory
git clone https://github.com/NoveIX/MCSLauncher.git ./mcsl
chmod +x ./mcsl/mcsl.sh
```

**Expected directory structure:**
```
minecraft-server/              ← Server root
  ├── mcsl/                    ← MCSL installation
  │   ├── mcsl.sh              ← Main launcher script
  │   ├── src/
  │   ├── README.md
  │   └── ...
  ├── run.sh                   ← Your server startup script
  ├── server.jar               ← Your Minecraft server
  ├── server.properties        ← Server config
  └── world/                   ← Game data
```

### 3️⃣ Start Your Server

```bash
cd ~/minecraft-server/mcsl
./mcsl.sh start
```

If this is the first time you run `start`, MCSL will generate default config files in `cfg/` and exit. Edit `cfg/mcslctl.conf` or `cfg/mcslctl-notify.conf` if needed, then run `./mcsl.sh start` again.

That's it! Your server is now running in a `tmux` session.

---

## 📖 Installation Details

The installation creates a modular structure where MCSL sits alongside your Minecraft server files.

### Directory Layout After Installation

```
minecraft-server/                    ← Server root directory
  ├── mcsl/                          ← MCSL launcher (this repo)
  │   ├── mcsl.sh                    ← Main entry point
  │   ├── src/
  │   │   ├── lib/
  │   │   │   ├── commands/          ← Command modules
  │   │   │   └── core/              ← Utility modules
  │   │   └── script/
  │   │       └── mcslctl.sh         ← Runtime controller
  │   ├── cfg/                       ← Config files (auto-created)
  │   ├── logs/                      ← Log files (auto-created)
  │   ├── README.md
  │   └── version
  ├── run.sh                         ← Your server startup script
  ├── server.jar                     ← Minecraft server JAR
  ├── server.properties              ← Server settings
  ├── eula.txt                       ← EULA acceptance
  ├── world/                         ← Game world data
  ├── plugins/                       ← If using Spigot/Paper
  └── mods/                          ← If using Forge/Fabric
```

### Verify Installation

After installation, verify everything works:

```bash
cd ~/minecraft-server/mcsl

# Check version
./mcsl.sh version

# View help
./mcsl.sh help

# Test start (watch the logs)
./mcsl.sh start --console
```

---

## 📦 Usage Guide

### Basic Commands

All commands are run from the MCSL directory:

```bash
cd ~/minecraft-server/mcsl
./mcsl.sh <command> [options]
```

### Commands Reference

| Command | Shortcut | Description |
|---------|----------|-------------|
| `help` | `-h`, `--help` | Show available commands and options (also accepted as a top-level command) |
| `version` | `-v`, `--version` | Display MCSL version |
| `start` | | Start the Minecraft server |
| `stop` | `-t`, `--time` | Stop the server gracefully (use `--time` to set delay) |
| `restart` | `-t`, `--time` | Restart the server (stop + start) |
| `console` | `-c`, `--console` | Attach to the server console |
| `status` | `--host`, `-h`, `--port`, `-p` | Check if server is online (use `--host`/`--port` for remote checks) |
| `migrate` | `-d`, `--dest` | Move the server to a new location (local or remote) |
| `kill` | `--confirm-action` | Forcefully kill a server tmux session (destructive; requires confirmation) |
| `selfupdate` | | Update MCSL from Git |

### Common Options

| Option | Description |
|--------|-------------|
| `-s, --session <name>` | tmux session name (default: derived from directory) |
| `-t, --time <seconds>` | Delay before stopping (gives warning to players) |
| `-c, --console` | Auto-attach to console after start/restart |
| `-a, --all` | Apply command to all servers in parent directory |
| `-h, --host <host>` | Host for status check (default: `localhost`) |
| `-p, --port <port>` | Port for status check (default: `25565`) |
| `-d, --dest <dest>` | Destination path or remote target for `migrate` (local path or `user@host:/path`) |
| `-u, --user <user>` | User for remote migration (`migrate`) |
| `-k, --key <key>` | SSH key file for remote migration (`migrate`) |
| `--confirm-action` | Required to confirm destructive actions like `kill` |

### Practical Examples

**Start the server:**
```bash
./mcsl.sh start
```

**Start and auto-attach to console:**
```bash
./mcsl.sh start --console
```

**Gracefully stop with 30-second warning:**
```bash
./mcsl.sh stop --time 30
```

**Restart with 60-second warning and auto-attach:**
```bash
./mcsl.sh restart --time 60 --console
```

**Attach to server console (if already running):**
```bash
./mcsl.sh console
```

**Check server status:**
```bash
./mcsl.sh status
```

**Check remote server status:**
```bash
./mcsl.sh status --host 192.168.1.100 --port 25565
```

**Update MCSL to latest version:**
```bash
./mcsl.sh selfupdate
```

**Manage multiple servers (if installed in parent directory):**
```bash
./mcsl.sh start --all              # Start all servers
./mcsl.sh stop --time 60 --all     # Stop all servers
./mcsl.sh status --all             # Check all servers
```

Note: `-h` is used both as a top-level short alias for the `help` command and as the short option for `--host` when used after a command (for example `./mcsl.sh status -h 1.2.3.4`). To avoid confusion, prefer using the long form `--host` for status checks.

### Console Navigation

Once attached to the server console (via `start --console` or `console` command):

- **Type commands** — Type Minecraft commands directly (e.g., `/say Hello`)
- **Exit console** — Press `Ctrl+B` then `D` (detach from tmux session)
- **Stop server** — Type `stop` command in console
- **See logs** — Use `Ctrl+B` then `[` to scroll through logs

---

## ⚙️ Configuration

The runtime controller is `src/script/mcslctl.sh`.
It loads configuration from `cfg/mcslctl.conf` and `cfg/mcslctl-notify.conf`, generating both files if missing on first start.

Default config values:

```ini
StartCommand=run.sh
CrashHandle=true
MaxRestart=3
LogMode=separate
```

- `StartCommand` — startup script or command used to launch the Minecraft server
- `CrashHandle` — `true` to restart automatically after a crash; `false` to stop instead
- `MaxRestart` — maximum crash restart attempts before stopping (use `-1` for unlimited retries)
- `LogMode` — `separate` for split logs, `combined` to write all messages into a single log.

---

## 🎮 How Each Command Works

### `start` — Launch the Server

1. Creates a `tmux` session (named after your server directory)
2. Spawns `mcslctl.sh` inside the session
3. `mcslctl.sh` reads `cfg/mcslctl.conf` (and `cfg/mcslctl-notify.conf`)
4. Executes the `StartCommand` (default: `run.sh`)
5. Monitors the process continuously:
   - If it crashes, auto-restarts (based on `CrashHandle` setting)
   - If max crashes reached, stops gracefully
   - Logs all events with timestamps

**Use `--console` to immediately attach to the server after starting.**

### `stop` — Shut Down Gracefully

1. Sends an in-game warning message
2. Waits for the specified delay (default: 0 seconds)
3. Sends the `stop` command to the server
4. Monitors until the server process exits
5. Cleans up the `tmux` session

**Use `--time 60` to give players 60 seconds to save and log off.**

### `restart` — Reboot the Server

Combines `stop` and `start`:
1. Stops the server gracefully
2. Waits for the session to terminate
3. Starts a new server instance

**Best used during maintenance windows.**

### `console` — Attach to Running Server

Directly connects you to the `tmux` session running your server.

**Useful for:**
- Running commands in-game (`/say`, `/time`, etc.)
- Monitoring server behavior
- Reading real-time logs

### `status` — Check Server Online Status

Performs a TCP connection test to the configured host:port.

**For localhost:** Reads `server.properties` to detect the actual port.
**For remote servers:** Use `--host <ip> --port <port>`.

### `selfupdate` — Update MCSL

Pulls the latest version from the Git repository:
1. Runs `git restore -- .` (resets local changes)
2. Runs `git pull` (fetches latest version)
3. MCSL is ready to use immediately

**Warning:** This resets any local modifications. Back up your config first if needed.

---

## 🧠 Behavior Notes

- `start` launches `src/script/mcslctl.sh` inside a detached `tmux` session.
- If the session already exists, `start` logs a warning and does not create a duplicate.
- `stop` sends an in-game warning before issuing the `stop` command, honoring the configured delay.
- `restart` stops the server, waits for the `tmux` session to terminate, then starts it again.
- `status` checks TCP connectivity; for `localhost`, it reads `server.properties` to detect the actual server port.
- `selfupdate` runs `git restore -- .` and `git pull` inside the MCSL directory.

---

## 📁 Project Structure

- `mcsl.sh` — main CLI entrypoint
- `src/script/mcslctl.sh` — runtime controller loop
- `src/lib/core/` — shared module utilities (`logger`, `config`, `tmux`, etc.)
- `src/lib/commands/` — command handlers (`start`, `stop`, `restart`, `status`, `selfupdate`, `help`, `version`)
- `src/runtime/` — runtime state files such as `restartctl`
- `cfg/` — generated configuration directory
- `logs/` — log files

---

## 🔧 Troubleshooting

### Server won't start

1. **Check logs:**
   ```bash
   tail -f logs/mcslctl_*.log
   ```

2. **Verify `run.sh` exists and is executable:**
   ```bash
   ls -la ../run.sh
   chmod +x ../run.sh
   ```

3. **Test startup script directly:**
   ```bash
   cd ..
   bash run.sh
   ```

### Can't attach to console

Ensure the server is running:
```bash
./mcsl.sh status
```

If not running, start it first:
```bash
./mcsl.sh start
```

### Server keeps restarting

Check your crash handling settings in `cfg/mcslctl.conf`:
```ini
CrashHandle=false    # Disable auto-restart
```

Then check the logs for why it's crashing.

---

## 📜 License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

