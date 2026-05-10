# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="apple"
plugins=(git macos brew)
source $ZSH/oh-my-zsh.sh

# History
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS SHARE_HISTORY

# PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# postgres (skip if not installed)
[[ -d "/opt/homebrew/opt/postgresql@17/bin" ]] && export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

unsetopt AUTO_CD

# eza (modern ls) — falls back to system ls if not installed
if command -v eza &>/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza --icons --group-directories-first -l --git"
  alias la="eza --icons --group-directories-first -la --git"
  alias lt="eza --icons --tree --level=2"
fi

# bat — falls back to cat if not installed
command -v bat &>/dev/null && alias cat="bat"

# fzf
command -v fzf &>/dev/null && eval "$(fzf --zsh)"

# zsh-autosuggestions
BREW_PREFIX="${$(brew --prefix 2>/dev/null):-/opt/homebrew}"
[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting — must be last
[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Welcome message
() {
  local colors=('\033[31m' '\033[32m' '\033[33m' '\033[34m' '\033[35m' '\033[36m' '\033[91m' '\033[92m' '\033[93m' '\033[94m' '\033[95m' '\033[96m')
  local color=${colors[$((RANDOM % ${#colors[@]} + 1))]}
  printf "\n  Welcome, ${color}${USER}\033[0m\n\n"
}

# Setup check — shows install instructions for missing tools, disappears once all installed
() {
  local missing=()
  command -v fzf &>/dev/null            || missing+=("fzf")
  command -v eza &>/dev/null            || missing+=("eza")
  command -v bat &>/dev/null            || missing+=("bat")
  [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]    || missing+=("zsh-autosuggestions")
  [ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] || missing+=("zsh-syntax-highlighting")

  (( ${#missing[@]} == 0 )) && return

  printf "  \033[33mMissing tools:\033[0m ${missing[*]}\n"
  printf "  \033[90mbrew install ${missing[*]}\033[0m\n\n"
}

