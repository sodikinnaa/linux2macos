#!/usr/bin/env bash
# Shared helpers and the list of every setting linux2macos touches.
# Sourced by install.sh and restore.sh.

L2M_STATE="$HOME/.config/linux2macos"
L2M_BACKUP_ROOT="$L2M_STATE/backup"
L2M_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/linux2macos"

THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.local/share/icons"
FONTS_DIR="$HOME/.local/share/fonts"
BG_DIR="$HOME/.local/share/backgrounds"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/.local/share/applications"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"

BASHRC_BEGIN="# >>> linux2macos terminal >>>"
BASHRC_END="# <<< linux2macos terminal <<<"

# Extensions installed from extensions.gnome.org.
EXTENSIONS=(
  "user-theme@gnome-shell-extensions.gcampax.github.com"
  "blur-my-shell@aunetx"
  "compiz-alike-magic-lamp-effect@hermes83.github.com"
  "logomenu@aryan_k"
  "just-perfection-desktop@just-perfection"
)

# Single dconf keys changed by install.sh. restore.sh resets these first,
# then loads the backup, so keys that were at their default come back too.
DCONF_KEYS=(
  /org/gnome/desktop/interface/gtk-theme
  /org/gnome/desktop/interface/icon-theme
  /org/gnome/desktop/interface/cursor-theme
  /org/gnome/desktop/interface/color-scheme
  /org/gnome/desktop/interface/font-name
  /org/gnome/desktop/interface/document-font-name
  /org/gnome/desktop/interface/font-antialiasing
  /org/gnome/desktop/interface/font-hinting
  /org/gnome/desktop/interface/clock-show-weekday
  /org/gnome/desktop/interface/enable-animations
  /org/gnome/desktop/wm/preferences/button-layout
  /org/gnome/desktop/wm/preferences/titlebar-font
  /org/gnome/desktop/background/picture-uri
  /org/gnome/desktop/background/picture-uri-dark
  /org/gnome/desktop/screensaver/picture-uri
  /org/gnome/mutter/center-new-windows
  /org/gnome/shell/enabled-extensions
  /org/gnome/shell/disable-user-extensions
  /org/gnome/shell/extensions/ding/show-home
)

# Whole dconf directories owned by linux2macos (reset recursively on restore).
DCONF_DIRS=(
  /org/gnome/shell/extensions/dash-to-dock/
  /org/gnome/shell/extensions/user-theme/
  /org/gnome/shell/extensions/blur-my-shell/
  /org/gnome/shell/extensions/ncom/github/hermes83/compiz-alike-magic-lamp-effect/
  /org/gnome/shell/extensions/Logo-menu/
  /org/gnome/shell/extensions/just-perfection/
)

c_info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
c_ok()    { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
c_warn()  { printf '\033[1;33m !!\033[0m %s\n' "$*" >&2; }
c_die()   { printf '\033[1;31merr\033[0m %s\n' "$*" >&2; exit 1; }

need() {
  local missing=()
  for c in "$@"; do command -v "$c" >/dev/null || missing+=("$c"); done
  ((${#missing[@]} == 0)) || c_die "Perintah belum terpasang: ${missing[*]} (sudo apt install ${missing[*]})"
}

# Major GNOME Shell version, e.g. 46.
shell_version() { gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1; }

# UUID of the default GNOME Terminal profile (empty if GNOME Terminal is absent).
terminal_profile() {
  gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'"
}

# Add (or remove with -r) extension UUIDs in org.gnome.shell enabled-extensions,
# keeping whatever else the user has enabled.
extensions_set() {
  local mode=add
  [[ ${1:-} == -r ]] && { mode=remove; shift; }
  local cur
  cur=$(gsettings get org.gnome.shell enabled-extensions)
  local new
  new=$(python3 -I - "$mode" "$cur" "$@" <<'EOF'
import ast, sys
mode, cur, uuids = sys.argv[1], sys.argv[2], sys.argv[3:]
cur = cur.replace("@as ", "")
items = list(ast.literal_eval(cur)) if cur.strip() else []
if mode == "add":
    items += [u for u in uuids if u not in items]
else:
    items = [i for i in items if i not in uuids]
print("[" + ", ".join(repr(i) for i in items) + "]")
EOF
)
  gsettings set org.gnome.shell enabled-extensions "$new"
}
