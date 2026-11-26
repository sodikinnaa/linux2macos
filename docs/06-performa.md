# 6. Performa: tetap ringan, tidak ngelag

Pengaturan bawaan linux2macos sudah dipilih supaya ringan:

| Pengaturan | Nilai | Kenapa |
|---|---|---|
| Blur top bar & dock | **statis** | Blur dinamis menghitung ulang setiap frame; statis hanya sekali |
| Blur jendela aplikasi | **mati** | Efek paling berat di Blur my Shell |
| Blur menu popup | **mati** | Menyala secara bawaan; membuat GNOME Shell 20–40% CPU terus-menerus (turun ke 3–5% setelah dimatikan) |
| Sigma blur | 25 | Cukup halus, tidak terlalu berat |
| Magic Lamp | 300 ms, 8×8 tile | Lebih cepat & lebih sedikit poligon dari bawaan (400 ms, 10×10) |
| Dock | auto‑hide + intellihide | Tidak menutupi jendela, tidak perlu digambar terus |

## Jika masih terasa berat

Urutkan dari yang paling berpengaruh:

1. **Tutup aplikasi berat yang tidak dipakai.** VM (QEMU/VirtualBox/Docker macOS), banyak tab Chrome/Brave, dan Android emulator memakan RAM & CPU jauh lebih banyak daripada tema. Cek:
   ```bash
   ps -eo pcpu,rss,comm --sort=-rss | head
   free -h
   ```
2. **Matikan blur sepenuhnya** (tampilan tetap transparan, hanya tanpa blur):
   ```bash
   gnome-extensions disable blur-my-shell@aunetx
   ```
3. **Pakai tema solid** (tanpa transparansi):
   ```bash
   CACHE=~/.cache/linux2macos/src/WhiteSur-gtk-theme
   tar -xJf $CACHE/release/WhiteSur-Dark-solid.tar.xz -C ~/.themes
   gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
   dconf write /org/gnome/shell/extensions/user-theme/name "'WhiteSur-Dark-solid'"
   ```
4. **Percepat atau matikan Magic Lamp**:
   ```bash
   dconf write /org/gnome/shell/extensions/ncom/github/hermes83/compiz-alike-magic-lamp-effect/duration 200.0
   # atau
   gnome-extensions disable compiz-alike-magic-lamp-effect@hermes83.github.com
   ```
5. **Kurangi animasi GNOME** lewat Just Perfection → *Behavior* → *Animation* (pilih *Fast* / *Faster*), atau matikan semua animasi:
   ```bash
   gsettings set org.gnome.desktop.interface enable-animations false
   ```

## GPU & driver

| Kondisi | Saran |
|---|---|
| NVIDIA | Pakai driver proprietary (`ubuntu-drivers devices`, lalu `sudo ubuntu-drivers install`). Cek: `nvidia-smi` |
| NVIDIA + X11, layar tearing | NVIDIA Settings → *Force Full Composition Pipeline*. Bisa menambah sedikit input lag |
| Intel/AMD | Driver Mesa bawaan sudah cukup; pastikan sistem ter‑update |
| Laptop hybrid | Efek desktop tetap di iGPU; itu normal |

Cek renderer yang dipakai GNOME:

```bash
glxinfo -B | grep -E 'renderer|direct'     # paket: mesa-utils
```

Kalau tertulis `llvmpipe`, berarti GPU tidak dipakai (render via CPU). Pasang driver GPU dulu, karena semua efek akan terasa berat.

## Mengetik atau scroll terasa delay

Kalau tema sudah ringan tapi ketikan masih terasa telat muncul, penyebabnya biasanya GPU atau CPU yang sedang berhemat daya. Tiga pengaturan ini aman dan bisa dibatalkan.

**1. GPU NVIDIA selalu siap.** Secara bawaan NVIDIA turun ke clock rendah saat santai, dan butuh waktu untuk naik lagi. Mode *Prefer Maximum Performance* menghilangkan jeda itu (konsumsi listrik sedikit naik):

```bash
nvidia-settings -a '[gpu:0]/GpuPowerMizerMode=1'
```

Pengaturan ini hilang setelah reboot. Supaya otomatis setiap login:

```bash
cat > ~/.config/autostart/nvidia-performance.desktop <<'END'
[Desktop Entry]
Type=Application
Name=NVIDIA Performance
Exec=nvidia-settings -a [gpu:0]/GpuPowerMizerMode=1
NoDisplay=true
END
```

Batalkan: hapus file itu lalu jalankan `nvidia-settings -a '[gpu:0]/GpuPowerMizerMode=0'`.

**2. Profil daya Performance.** Sama dengan memilih *Performance* di Quick Settings → *Power Mode*:

```bash
powerprofilesctl set performance      # kembali: balanced
```

**3. Kurangi swap (butuh sudo).** Ubuntu mulai memindahkan isi RAM ke disk cukup awal (`swappiness` 60). Kalau RAM kamu 16 GB atau lebih, nilai rendah membuat aplikasi tidak tersendat saat dibuka lagi:

```bash
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl --system
```

Batalkan: `sudo rm /etc/sysctl.d/99-swappiness.conf && sudo sysctl vm.swappiness=60`.

## Refresh rate

Settings → Displays → Refresh Rate: pilih yang tertinggi yang didukung monitor (mis. 75 Hz / 144 Hz). Animasi terasa jauh lebih halus.

## Mengukur beban GNOME Shell

GNOME Shell yang sehat saat diam memakai CPU di bawah ~5%. Ukur rata-rata 6 detik (paket `sysstat`):

```bash
pidstat -p $(pgrep -x gnome-shell) 1 6 | tail -1
```

Untuk mencari ekstensi yang berat, matikan satu per satu lalu ukur lagi:

```bash
gnome-extensions disable blur-my-shell@aunetx; sleep 3
pidstat -p $(pgrep -x gnome-shell) 1 6 | tail -1
gnome-extensions enable blur-my-shell@aunetx
```

## Memeriksa apa yang membuat lag

```bash
top -o %CPU               # tekan q untuk keluar
journalctl --user -b -g 'gnome-shell' | tail -50   # error dari ekstensi
```

Ekstensi yang error berulang bisa membuat GNOME Shell tersendat. Nonaktifkan satu per satu untuk mencari penyebabnya.
