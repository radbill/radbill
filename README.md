# RadBill - Sistem Billing & Manajemen ISP

RadBill adalah aplikasi billing dan manajemen ISP untuk mengelola pelanggan, layanan internet, perangkat NAS, dan proses penagihan secara terintegrasi.

## Ringkasan

RadBill membantu ISP mengelola:
- Pelanggan dan layanan internet (PPPoE/Hotspot)
- Tagihan, invoice, dan pembayaran
- NAS/Router (MikroTik) termasuk VPN akses
- Laporan dan monitoring sesi aktif
- Integrasi payment gateway dan WhatsApp gateway

## Fitur Utama

### 1) Manajemen Pelanggan & Layanan
- Data pelanggan, profil layanan, dan status aktif
- Manajemen PPPoE dan Hotspot
- Manajemen isolir

### 2) Billing & Invoice
- Pembuatan invoice otomatis
- Histori pembayaran
- Pengaturan produk/plan dan tarif

### 3) Manajemen NAS & VPN
- Registrasi NAS
- VPN akses untuk NAS (WireGuard/L2TP)
- Monitoring status NAS

### 4) Portal & Roles
- Admin, reseller, dan cashier portal
- Portal pelanggan (client portal)

### 5) Laporan & Monitoring
- Sesi aktif PPPoE/Hotspot
- Laporan transaksi dan rekap
- Network map & monitoring

### 6) Integrasi
- Payment gateway
- WhatsApp gateway
- TR-069/GenieACS/GoACS

## Teknologi

- Backend: Go (Clean Architecture)
- Database: MySQL/MariaDB
- Frontend: HTML/CSS/JS (admin & portal)
- Infrastruktur: Nginx + SSL Let’s Encrypt

## Instalasi Singkat (Linux)

Gunakan installer resmi:

```bash
wget -qO- https://raw.githubusercontent.com/radbill/radbill/main/install.sh | sudo bash
```

Untuk update:

```bash
wget -qO- https://raw.githubusercontent.com/radbill/radbill/main/update.sh | sudo bash
```

Panduan Nginx & SSL: [docs/NGINX_SSL_SETUP.md](docs/NGINX_SSL_SETUP.md)

## Lisensi

Hak cipta dan lisensi mengikuti ketentuan proyek ini.
