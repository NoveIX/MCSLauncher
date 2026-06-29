# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2026-06-29

### Added
- Discord and Telegram notifications for server lifecycle events.
- Dedicated notification configuration file.
- Automatic notifications for server start, stop, crash, and crash-limit events.
- A startup failure prompt with a 30-second timeout before the session closes.
- Improved configuration comments and examples in `cfg/mcslctl.conf`.

### Changed
- Clarified help text for the `migrate` and `kill` commands.
- Updated documentation references from `cfg/mcsl-behavior.ini` to `cfg/mcslctl.conf` and `cfg/mcslctl-notify.conf`.
- Improved the crash-limit log message to clearly indicate that the server will not restart.
- Expanded the README with notification setup guidance.

### Fixed
- Fixed case-insensitive validation handling for configuration values.
- Corrected the help example for remote migration command syntax.

### Notes
- Notifications are disabled by default.
- Discord and Telegram notifications require either `curl` or `wget`.

## [2.0.0] - 2026-06-17

### Added
- Main CLI interface via `mcsl.sh`.
- Core commands: `start`, `stop`, `restart`, `console`, `status`, `selfupdate`, `migrate`, `kill`, `help`, and `version`.
- `src/script/mcslctl.sh` runtime controller executed inside `tmux`.
- Automatic crash handling and restart control through `CrashHandle` and `MaxRestart`.
- Automatic generation of the initial configuration and EULA handling.
- `tmux`-based console and command control.
- TCP-based status checks and uptime reporting.
- Multi-server support with the `--all` option.
- Local and remote migration via `rsync` and `ssh`.
- Self-update from Git.
- Structured logging with separate and combined log modes.
- Runtime dependency checks for `tmux`, `git`, `rsync`, `ssh`, and `java`.

### Notes
- Project tested on Ubuntu 24.04 and Debian 13 with WSL2 support on Windows.

## [1.0.0] - Original Release (Archived)

### Deprecated
- This was the original project version, originally known as **MCSM** (Minecraft Server Manager).
- It is no longer maintained and has been superseded by version `2.0.0`.
