#!/usr/bin/env bash
# Undo linux2macos: bring settings back to the state before the first install.
#
#   ./scripts/restore.sh            # restore settings, keep downloaded files
#   ./scripts/restore.sh --purge    # also delete themes, icons, fonts, extensions, tools
#   ./scripts/restore.sh --from DIR # restore from a specific backup folder
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

purge=false
from="$L2M_BACKUP_ROOT/original"
while (($#)); do
  case "$1" in
    --purge) purge=true ;;
    --from) from="$2"; shift ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) c_die "Argumen tidak dikenal: $1" ;;
  esac
  shift
done
from=$(readlink -f "$from" 2>/dev/null || true)
[[ -f $from/dconf.ini ]] || c_die "Backup tidak ditemukan di $from"
c_info "Memulihkan dari $from"

# 1. Settings: reset every key we touch (so keys that were at their default
#    come back), then load the snapshot taken before the first install.
for k in "${DCONF_KEYS[@]}"; do dconf reset "$k"; done
for d in "${DCONF_DIRS[@]}"; do dconf reset -f "$d"; done
P=$(terminal_profile)
[[ -n $P ]] && dconf reset -f "/org/gnome/terminal/legacy/profiles:/:$P/"
dconf load / <"$from/dconf.ini"
c_ok "Pengaturan GNOME dikembalikan"

# 2. GTK4 / libadwaita links.
for f in gtk.css gtk-dark.css assets windows-assets; do
  [[ -L $HOME/.config/gtk-4.0/$f ]] && rm -f "$HOME/.config/gtk-4.0/$f"
done
[[ -d $from/gtk-4.0 ]] && cp -an "$from/gtk-4.0/." "$HOME/.config/gtk-4.0/"
c_ok "Tema GTK4 dilepas"

# Generic font families (sans-serif, monospace) back to the system defaults.
if [[ -f $FONTCONFIG_FILE ]]; then
  rm -f "$FONTCONFIG_FILE"
  fc-cache -f >/dev/null
  c_ok "Alias font fontconfig dihapus"
fi

# 3. ~/.bashrc: drop only our block, so later edits by the user survive.
if grep -qF "$BASHRC_BEGIN" "$HOME/.bashrc" 2>/dev/null; then
  sed -i "/^$BASHRC_BEGIN\$/,/^$BASHRC_END\$/d" "$HOME/.bashrc"
  c_ok "Blok Starship/fastfetch dihapus dari ~/.bashrc"
fi

# 4. App launcher icon overrides.
n=0
for f in "$APPS_DIR"/*.desktop; do
  [[ -f $f ]] && grep -q '^X-Linux2macos-Original-Icon=' "$f" || continue
  b="$L2M_BACKUP_ROOT/applications/$(basename "$f")"
  if [[ -f $b ]]; then cp -p "$b" "$f"; else rm -f "$f"; fi
  n=$((n + 1))
done
update-desktop-database "$APPS_DIR" 2>/dev/null || true
c_ok "$n ikon aplikasi dikembalikan"

# 5. Browsers.
if [[ -d $L2M_BACKUP_ROOT/browser-prefs ]]; then
  "$HERE/browser-gtk.sh" --undo || true
fi

if $purge; then
  c_info "Menghapus file yang dipasang"
  for u in "${EXTENSIONS[@]}"; do
    gnome-extensions uninstall "$u" 2>/dev/null || rm -rf "${EXT_DIR:?}/$u"
  done
  rm -rf "$THEMES_DIR"/WhiteSur-{Dark,Light} \
         "$ICONS_DIR"/WhiteSur{,-dark,-cursors} "$ICONS_DIR/linux2macos" \
         "$BG_DIR"/WhiteSur{,-dark,-light,-morning}.jpg \
         "$FONTS_DIR/Inter" "$FONTS_DIR/JetBrainsMonoNerd" \
         "$L2M_CACHE"
  for b in starship fastfetch; do
    [[ -x $BIN_DIR/$b ]] && rm -f "$BIN_DIR/$b"
  done
  fc-cache -f >/dev/null
  c_ok "File tema, ikon, font, ekstensi, starship & fastfetch dihapus"
  c_warn "~/.config/starship.toml dan folder backup dibiarkan"
fi

echo
c_info "Selesai. Tekan Alt+F2 → r (X11) atau log out/login (Wayland)."
