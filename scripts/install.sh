#!/usr/bin/env bash
# linux2macos — make Ubuntu GNOME look and feel like macOS.
# Installs everything into the user's home directory; no sudo needed.
#
#   ./scripts/install.sh              # everything
#   ./scripts/install.sh theme dock   # only some modules
#   ./scripts/install.sh --list       # show modules
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

ALL_MODULES=(backup theme icons cursors wallpaper fonts dock extensions window app-icons terminal browser)

usage() {
  cat <<EOF
Pemakaian: $0 [modul ...]

Tanpa argumen semua modul dijalankan berurutan. Modul yang tersedia:
  backup      simpan pengaturan saat ini (selalu dijalankan otomatis)
  theme       tema GTK & GNOME Shell WhiteSur (gelap)
  icons       ikon WhiteSur
  cursors     kursor WhiteSur
  wallpaper   wallpaper WhiteSur (terang/gelap otomatis)
  fonts       font Inter (mirip SF Pro) + JetBrainsMono Nerd Font
  dock        dock bawah-tengah, auto-hide, titik indikator
  extensions  User Themes, Blur my Shell, Magic Lamp, Logo Menu, Just Perfection
  window      tombol jendela di kiri, jendela baru di tengah
  app-icons   seragamkan ikon aplikasi snap/AppImage ke WhiteSur
  terminal    warna terminal, prompt Starship, fastfetch
  browser     Chrome/Brave pakai tema GTK (browser harus ditutup)
EOF
}

# ---------------------------------------------------------------- helpers ---

fetch() { # url dest
  curl -fsSL --retry 3 -o "$2" "$1"
}

clone() { # repo-name -> path in cache
  local repo="$1" dst="$L2M_CACHE/src/$1"
  if [[ -d $dst/.git ]]; then
    git -C "$dst" pull -q --ff-only || true
  else
    mkdir -p "$L2M_CACHE/src"
    git clone -q --depth 1 "https://github.com/vinceliuice/$repo.git" "$dst"
  fi
  echo "$dst"
}

gh_latest_asset() { # owner/repo regex
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" |
    python3 -I -c 'import sys,json,re;a=[x["browser_download_url"] for x in json.load(sys.stdin)["assets"] if re.search(sys.argv[1],x["name"])];print(a[0] if a else "")' "$2"
}

# ---------------------------------------------------------------- modules ---

m_backup() {
  local dir="$L2M_BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$dir"
  dconf dump / >"$dir/dconf.ini"
  [[ -f $HOME/.bashrc ]] && cp -p "$HOME/.bashrc" "$dir/bashrc"
  if [[ -d $HOME/.config/gtk-4.0 ]]; then cp -a "$HOME/.config/gtk-4.0" "$dir/gtk-4.0"; fi
  ln -sfn "$dir" "$L2M_BACKUP_ROOT/latest"
  # The first backup is the true "before" state; never overwrite it.
  [[ -e $L2M_BACKUP_ROOT/original ]] || ln -sfn "$dir" "$L2M_BACKUP_ROOT/original"
  c_ok "Backup disimpan di $dir"
}

m_theme() {
  local src; src=$(clone WhiteSur-gtk-theme)
  mkdir -p "$THEMES_DIR"
  for v in Dark Light; do
    rm -rf "$THEMES_DIR/WhiteSur-$v"
    tar -xJf "$src/release/WhiteSur-$v.tar.xz" -C "$THEMES_DIR"
  done
  # libadwaita (GTK4) apps only follow a theme through ~/.config/gtk-4.0.
  mkdir -p "$HOME/.config/gtk-4.0"
  for f in gtk.css gtk-dark.css assets; do
    ln -sfn "$THEMES_DIR/WhiteSur-Dark/gtk-4.0/$f" "$HOME/.config/gtk-4.0/$f"
  done
  gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  dconf write /org/gnome/shell/extensions/user-theme/name "'WhiteSur-Dark'"
  c_ok "Tema WhiteSur-Dark terpasang"
}

