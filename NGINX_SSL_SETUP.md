# Panduan Install Nginx & SSL (Let’s Encrypt) - Multi Subdomain Setup

Dokumen ini menjelaskan langkah-langkah memasang Nginx dan SSL (Let’s Encrypt) untuk RadBill dengan arsitektur Microservices (banyak subdomain & port) pada server Ubuntu/Debian.

## Prasyarat

- Domain sudah mengarah ke IP VPS (A record) untuk semua subdomain (misal: `my`, `member`, `kasir`, `reseller`).
- Akses root/sudo pada server.
- Port 80 & 443 terbuka di Firewall/Security Group.

## 1) Install Nginx

Instal paket Nginx:

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

Cek status pastikan active (running):

```bash
sudo systemctl status nginx
```

## 2) Siapkan Konfigurasi Awal (HTTP)

Sebelum menginstall SSL, kita harus membuat konfigurasi standar di **Port 80** terlebih dahulu agar Certbot bisa memverifikasi kepemilikan domain.

Buat file konfigurasi baru:

```bash
sudo nano /etc/nginx/sites-available/radbill
```

Isi dengan konfigurasi berikut (sesuaikan dengan nama domain Anda):

```nginx
# 1. API Utama/Admin (Port 8080)
server {
    listen 80;
    server_name sub1.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# 2. Client Portal (Port 8081)
server {
    listen 80;
    server_name sub2.example.com;

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# 3. Cashier Portal (Port 8082)
server {
    listen 80;
    server_name sub3.example.com;

    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# 4. Reseller Portal (Port 8083)
server {
    listen 80;
    server_name sub4.example.com;

    location / {
        proxy_pass http://127.0.0.1:8083;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Simpan file (Ctrl+X, Y, Enter).

Aktifkan konfigurasi tersebut dan hapus default:

```bash
sudo ln -s /etc/nginx/sites-available/radbill /etc/nginx/sites-enabled/
# Hapus default config jika ada agar tidak bentrok
sudo unlink /etc/nginx/sites-enabled/default
```

Uji konfigurasi dan Reload Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 3) Install SSL (Let’s Encrypt) Otomatis

Install Certbot plugin nginx:

```bash
sudo apt install -y certbot python3-certbot-nginx
```

Jalankan Certbot. Anda bisa menjalankannya **tanpa parameter** agar muncul menu pilihan domain:

```bash
sudo certbot --nginx
```

Certbot akan membaca file Nginx Anda dan bertanya: *"Which names would you like to activate HTTPS for?"*.
**Tekan Enter** (kosong) untuk memilih **semua domain** yang terdaftar, atau ketik nomornya (misal: `1 2 3 4`).

### PENTING: Pilih Opsi Redirect
Saat proses berjalan, Certbot akan bertanya:

```text
Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter]:
```

**Pilih angka 2 (Redirect) lalu Enter.**

Ini akan membuat Certbot memodifikasi file konfigurasi Anda secara otomatis agar semua trafik non-aman (HTTP) dipaksa pindah ke aman (HTTPS).

## 4) Maintenance & Troubleshooting

**Cek Auto Renew SSL:**
Certbot otomatis memasang timer renew. Cek dengan:
```bash
sudo systemctl status certbot.timer
sudo certbot renew --dry-run
```

**Troubleshooting:**
- **502 Bad Gateway:** Artinya Nginx jalan, tapi aplikasi Go di port (8080/8081/dll) mati. Cek dengan `ps aux | grep main`.
- **Situs tidak bisa diakses:** Cek firewall, pastikan port 80 dan 443 diizinkan (`sudo ufw allow 'Nginx Full'`).


