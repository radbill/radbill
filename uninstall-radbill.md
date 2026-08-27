# Panduan Uninstall Radbill

Dokumen ini menjelaskan cara menghapus instalasi Radbill dari server Linux berbasis Debian, Ubuntu, atau Armbian. Instalasi standar menggunakan direktori `/opt/radbill`, service `systemd`, serta database MariaDB/MySQL bernama `radius` dan `radius_state`.

> **PERINGATAN:** Penghapusan database dan direktori data bersifat permanen. Pastikan server tidak menyimpan database atau aplikasi lain yang masih diperlukan.

## 1. Persiapan dan backup

Bagian ini opsional, tetapi sangat disarankan apabila data mungkin diperlukan kembali.

```bash
sudo mkdir -p /root/radbill-backup

sudo mysqldump --single-transaction --routines --triggers \
  -u root -p radius > /root/radbill-backup/radius.sql

sudo mysqldump --single-transaction --routines --triggers \
  -u root -p radius_state > /root/radbill-backup/radius_state.sql

sudo cp -a /opt/radbill /root/radbill-backup/radbill-files
sudo ls -lh /root/radbill-backup
```

Jika MariaDB/MySQL telah dihapus sebelum backup dibuat, data hanya dapat dipulihkan dari backup yang sudah tersedia sebelumnya.

## 2. Hentikan dan hapus service Radbill

Hentikan semua service Radbill dan nonaktifkan agar tidak dijalankan saat server boot:

```bash
sudo systemctl disable --now \
  radbill-api.service \
  radbill-radius.service \
  radbill-acs.service \
  radbill-worker.service \
  radbill-whatsapp-gateway.service
```

Pesan bahwa unit tidak ditemukan dapat diabaikan jika komponen tersebut memang tidak pernah dipasang.

Hapus seluruh unit service:

```bash
sudo rm -f \
  /etc/systemd/system/radbill-api.service \
  /etc/systemd/system/radbill-radius.service \
  /etc/systemd/system/radbill-acs.service \
  /etc/systemd/system/radbill-worker.service \
  /etc/systemd/system/radbill-whatsapp-gateway.service

sudo systemctl daemon-reload
sudo systemctl reset-failed
```

Hapus cron lama jika masih tersedia:

```bash
sudo rm -f /etc/cron.d/radbill-billing
```

## 3. Hapus binary, konfigurasi, dan log Radbill

Perintah berikut menghapus binary, frontend, file `.env`, license, konfigurasi runtime, dan log aplikasi:

```bash
sudo rm -rf /opt/radbill
sudo rm -rf /var/log/billing
sudo rm -f /tmp/radbill-updater
```

Verifikasi direktori aplikasi:

```bash
test ! -e /opt/radbill && echo "Direktori aplikasi sudah terhapus"
```


## 4. Uninstall total MariaDB

Gunakan bagian ini hanya jika MariaDB tidak digunakan oleh aplikasi lain. Tindakan ini menghapus seluruh database di server, bukan hanya data Radbill.

Hentikan service dan hapus paket MariaDB:

```bash
sudo systemctl disable --now mariadb 2>/dev/null || true

sudo apt purge -y \
  mariadb-server \
  mariadb-client \
  mariadb-common \
  mariadb-server-core \
  mariadb-client-core

sudo apt autoremove --purge -y
sudo apt autoclean
```

Hapus seluruh data dan konfigurasi yang tersisa:

```bash
sudo rm -rf /var/lib/mysql
sudo rm -rf /etc/mysql
sudo rm -rf /var/log/mysql
sudo rm -rf /var/log/mysql.*
sudo rm -f /etc/apt/sources.list.d/mariadb.list
sudo systemctl daemon-reload
```


## 5. Ekstensi PHP MySQL

Paket `php-mysql` dan `php8.2-mysql` hanyalah ekstensi PHP untuk menghubungkan aplikasi PHP ke MySQL. Paket tersebut bukan server database dan aman dibiarkan jika masih digunakan website lain.

Jika tidak diperlukan, hapus dengan:

```bash
sudo apt purge -y php-mysql php8.2-mysql
sudo apt autoremove --purge -y
sudo apt autoclean
```

## 6. Bersihkan konfigurasi Nginx

Cari konfigurasi yang mengarah ke Radbill:

```bash
sudo grep -RilE 'radbill|127\.0\.0\.1:8080|127\.0\.0\.1:8087' \
  /etc/nginx/sites-available \
  /etc/nginx/sites-enabled \
  /etc/nginx/conf.d 2>/dev/null
```

Periksa hasilnya, lalu hapus hanya file konfigurasi yang memang khusus Radbill. Sesudah itu validasi dan muat ulang Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Jika sertifikat domain Radbill dikelola Certbot dan sudah tidak diperlukan:

```bash
sudo certbot certificates
sudo certbot delete --cert-name NAMA_DOMAIN
```

Jangan uninstall Nginx atau Certbot apabila masih digunakan website lain.

## 7. Pembersihan Redis opsional

Radbill menggunakan key Redis dengan prefix `otp:` dan `acs:session:`. Jangan menggunakan `FLUSHDB` jika Redis digunakan bersama aplikasi lain.

Periksa key terkait Radbill:

```bash
redis-cli --scan --pattern 'otp:*'
redis-cli --scan --pattern 'acs:session:*'
```

Jika instance Redis sepenuhnya khusus Radbill, database Redis dapat dibersihkan dengan:

```bash
redis-cli FLUSHDB
```

## 8. Verifikasi akhir

Periksa apakah service dan file Radbill telah hilang:

```bash
systemctl list-unit-files | grep -i radbill || echo "Bersih: unit Radbill tidak ditemukan"
systemctl list-units --all | grep -i radbill || echo "Bersih: service Radbill tidak berjalan"
test ! -e /opt/radbill && echo "Bersih: direktori Radbill sudah terhapus"
```

Periksa instalasi MariaDB/MySQL:

```bash
dpkg -l | grep -Ei 'mysql|mariadb' || echo "Bersih: tidak ada paket MySQL/MariaDB"
command -v mysql || echo "Bersih: mysql client tidak ditemukan"
test ! -d /var/lib/mysql && echo "Bersih: data MySQL/MariaDB sudah terhapus"
```

