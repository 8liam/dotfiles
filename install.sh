#!/usr/bin/env bash

# Interactive installer driven by a manifest that maps repo paths to destinations.
# Manifest format (install-map.txt by default):
#   relative/source/path -> /absolute/destination/path
# Lines starting with # are ignored. Tilde (~) expands to $HOME.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST_FILE="${MANIFEST_FILE:-${SCRIPT_DIR}/install-map.txt}"

GREEN="$(printf '\033[32m')"
YELLOW="$(printf '\033[33m')"
RED="$(printf '\033[31m')"
BLUE="$(printf '\033[34m')"
RESET="$(printf '\033[0m')"

ENTRIES_SRC=()
ENTRIES_DEST=()
STATUS_LINES=()

trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "$var"
}

log_info() { echo "${BLUE}[INFO]${RESET} $*"; }
log_warn() { echo "${YELLOW}[WARN]${RESET} $*"; }
log_error() { echo "${RED}[ERROR]${RESET} $*"; }
log_success() { echo "${GREEN}[DONE]${RESET} $*"; }

print_banner() {
cat <<'EOF'
      d8b                    ,d8888b  d8, d8b                
      88P            d8P     88P'    `8P  88P                
     d88          d888888Pd888888P       d88                 
 d888888   d8888b   ?88'    ?88'      88b888   d8888b .d888b,
d8P' ?88  d8P' ?88  88P     88P       88P?88  d8b_,dP ?8b,   
88b  ,88b 88b  d88  88b    d88       d88  88b 88b       `?8b 
`?88P'`88b`?8888P'  `?8b  d88'      d88'   88b`?888P'`?888P' 
                                                             
EOF
}

add_status() {
  local line
  while IFS= read -r line; do
    STATUS_LINES+=("$line")
  done <<<"$1"
  # keep last 8 lines
  if [ "${#STATUS_LINES[@]}" -gt 8 ]; then
    STATUS_LINES=("${STATUS_LINES[@]: -8}")
  fi
}

copy_entry() {
  local src_rel="$1"
  local dest_abs="$2"
  local src_path="${SCRIPT_DIR}/${src_rel}"
  local expanded_dest="${dest_abs/#\~/${HOME}}"
  local dest_dir

  if [ ! -e "${src_path}" ]; then
    echo "$(log_error "Source not found: ${src_rel}")"
    return 1
  fi

  dest_dir="$(dirname "${expanded_dest}")"
  mkdir -p "${dest_dir}"

  cp -R "${src_path}" "${expanded_dest}"
  echo "$(log_success "${src_rel} -> ${expanded_dest}")"
}

parse_manifest() {
  local line src_raw dest_raw src dest
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      \#*|"") continue ;;
    esac
    if [[ "$line" == *"->"* ]]; then
      src_raw="${line%%->*}"
      dest_raw="${line#*->}"
    else
      set -- $line
      src_raw="$1"
      dest_raw="$2"
    fi
    src="$(trim "$src_raw")"
    dest="$(trim "$dest_raw")"
    if [ -z "$src" ] || [ -z "$dest" ]; then
      add_status "$(log_warn "Skipping malformed line: $line")"
      continue
    fi
    ENTRIES_SRC+=("$src")
    ENTRIES_DEST+=("$dest")
  done < "$MANIFEST_FILE"
}

draw_menu() {
  local selected="$1"
  clear
  print_banner
  echo
  echo "Manifest: ${MANIFEST_FILE}"
  echo "Use ↑/↓ to select, Enter to install, a = install all, q = quit"
  echo
  local idx
  for idx in "${!ENTRIES_SRC[@]}"; do
    if [ "$idx" -eq "$selected" ]; then
      printf "  > %s %s -> %s %s\n" "$(tput rev)" "${ENTRIES_SRC[$idx]}" "${ENTRIES_DEST[$idx]}" "$(tput sgr0)"
    else
      printf "    %s -> %s\n" "${ENTRIES_SRC[$idx]}" "${ENTRIES_DEST[$idx]}"
    fi
  done
  echo
  echo "Messages (latest first):"
  for ((i=${#STATUS_LINES[@]}-1; i>=0; i--)); do
    echo "  ${STATUS_LINES[$i]}"
  done
}

install_one() {
  local idx="$1"
  add_status "$(copy_entry "${ENTRIES_SRC[$idx]}" "${ENTRIES_DEST[$idx]}")"
}

install_all() {
  local i
  for i in "${!ENTRIES_SRC[@]}"; do
    add_status "$(copy_entry "${ENTRIES_SRC[$i]}" "${ENTRIES_DEST[$i]}")"
  done
}

interactive_menu() {
  local selected=0 key
  tput civis
  trap 'tput cnorm; stty sane; clear' EXIT
  stty -echo -icanon time 0 min 1

  while true; do
    draw_menu "$selected"
    read -rsn1 key
    case "$key" in
      "") install_one "$selected" ;;
      q|Q) break ;;
      a|A) install_all ;;
      $'\x1b')
        read -rsn2 key
        case "$key" in
          "[A") [ "$selected" -gt 0 ] && selected=$((selected-1)) ;;
          "[B") [ "$selected" -lt $((${#ENTRIES_SRC[@]}-1)) ] && selected=$((selected+1)) ;;
        esac
        ;;
    esac
  done
}

main() {
  if [ ! -f "$MANIFEST_FILE" ]; then
    log_error "Manifest file not found."
    exit 1
  fi

  parse_manifest
  if [ "${#ENTRIES_SRC[@]}" -eq 0 ]; then
    log_error "No entries found in manifest."
    exit 1
  fi

  interactive_menu
}

main "$@"