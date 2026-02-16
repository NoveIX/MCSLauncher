# Minecraft Script Launcher (MCSL)

[![Bash](https://img.shields.io/badge/Bash-4%2B-brightgreen?style=for-the-badge)](https://www.gnu.org/software/bash/) [![tmux](https://img.shields.io/badge/tmux-required-blue?style=for-the-badge)](https://github.com/tmux/tmux) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)

---

## 📝 Description

**MCSL** is a lightweight runtime Bash script for managing a Minecraft server using [tmux](https://github.com/tmux/tmux). It provides simple commands to start, stop, restart, and access the server console, with built-in EULA handling and session management.

---

## ✨ Features

- Start, stop, and restart your Minecraft server with simple commands
- Open the server console in an interactive tmux session
- Automatic EULA file creation and an interactive acceptance prompt
- Session management to prevent duplicate or missing tmux sessions
- Colorful, informative terminal output
- Beginner-friendly usage and help menu

---

## ⚙️ Requirements

- **Bash** (version 4.4 or higher recommended)
- **tmux** (must be installed and available in your PATH)
- **sed**, **grep**, **realpath** (standard on most Unix-like systems)
- Minecraft server files (for example `run.sh` and `eula.txt`)

> **Note**: This script is designed for Unix-like environments (Linux, macOS, WSL). It will not run natively on Windows unless you provide a compatible environment such as WSL, Cygwin, MSYS2 or a Linux-like shell with tmux available.

---

## 🚀 Installation

1. **Install [tmux](https://github.com/tmux/tmux):**

	- On Ubuntu/Debian: `sudo apt-get install tmux`
	- On CentOS/Fedora: `sudo dnf install tmux`
	- On macOS (Homebrew): `brew install tmux`

2. **Clone or download this repository:**

	```bash
	git clone https://github.com/NoveIX/mcsl.git
	cd mcsl
	```

3. **Make the script executable:**

	```bash
	chmod +x mcsl.sh
	```

4. **One-line (all-in-one) alternative:**

	```bash
	git clone https://github.com/NoveIX/mcsl.git && cd mcsl && chmod +x mcsl.sh
	```

5. **Place your Minecraft server files** (for example `config/`, `mods/`, `kubejs/`, `world/`, `run.sh`, `eula.txt`, `user_jvm_args.txt`) in the modpack root alongside the `mcsl/` directory (see example below).

6. **Example directory layout:**

	```text
	modpack/
	├── libraries/
	├── mcsl/
	│   ├── LICENSE
	│   ├── mcsl.sh        	<- Main entry
	│   ├── README.md
	│   ├── source/
	│   └── VERSION
	├── neoforge-21.1.208-installer.jar
	├── neoforge-21.1.208-installer.jar.log
	├── run.bat
	├── run.sh            	<- Minecraft server start script
	└── user_jvm_args.txt
	```

---

## 📦 Usage

Run the script with one of the following commands:

```bash
./mcsl.sh [option]
```

| Option            | Description                                             |
|-------------------|---------------------------------------------------------|
| `-s`, `--start`   | Launch the server.                                      |
| `-e`, `--exit`    | Stop the server gracefully with an in-game warning.     |
| `-r`, `--restart` | Restart the server gracefully with an in-game warning.  |
| `-c`, `--console` | Attach to the server console (tmux session).            |
| `-n`, `--now`     | Stop or restart the server immediately without warning. |
| `-h`, `--help`    | Show help information.                          		  |
| `--mcsl-update`   | Update MCSL from the official Git repository.           |
| `--version`       | Show the currently installed MCSL version.              |

---

## 📄 EULA Handling

On first run, if `eula.txt` does not exist the script will create it with `eula=false`. If the EULA is not accepted you will see an interactive prompt similar to:

```
The EULA is not accepted. Do you want to accept it now? [y/N]:
```

Type `y` and press Enter to accept the EULA. The script will update `eula.txt` to `eula=true` and continue. If you do not accept, the server will not start.

---

## 📝 Notes

- **Session naming:** The tmux session name is automatically derived from the modpack or server directory name and is sanitized for safety.
- **tmux required:** All server management is handled via tmux — make sure it is installed and available in your PATH.
- **Server launcher / files location:** By default, server files (for example `config/`, `mods/`, `kubejs/`, `world/`, `run.sh` or `run.bat`, `eula.txt`, `user_jvm_args.txt`) are expected in the modpack root alongside the `mcsl/` directory (see the "Example directory layout" in Installation). The script will call your server launcher (e.g. `run.sh`) — ensure the launcher exists and is executable.
- **Unix shell:** This script is intended for Unix-like shells. On Windows, use WSL, Cygwin, MSYS2 or another compatible environment with tmux available.

---

## 📜 License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

---

## ✒️ Author's note / Signature

This repository started as a personal project to solve a problem at a personal level: making it easy and repeatable to manage Minecraft servers (start, stop, console access, and updates) using lightweight tools such as tmux. It is intended as a practical, field-tested utility rather than an enterprise-grade solution.

Maintainer: NoveIX

Created by NoveIX