# Mirrors the install() function of WhiteSur-icon-theme/install.sh for the
# default and -dark variants, so it works without running upstream scripts.
m_icons() {
  local SRC; SRC=$(clone WhiteSur-icon-theme)
  local B="$ICONS_DIR/WhiteSur" K="$ICONS_DIR/WhiteSur-dark"
  mkdir -p "$ICONS_DIR"
  rm -rf "$B" "$K"

  mkdir -p "$B/status"
  cp "$SRC/src/index.theme" "$B/"
  cp -r "$SRC"/src/{actions,animations,apps,categories,devices,emotes,emblems,mimes,places,preferences} "$B"
  cp -r "$SRC"/src/status/{16,22,24,32,symbolic} "$B/status"
  rm -f "$B"/places/scalable/user-trash{,-full}-dark.svg
  cp -r "$SRC"/links/{actions,apps,categories,devices,emotes,emblems,mimes,places,status,preferences} "$B"

  mkdir -p "$K"/{apps,categories,emblems,devices,mimes,places,status}
  cp "$SRC/src/index.theme" "$K/"
  sed -i "s/WhiteSur/WhiteSur-dark/g" "$K/index.theme"
  cp -r "$SRC/src/actions" "$K"
  cp -r "$SRC"/src/apps/{16,22,32,symbolic} "$K/apps"
  cp -r "$SRC"/src/categories/{22,symbolic} "$K/categories"
  cp -r "$SRC/src/emblems/symbolic" "$K/emblems"
  cp -r "$SRC/src/mimes/symbolic" "$K/mimes"
  cp -r "$SRC"/src/devices/{16,22,24,32,symbolic} "$K/devices"
  cp -r "$SRC"/src/places/{16,22,24,scalable,symbolic} "$K/places"
  cp -r "$SRC/src/status/symbolic" "$K/status"
  mv -f "$K/places/scalable/user-trash-dark.svg" "$K/places/scalable/user-trash.svg"
  mv -f "$K/places/scalable/user-trash-full-dark.svg" "$K/places/scalable/user-trash-full.svg"
  # Thousands of files: use find instead of a glob to stay under ARG_MAX.
  find "$K"/{actions,devices,places}/{16,22,24} "$K"/apps/{16,22,32} "$K"/categories/22 \
       "$K"/{actions,devices}/32 "$K"/{actions,apps,categories,emblems,devices,mimes,places,status}/symbolic \
       -maxdepth 1 -type f -name '*.svg' -exec sed -i "s/#363636/#dedede/g" {} +
  cp -r "$SRC"/links/actions/{16,22,24,32,symbolic} "$K/actions"
  cp -r "$SRC"/links/devices/{16,22,24,32,symbolic} "$K/devices"
  cp -r "$SRC"/links/places/{16,22,24,scalable,symbolic} "$K/places"
  cp -r "$SRC"/links/apps/{16,22,32,symbolic} "$K/apps"
  cp -r "$SRC"/links/categories/{22,symbolic} "$K/categories"
  cp -r "$SRC/links/emblems/symbolic" "$K/emblems"
  cp -r "$SRC/links/mimes/symbolic" "$K/mimes"
  cp -r "$SRC/links/status/symbolic" "$K/status"
  (
    cd "$ICONS_DIR"
    for d in animations emotes preferences; do ln -s "../WhiteSur/$d" "WhiteSur-dark/$d"; done
    for p in categories/32 emblems/16 emblems/22 emblems/24 mimes/16 mimes/22 mimes/scalable \
             apps/scalable devices/scalable status/16 status/22 status/24 status/32; do
      ln -s "../../WhiteSur/$p" "WhiteSur-dark/$p"
    done
  )
  for t in "$B" "$K"; do
    (cd "$t" && for x in actions animations apps categories devices emotes emblems mimes places preferences status; do ln -sf "$x" "$x@2x"; done)
    gtk-update-icon-cache -q "$t" 2>/dev/null || true
  done
  gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
  c_ok "Ikon WhiteSur terpasang"
}

