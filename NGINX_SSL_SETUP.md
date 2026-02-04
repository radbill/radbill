# Panduan Install Nginx & SSL (Let’s Encrypt)

Dokumen ini menjelaskan langkah-langkah memasang Nginx dan SSL (Let’s Encrypt) untuk RadBill pada server Ubuntu/Debian.

## Prasyarat

- Domain sudah mengarah ke IP VPS (A record)
- Akses root/sudo
- Port 80 & 443 terbuka

## 1) Install Nginx

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

Cek status:

```bash
sudo systemctl status nginx
```

## 2) Siapkan Konfigurasi Nginx

Buat file konfigurasi baru:

```bash
sudo nano /etc/nginx/sites-available/radbill
```

Isi dengan konfigurasi berikut (ganti domain dan port aplikasi):

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    # Arahkan ke aplikasi RadBill
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Aktifkan site:

```bash
sudo ln -s /etc/nginx/sites-available/radbill /etc/nginx/sites-enabled/
```

Uji konfigurasi:

```bash
sudo nginx -t
```

Reload Nginx:

```bash
sudo systemctl reload nginx
```

## 3) Install SSL (Let’s Encrypt)

Install Certbot:

```bash
sudo apt install -y certbot python3-certbot-nginx
```

Jalankan Certbot:

```bash
sudo certbot --nginx -d example.com -d www.example.com
```

Ikuti prompt untuk memilih redirect HTTP ke HTTPS.

## 4) Cek Auto Renew SSL

Cek timer:

```bash
sudo systemctl status certbot.timer
```

Uji renew:

```bash
sudo certbot renew --dry-run
```

## 5) (Opsional) Optimasi Nginx untuk HTTPS

Tambahkan block berikut pada server HTTPS di file Nginx yang sudah dibuat oleh Certbot:

```nginx
# Tambahkan di dalam server { ... }
client_max_body_size 50M;
proxy_read_timeout 300;
proxy_connect_timeout 300;
proxy_send_timeout 300;
```

## Catatan Penting

- Pastikan aplikasi RadBill berjalan di port yang benar (default: 8080).
- Jika port aplikasi berbeda, ubah bagian `proxy_pass`.
- Jika ingin multi-domain, tambahkan di `server_name`.

## Troubleshooting

- **Port 80/443 belum terbuka:** cek firewall VPS
- **SSL gagal:** pastikan domain sudah resolve ke IP VPS
- **Nginx gagal reload:** periksa error dengan `sudo nginx -t`
