# 3. Panduan Manual (tanpa script)

Semua yang dikerjakan `install.sh`, ditulis perintah per perintah. Cocok kalau kamu ingin paham setiap langkah atau hanya memasang sebagian.

> Jalankan di terminal biasa (bukan root). Folder kerja sementara: `~/linux2macos-src`.

```bash
mkdir -p ~/linux2macos-src && cd ~/linux2macos-src
```

---

## 0. Backup

```bash
mkdir -p ~/.config/linux2macos/backup/manual
dconf dump / > ~/.config/linux2macos/backup/manual/dconf.ini
cp ~/.bashrc ~/.config/linux2macos/backup/manual/bashrc
```

---

## 1. Tema GTK & GNOME Shell (WhiteSur)

Repo WhiteSur menyediakan rilis siap pakai di folder `release/`, jadi tidak perlu `sassc`.

```bash
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
mkdir -p ~/.themes
tar -xJf WhiteSur-gtk-theme/release/WhiteSur-Dark.tar.xz  -C ~/.themes
tar -xJf WhiteSur-gtk-theme/release/WhiteSur-Light.tar.xz -C ~/.themes

gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

Varian lain di folder `release/`: `-solid` (tanpa transparansi, lebih ringan) dan `-nord` (warna Nord).

### Penting: sesuaikan tema top bar dengan versi GNOME

Rilis di atas dibuat untuk GNOME versi tertentu (`grep VERSION WhiteSur-gtk-theme/release/release-info.txt`). Kalau berbeda dengan `gnome-shell --version`, tombol Quick Settings akan menumpuk. Compile ulang `gnome-shell.css`. Contoh untuk GNOME 46:

```bash
python3 -m venv ~/.cache/sassenv && ~/.cache/sassenv/bin/pip install libsass   # atau: sudo apt install sassc
cd WhiteSur-gtk-theme/src
cp sass/_theme-options.scss sass/_theme-options-temp.scss
cp sass/_gtk-base.scss      sass/_gtk-base-temp.scss
cp main/gnome-shell/_shell-base.scss main/gnome-shell/_shell-base-temp.scss
# GNOME 47/48: ganti 46/46-0 di _shell-base-temp.scss dengan 47/47-0 atau 48/48-0,
#              lalu ubah $shell_version: 'old' -> 'new' di sass/_theme-options-temp.scss
~/.cache/sassenv/bin/pysassc -t expanded main/gnome-shell/gnome-shell-Dark.scss \
    ~/.themes/WhiteSur-Dark/gnome-shell/gnome-shell.css
