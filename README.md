# My Dotfiles

Personal configuration files for macOS, managed with [dotship](https://github.com/8liam/dotship).

## What's included

| File                   | Description                    | Destination                                               |
| ---------------------- | ------------------------------ | --------------------------------------------------------- |
| `ghostty/config`       | Ghostty terminal configuration | `~/.config/ghostty/config`                                |
| `cursor/settings.json` | Cursor IDE settings            | `~/Library/Application Support/Cursor/User/settings.json` |

## Quick install

Make sure you have [Node.js](https://nodejs.org/) v18+ installed, then run:

`npx dotship`

Paste this repo's URL when prompted:
`https://github.com/8liam/dotfiles`

dotship will detect the `.dotship.yml` manifest and offer to install all config files automatically.

## Configuration

If you are forking this repo for use with your own dotfiles,
Add the `.dotship.yml` file for the repo root:

```yml
files:
  ghostty/config: ~/.config/ghostty/config
  cursor/settings.json: ~/Library/Application Support/Cursor/User/settings.json
```

## About dotship

dotship is a TUI for browsing GitHub repos and installing dotfiles. When a repo contains a .dotship.yml manifest, it can batch-install everything in one go.
npm: https://npmjs.com/package/dotship
GitHub: https://github.com/8liam/dotship

## License

MIT
