#!/usr/bin/env bash
# Switch every Chrome/Chromium/Brave/Edge profile to the GTK theme so the
# window buttons follow WhiteSur (red/yellow/green on the left).
#
#   ./scripts/browser-gtk.sh          # apply to browsers that are closed now
#   ./scripts/browser-gtk.sh --wait   # wait until each running browser exits
#   ./scripts/browser-gtk.sh --undo   # put back the saved Preferences files
#
# Browsers rewrite Preferences on exit, so they must be closed while patching.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

BK="$L2M_STATE/backup/browser-prefs"
# process-name:config-dir
BROWSERS=(
  "chrome:$HOME/.config/google-chrome"
  "chromium:$HOME/.config/chromium"
  "chromium:$HOME/snap/chromium/common/chromium"
  "brave:$HOME/.config/BraveSoftware/Brave-Browser"
  "msedge:$HOME/.config/microsoft-edge"
)

profiles() { # config-dir -> Preferences files
  local f
  for f in "$1"/Default/Preferences "$1"/Profile\ */Preferences; do
    [[ -f $f ]] && printf '%s\n' "$f"
  done
}

patch() { # proc dir
  local proc="$1" dir="$2" f p
  while IFS= read -r f; do
    p=$(basename "$(dirname "$f")")
    mkdir -p "$BK"
    local saved="$BK/$(basename "$dir")-${p// /_}.Preferences"
    [[ -f $saved ]] || cp -p "$f" "$saved"   # keep the oldest copy
    python3 -I - "$f" <<'EOF'
import json, os, sys
f = sys.argv[1]
d = json.load(open(f, encoding="utf-8"))
d.setdefault("extensions", {}).setdefault("theme", {})["system_theme"] = 1  # 0 classic, 1 GTK, 2 QT
d.setdefault("browser", {})["custom_chrome_frame"] = True                  # keep tabs in the title bar
tmp = f + ".tmp"
json.dump(d, open(tmp, "w", encoding="utf-8"), separators=(",", ":"))
os.replace(tmp, f)
EOF
    c_ok "$proc / $p → GTK"
  done < <(profiles "$dir")
}

undo() {
  [[ -d $BK ]] || c_die "Tidak ada backup Preferences browser"
  local entry proc dir f p saved
  for entry in "${BROWSERS[@]}"; do
    proc=${entry%%:*}; dir=${entry#*:}
    [[ -d $dir ]] || continue
    pgrep -x "$proc" >/dev/null && { c_warn "Tutup $proc dulu, dilewati"; continue; }
    while IFS= read -r f; do
      p=$(basename "$(dirname "$f")")
      saved="$BK/$(basename "$dir")-${p// /_}.Preferences"
      [[ -f $saved ]] && cp -p "$saved" "$f" && c_ok "$proc / $p dikembalikan"
    done < <(profiles "$dir")
  done
}

wait_mode=false
case "${1:-}" in
  --undo) undo; exit 0 ;;
  --wait) wait_mode=true ;;
esac

pids=()
for entry in "${BROWSERS[@]}"; do
  proc=${entry%%:*}; dir=${entry#*:}
  [[ -d $dir ]] || continue
  if pgrep -x "$proc" >/dev/null; then
    if $wait_mode; then
      c_info "Menunggu $proc ditutup (Ctrl+Shift+Q untuk keluar penuh)…"
      ( while pgrep -x "$proc" >/dev/null; do sleep 3; done; patch "$proc" "$dir" ) &
      pids+=($!)
    else
      c_warn "$proc masih berjalan; tutup lalu jalankan ulang, atau pakai --wait"
    fi
  else
    patch "$proc" "$dir"
  fi
done
((${#pids[@]})) && wait "${pids[@]}"
exit 0