cp -n assets/gnome-shell/common-assets/*.svg assets/gnome-shell/assets-Dark/*.svg \
    ~/.themes/WhiteSur-Dark/gnome-shell/assets/
cd ../..
```

`scripts/install.sh` mengerjakan ini otomatis.

### Aplikasi GTK4 / libadwaita

Aplikasi GNOME baru (Files, Settings, Text Editor) tidak membaca `gtk-theme`. Arahkan lewat `~/.config/gtk-4.0`.

Rilis WhiteSur menyimpan tema GTK4 di dalam `gtk.gresource`, dan file itu **tidak** terbaca dari `~/.config/gtk-4.0`. Kalau langsung di-link, tema tidak termuat, tombol jendela jadi abu‑abu (× – ○), dan log berisi *"Failed to import: The resource at /org/gnome/theme/gtk.css does not exist"*. Ekstrak dulu:

```bash
D=~/.themes/WhiteSur-Dark/gtk-4.0
for r in $(gresource list $D/gtk.gresource); do
  f=$D/extracted/${r#/org/gnome/theme/}
  mkdir -p "$(dirname "$f")" && gresource extract $D/gtk.gresource "$r" > "$f"
done

mkdir -p ~/.config/gtk-4.0
for f in gtk.css gtk-dark.css assets windows-assets; do
  ln -sfn $D/extracted/$f ~/.config/gtk-4.0/$f
done
```

Buka ulang aplikasinya untuk melihat perubahan.

---

## 2. Ikon WhiteSur

Cara resmi:

```bash
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme && ./install.sh && cd ..
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
```

`install.sh` upstream memasang ke `~/.local/share/icons`. (`scripts/install.sh` di repo ini melakukan hal yang sama secara manual untuk varian default dan `-dark` saja.)

Opsi `install.sh` upstream yang berguna: `-a` ikon alternatif, `-b` ikon panel lebih tebal, `-t <warna>` warna folder (blue, purple, pink, red, orange, yellow, green, grey).

---

## 3. Kursor WhiteSur

```bash
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-cursors.git
mkdir -p ~/.local/share/icons/WhiteSur-cursors
cp -r WhiteSur-cursors/dist/* ~/.local/share/icons/WhiteSur-cursors/
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
```

---

## 4. Wallpaper

```bash
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-wallpapers.git
mkdir -p ~/.local/share/backgrounds
cp WhiteSur-wallpapers/1080p/WhiteSur*.jpg ~/.local/share/backgrounds/   # atau 2k / 4k

gsettings set org.gnome.desktop.background picture-uri      "file://$HOME/.local/share/backgrounds/WhiteSur-light.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/WhiteSur-dark.jpg"
gsettings set org.gnome.desktop.screensaver picture-uri     "file://$HOME/.local/share/backgrounds/WhiteSur-dark.jpg"
```

Pilihan lain di repo yang sama: `Monterey`, `Ventura`, `Sonoma`, `Nord`.

---

## 5. Font

**Inter** adalah font gratis (lisensi OFL) yang paling mirip SF Pro. Font SF Pro asli tidak boleh didistribusikan ulang.

```bash
curl -L -o inter.zip https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
unzip -o inter.zip -d inter
mkdir -p ~/.local/share/fonts/Inter
find inter -name 'Inter*.ttf' -exec cp {} ~/.local/share/fonts/Inter/ \;

curl -L -o jbm.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
unzip -o jbm.zip -d ~/.local/share/fonts/JetBrainsMonoNerd

fc-cache -f

gsettings set org.gnome.desktop.interface font-name 'Inter 10.5'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 10.5'
gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Semi-Bold 10.5'
```

Aplikasi dan situs yang meminta font generik (`sans-serif`, `system-ui`, `monospace`) mengambilnya dari fontconfig, bukan dari gsettings. Di Mac font generik itu menjadi SF Pro / SF Mono. Arahkan ke Inter dan JetBrains Mono:

```bash
mkdir -p ~/.config/fontconfig/conf.d
cat > ~/.config/fontconfig/conf.d/60-linux2macos.conf <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias><family>sans-serif</family><prefer><family>Inter</family></prefer></alias>
  <alias><family>system-ui</family><prefer><family>Inter</family></prefer></alias>
  <alias><family>-apple-system</family><prefer><family>Inter</family></prefer></alias>
  <alias><family>BlinkMacSystemFont</family><prefer><family>Inter</family></prefer></alias>
  <alias><family>monospace</family><prefer><family>JetBrainsMono Nerd Font Mono</family></prefer></alias>
</fontconfig>
XML
fc-cache -f
fc-match sans-serif     # harus: Inter
```

Buka ulang aplikasi/browser untuk melihat hasilnya.

---

## 6. Dock

Ubuntu memakai *Ubuntu Dock* (turunan Dash to Dock). Pengaturannya:

```bash
D=org.gnome.shell.extensions.dash-to-dock
gsettings set $D dock-position 'BOTTOM'           # bawah
gsettings set $D extend-height false              # tidak selebar layar
gsettings set $D dock-fixed false                 # boleh disembunyikan
gsettings set $D autohide true
gsettings set $D intellihide true                 # sembunyi hanya jika tertutup jendela
gsettings set $D dash-max-icon-size 44
gsettings set $D transparency-mode 'FIXED'
gsettings set $D background-opacity 0.35
gsettings set $D show-trash true
gsettings set $D show-mounts false
gsettings set $D click-action 'minimize-or-previews'
gsettings set $D custom-theme-shrink true
gsettings set $D running-indicator-style 'DOTS'   # titik di bawah ikon
gsettings set $D show-apps-at-top true            # tombol Launchpad di kiri
gsettings set org.gnome.shell.extensions.ding show-home false   # sembunyikan ikon Home di desktop
```

---

## 7. Jendela

```bash
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
gsettings set org.gnome.mutter center-new-windows true
```

---

## 8. Ekstensi GNOME

Penjelasan lengkap setiap ekstensi ada di [Ekstensi GNOME](04-ekstensi-gnome.md). Cara memasang tanpa browser:

```bash
SV=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)
for u in user-theme@gnome-shell-extensions.gcampax.github.com \
         blur-my-shell@aunetx \
         compiz-alike-magic-lamp-effect@hermes83.github.com \
         logomenu@aryan_k \
         just-perfection-desktop@just-perfection \
         search-light@icedman.github.com appmenu-is-back@fthx \
         monitor@astraext.github.io; do
  dl=$(curl -s "https://extensions.gnome.org/extension-info/?uuid=$u&shell_version=$SV" \
       | python3 -c 'import sys,json;print(json.load(sys.stdin)["download_url"])')
  curl -sL "https://extensions.gnome.org$dl" -o "$u.zip"
  gnome-extensions install --force "$u.zip"
done
```

Alternatif GUI: pasang **Extension Manager** (`sudo apt install gnome-shell-extension-manager`), cari nama ekstensinya, klik *Install*.

Muat ulang GNOME Shell (X11: <kbd>Alt</kbd>+<kbd>F2</kbd> → `r`; Wayland: log out), lalu aktifkan:

```bash
for u in user-theme@gnome-shell-extensions.gcampax.github.com blur-my-shell@aunetx \
         compiz-alike-magic-lamp-effect@hermes83.github.com logomenu@aryan_k \
         just-perfection-desktop@just-perfection \
         search-light@icedman.github.com appmenu-is-back@fthx \
         monitor@astraext.github.io; do
  gnome-extensions enable "$u"
done
```

Lalu terapkan pengaturan dari bagian *Pengaturan yang dipakai* di [04-ekstensi-gnome.md](04-ekstensi-gnome.md).

---

## 9. Ikon aplikasi yang belum seragam

Aplikasi snap/AppImage sering menulis ikon sebagai path absolut (`Icon=/snap/obs-studio/current/meta/gui/obs-studio.png`) sehingga tidak ikut tema. Solusinya, salin launcher ke folder lokal lalu ganti nama ikonnya:

```bash
cp /var/lib/snapd/desktop/applications/obs-studio_obs-studio.desktop ~/.local/share/applications/
sed -i 's|^Icon=.*|Icon=com.obsproject.Studio|' ~/.local/share/applications/obs-studio_obs-studio.desktop
update-desktop-database ~/.local/share/applications
```

Cari nama ikon yang tersedia: `ls ~/.local/share/icons/WhiteSur/apps/scalable | grep -i obs`.

Script `scripts/lib/fix-app-icons.py` melakukan ini otomatis untuk semua aplikasi.

Contoh pemetaan:

| Aplikasi | Ikon WhiteSur |
|---|---|
| LibreOffice Writer/Calc/Impress… | `libreoffice-writer`, `libreoffice-calc`, `libreoffice-impress` |
| OBS Studio | `com.obsproject.Studio` |
| Chromium (snap) | `chromium` |
| App Center | `snap-store` |
| Firmware Updater | `org.gnome.Firmware` |
| Android Studio | `android-studio` |
| Zed | `dev.zed.Zed` |
| RustDesk | `rustdesk` |
| Claude | `claude` |

Aplikasi web (PWA) dari Chrome/Brave sengaja dibiarkan memakai ikon situsnya.

---

## 10. Browser & terminal

Lihat [Browser & Terminal](05-browser-terminal.md).

---

## 11. Muat ulang

X11: <kbd>Alt</kbd>+<kbd>F2</kbd> → `r` → <kbd>Enter</kbd>. Wayland: log out/login.