m_cursors() {
  local src; src=$(clone WhiteSur-cursors)
  rm -rf "$ICONS_DIR/WhiteSur-cursors"
  mkdir -p "$ICONS_DIR/WhiteSur-cursors"
  cp -r "$src"/dist/* "$ICONS_DIR/WhiteSur-cursors/"
  gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
  c_ok "Kursor WhiteSur terpasang"
}

m_wallpaper() {
  local src; src=$(clone WhiteSur-wallpapers)
  local res=1080p
  local w; w=$(xrandr --current 2>/dev/null | grep -oE 'current [0-9]+' | grep -oE '[0-9]+' || echo 1920)
  ((w > 1920)) && res=2k
  ((w > 2560)) && res=4k
  mkdir -p "$BG_DIR"
  cp "$src/$res"/WhiteSur*.jpg "$BG_DIR/"
  gsettings set org.gnome.desktop.background picture-uri "file://$BG_DIR/WhiteSur-light.jpg"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$BG_DIR/WhiteSur-dark.jpg"
  gsettings set org.gnome.desktop.screensaver picture-uri "file://$BG_DIR/WhiteSur-dark.jpg"
  c_ok "Wallpaper ($res) terpasang"
}

m_fonts() {
  local tmp; tmp=$(mktemp -d)
  mkdir -p "$FONTS_DIR/Inter" "$FONTS_DIR/JetBrainsMonoNerd"
  if ! fc-list : family | grep -q '^Inter'; then
    fetch "$(gh_latest_asset rsms/inter '^Inter-.*\.zip$')" "$tmp/inter.zip"
    unzip -oq "$tmp/inter.zip" -d "$tmp/inter"
    find "$tmp/inter" -name 'Inter*.ttf' -exec cp {} "$FONTS_DIR/Inter/" \;
  fi
  if ! fc-list : family | grep -q 'JetBrainsMono Nerd Font Mono'; then
    fetch https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip "$tmp/jbm.zip"
    unzip -oq "$tmp/jbm.zip" -d "$FONTS_DIR/JetBrainsMonoNerd"
  fi
  rm -rf "$tmp"
  fc-cache -f >/dev/null
  local I=org.gnome.desktop.interface
  gsettings set $I font-name 'Inter 10.5'
  gsettings set $I document-font-name 'Inter 10.5'
  gsettings set $I font-antialiasing 'grayscale'
  gsettings set $I font-hinting 'slight'
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Semi-Bold 10.5'
  c_ok "Font Inter & JetBrainsMono Nerd Font terpasang"
}

m_dock() {
  local D=org.gnome.shell.extensions.dash-to-dock
  if ! gsettings list-schemas | grep -qx $D; then
    c_warn "Dock (ubuntu-dock / dash-to-dock) tidak ditemukan, modul dock dilewati"
    return
  fi
  gsettings set $D dock-position 'BOTTOM'
  gsettings set $D extend-height false
  gsettings set $D dock-fixed false
  gsettings set $D autohide true
  gsettings set $D intellihide true
  gsettings set $D dash-max-icon-size 44
  gsettings set $D transparency-mode 'FIXED'
  gsettings set $D background-opacity 0.35
  gsettings set $D show-trash false
  gsettings set $D show-mounts false
  gsettings set $D click-action 'minimize-or-previews'
  gsettings set $D custom-theme-shrink true
  gsettings set $D running-indicator-style 'DOTS'
  gsettings set $D show-apps-at-top true
  gsettings set org.gnome.shell.extensions.ding show-home false 2>/dev/null || true
  c_ok "Dock diatur ala macOS"
}

m_extensions() {
  local sv; sv=$(shell_version)
  [[ -n $sv ]] || c_die "GNOME Shell tidak terdeteksi"
  local tmp; tmp=$(mktemp -d)
  for u in "${EXTENSIONS[@]}"; do
    local dl
    dl=$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$u&shell_version=$sv" |
      python3 -I -c 'import sys,json;print(json.load(sys.stdin).get("download_url",""))' || true)
    if [[ -z $dl ]]; then c_warn "$u belum mendukung GNOME $sv, dilewati"; continue; fi
    fetch "https://extensions.gnome.org$dl" "$tmp/$u.zip"
    gnome-extensions install --force "$tmp/$u.zip"
    c_ok "Ekstensi $u"
  done
  rm -rf "$tmp"

  # Blur: static (cheap) on panel and dock, none on app windows.
  local B=/org/gnome/shell/extensions/blur-my-shell
  dconf write $B/sigma 25
  dconf write $B/panel/blur true;        dconf write $B/panel/static-blur true
  dconf write $B/dash-to-dock/blur true; dconf write $B/dash-to-dock/static-blur true
  dconf write $B/overview/blur true
  dconf write $B/appfolder/blur true
  dconf write $B/applications/blur false
  dconf write $B/screenshot/blur false
  dconf write $B/window-list/blur false

  # Magic Lamp minimize effect (the schema path really starts with "ncom").
  local M=/org/gnome/shell/extensions/ncom/github/hermes83/compiz-alike-magic-lamp-effect
  dconf write $M/duration 300.0
  dconf write $M/x-tiles 8.0
  dconf write $M/y-tiles 8.0

  # Apple-style menu in the top-left corner; the logo comes from WhiteSur's shell assets.
  local gtk; gtk=$(clone WhiteSur-gtk-theme)
  mkdir -p "$ICONS_DIR/linux2macos"
  cp "$gtk/src/assets/gnome-shell/activities/activities-apple.svg" "$ICONS_DIR/linux2macos/apple-logo.svg"
  local L=/org/gnome/shell/extensions/Logo-menu
  dconf write $L/use-custom-icon true
  dconf write $L/custom-icon-path "'$ICONS_DIR/linux2macos/apple-logo.svg'"
  dconf write $L/menu-button-icon-size 20
  dconf write $L/show-activities-button false
  dconf write $L/show-power-options true
  dconf write $L/show-lockscreen true
  dconf write $L/menu-button-terminal "'gnome-terminal'"

  # Clock on the right, no Activities button, boot straight to the desktop.
  local J=/org/gnome/shell/extensions/just-perfection
  dconf write $J/activities-button false
  dconf write $J/clock-menu-position 1
  dconf write $J/clock-menu-position-offset 20
  dconf write $J/startup-status 0
  dconf write $J/workspace-popup false

  gsettings set org.gnome.shell disable-user-extensions false
  gsettings set org.gnome.desktop.interface enable-animations true
  gsettings set org.gnome.desktop.interface clock-show-weekday true
  extensions_set "${EXTENSIONS[@]}"
  c_ok "Ekstensi diatur (aktif setelah Alt+F2 → r di X11, atau log out/login)"
}

m_window() {
  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
  gsettings set org.gnome.mutter center-new-windows true
  c_ok "Tombol jendela di kiri, jendela baru di tengah"
}

m_app-icons() {
  python3 -I "$HERE/lib/fix-app-icons.py"
  update-desktop-database "$APPS_DIR" 2>/dev/null || true
}

m_terminal() {
  mkdir -p "$BIN_DIR"
  local tmp; tmp=$(mktemp -d)
  if ! command -v starship >/dev/null && [[ ! -x $BIN_DIR/starship ]]; then
    fetch https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz "$tmp/s.tgz"
    tar -xzf "$tmp/s.tgz" -C "$BIN_DIR"
  fi
  if ! command -v fastfetch >/dev/null && [[ ! -x $BIN_DIR/fastfetch ]]; then
    fetch https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.tar.gz "$tmp/f.tgz"
    tar -xzf "$tmp/f.tgz" -C "$tmp"
    cp "$tmp"/fastfetch-linux-amd64/usr/bin/fastfetch "$BIN_DIR/"
  fi
  rm -rf "$tmp"
  [[ -f $HOME/.config/starship.toml ]] || "$BIN_DIR/starship" preset pastel-powerline -o "$HOME/.config/starship.toml" 2>/dev/null ||
    starship preset pastel-powerline -o "$HOME/.config/starship.toml"

  if ! grep -qF "$BASHRC_BEGIN" "$HOME/.bashrc" 2>/dev/null; then
    cat >>"$HOME/.bashrc" <<EOF

$BASHRC_BEGIN
if [[ \$- == *i* ]]; then
  command -v fastfetch >/dev/null && fastfetch
  command -v starship >/dev/null && eval "\$(starship init bash)"
fi
$BASHRC_END
EOF
  fi

  local P; P=$(terminal_profile)
  if [[ -n $P ]]; then
    local K="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$P/"
    gsettings set "$K" use-system-font false
    gsettings set "$K" font 'JetBrainsMono Nerd Font Mono 12'
    gsettings set "$K" use-theme-colors false
    gsettings set "$K" background-color '#1e1e2e'
    gsettings set "$K" foreground-color '#cdd6f4'
    gsettings set "$K" palette "['#45475a','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#bac2de','#585b70','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#a6adc8']"
    gsettings set "$K" scrollbar-policy 'never'
    gsettings set "$K" default-size-columns 110
    gsettings set "$K" default-size-rows 30
  else
    c_warn "GNOME Terminal tidak ditemukan; hanya prompt Starship yang dipasang"
  fi
  c_ok "Terminal diatur (buka terminal baru untuk melihat)"
}

m_browser() {
  "$HERE/browser-gtk.sh"
}

# ------------------------------------------------------------------- main ---

[[ ${1:-} == --help || ${1:-} == -h ]] && { usage; exit 0; }
[[ ${1:-} == --list ]] && { printf '%s\n' "${ALL_MODULES[@]}"; exit 0; }

[[ $EUID -ne 0 ]] || c_die "Jangan jalankan dengan sudo; script ini hanya mengubah folder home kamu."
[[ ${XDG_CURRENT_DESKTOP:-} == *GNOME* ]] || c_warn "Desktop bukan GNOME ($XDG_CURRENT_DESKTOP); hasil bisa berbeda."
need git curl tar unzip python3 dconf gsettings gnome-extensions fc-cache

modules=("$@")
((${#modules[@]})) || modules=("${ALL_MODULES[@]}")
[[ " ${modules[*]} " == *" backup "* ]] || modules=(backup "${modules[@]}")

for m in "${modules[@]}"; do
  [[ " ${ALL_MODULES[*]} " == *" $m "* ]] || c_die "Modul tidak dikenal: $m (lihat --help)"
  c_info "$m"
  "m_$m"
done

echo
c_info "Selesai. Langkah terakhir:"
echo "  • X11  : tekan Alt+F2, ketik r, Enter (memuat ulang GNOME Shell)"
echo "  • Wayland: log out lalu login lagi"
echo "  • Kembalikan semua: ./scripts/restore.sh"
