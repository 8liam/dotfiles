# My Dotfiles

Personal configuration files for macOS and Linux, managed with [dotship](https://github.com/8liam/dotship).

## What's included

### macOS

| File                          | Description                    | Destination                                               |
| ------------------------------ | ------------------------------ | --------------------------------------------------------- |
| `macos/ghostty/config`         | Ghostty terminal configuration | `~/.config/ghostty/config`                                |
| `macos/cursor/settings.json`   | Cursor IDE settings            | `~/Library/Application Support/Cursor/User/settings.json` |
| `macos/glance/glance.yml`      | Glance dashboard config        | `~/glance/config/glance.yml`                              |
| `macos/glance/glance.sh`       | Run/restart Glance in a container | `~/glance/glance.sh`                                   |
| `macos/glance/com.liam.glance.plist` | Start Glance at login (LaunchAgent) | `~/Library/LaunchAgents/com.liam.glance.plist`   |

#### Glance on macOS (Apple container)

Glance runs in an [Apple container](https://github.com/apple/container) (Apple silicon, macOS 26+). After installing the files with dotship:

```sh
brew install container
sh ~/glance/glance.sh                  # starts the container service, pulls and runs Glance on :8080
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.liam.glance.plist   # start at login
```

Glance is published on `127.0.0.1` only, so put a reverse proxy (e.g. Caddy) in front of it for tailnet access; set `GLANCE_BIND=0.0.0.0` to expose the port directly. Glance only reads `glance.yml` on startup, so after editing it run `sh ~/glance/glance.sh restart`. Changing the port or bind address needs `sh ~/glance/glance.sh recreate`. Apple's runtime has no restart policy, which is why the LaunchAgent exists.

### Linux (CachyOS + Hyprland)

| File                                | Description                          | Destination                        |
| ------------------------------------ | ------------------------------------- | ----------------------------------- |
| `linux/hypr/hyprland.lua`            | Hyprland config (Hyprlua)             | `~/.config/hypr/hyprland.lua`       |
| `linux/hypr/hyprlock.conf`           | Lock screen                          | `~/.config/hypr/hyprlock.conf`      |
| `linux/hypr/hypridle.conf`           | Idle/lock/suspend timers             | `~/.config/hypr/hypridle.conf`      |
| `linux/hypr/hyprpaper.conf`          | Wallpaper                            | `~/.config/hypr/hyprpaper.conf`     |
| `linux/waybar/*`                     | Status bar config + styling          | `~/.config/waybar/*`                |
| `linux/fuzzel/fuzzel.ini`            | App launcher                         | `~/.config/fuzzel/fuzzel.ini`       |
| `linux/mako/config`                  | Notification daemon                  | `~/.config/mako/config`             |
| `linux/wlogout/*`                    | Logout menu                          | `~/.config/wlogout/*`               |
| `linux/fastfetch/config.jsonc`       | System info fetch theming            | `~/.config/fastfetch/config.jsonc`  |

## Quick install

Make sure you have [Node.js](https://nodejs.org/) v18+ installed, then run:

`npx dotship`

Paste this repo's URL when prompted:
`https://github.com/8liam/dotfiles`

dotship will detect the `.dotship.yml` manifest and offer to install all config files automatically.

## Configuration

If you are forking this repo for use with your own dotfiles,
add a `.dotship.yml` file to the repo root. Example:

```yml
files:
  macos/ghostty/config: ~/.config/ghostty/config
  linux/hypr/hyprland.lua: ~/.config/hypr/hyprland.lua
```

## About dotship

dotship is a TUI for browsing GitHub repos and installing dotfiles. When a repo contains a .dotship.yml manifest, it can batch-install everything in one go.
npm: https://npmjs.com/package/dotship
GitHub: https://github.com/8liam/dotship

## License

MIT
