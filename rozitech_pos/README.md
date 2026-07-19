<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/SQLite-Drift-003B57?style=for-the-badge&logo=sqlite&logoColor=white" />
<img src="https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=for-the-badge" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20Windows-green?style=for-the-badge" />

# 🏪 Rozitech POS

**Aplikasi Point of Sale (Kasir) Offline-First Profesional**

*Dikembangkan oleh [Rozitech Multimedia Indonesia](https://rozitech.co.id)*

</div>

---

## 📋 Deskripsi

**Rozitech POS** adalah aplikasi kasir (Point of Sale) komersial berbasis Flutter yang dirancang untuk bekerja **100% offline**. Semua data bisnis disimpan secara lokal di SQLite menggunakan ORM Drift. Koneksi internet **hanya** digunakan untuk aktivasi dan validasi lisensi.

### 🎯 Target Platform

| Platform | Status |
|----------|--------|
| **Android** | ✅ Primary |
| **Windows** | 🚧 In Development |
| **Linux** | 📅 Planned |
| **Web** | 📅 Read-Only (Planned) |

---

## ✨ Fitur Utama

| Modul | Fitur |
|-------|-------|
| 🛒 **POS / Kasir** | Grid produk, keranjang belanja, numpad, hitung kembalian, checkout |
| 💳 **Pembayaran** | Integrasi Gateway Pembayaran (QRIS Dinamis & Midtrans) |
| 👥 **Sinkronisasi Pengguna** | Sinkronisasi multi-akun kasir/manager/owner dengan Laravel backend |
| 🖨️ **Struk & Thermal** | Cetak struk via Bluetooth thermal printer (58mm/80mm) & generate PDF struk |
| 📦 **Produk** | CRUD produk, kategori, barcode, gambar, pelacakan stok, scan kamera |
| 📊 **Laporan** | Penjualan harian/bulanan, laba bersih, produk terlaris, export Excel |
| 🗃️ **Inventaris** | Stok masuk/keluar, penyesuaian, log pergerakan stok |
| 👥 **Pelanggan** | Data pelanggan, poin loyalitas |
| 🚚 **Supplier** | Manajemen data supplier |
| 💸 **Pengeluaran** | Pencatatan & kategorisasi pengeluaran |
| 🔒 **Lisensi** | Aktivasi offline-first, re-validasi 30 hari, JWT secure storage |
| 🔁 **Backup/Restore** | Backup database SQLite lokal |
| 🤖 **AI Asisten** | Antarmuka chat (siap integrasi AI) |
| ⚙️ **Pengaturan** | Profil toko, tarif pajak, lebar kertas struk, tema, gerbang pembayaran |

---

## 🏗️ Arsitektur

Proyek ini menggunakan **Clean Architecture + Feature-First** folder structure.

```
lib/
├── core/                          # Shared infrastructure
│   ├── config/                    # App constants & config
│   ├── constants/                 # Colors, strings
│   ├── database/                  # Drift schema & provider
│   ├── license/                   # License manager & API
│   ├── network/                   # Dio HTTP client
│   ├── theme/                     # Material 3 themes
│   └── utils/                     # Extensions, Result, InvoiceGenerator
│
├── features/                      # Feature modules (1 per domain)
│   ├── ai/                        # AI Assistant
│   ├── backup/                    # Backup & Restore
│   ├── categories/                # Category management
│   ├── customers/                 # Customer management
│   ├── dashboard/                 # Dashboard & KPI
│   ├── expenses/                  # Expense tracking
│   ├── inventory/                 # Stock movements
│   ├── license/                   # License UI pages
│   ├── products/                  # Product CRUD
│   ├── reports/                   # Sales reports
│   ├── sales/                     # POS + Transaction history
│   ├── settings/                  # App settings
│   └── suppliers/                 # Supplier management
│
├── routes/                        # GoRouter config + Splash page
├── shared/                        # Shared widgets (MainShell)
└── main.dart                      # App entry point
```

### Layer di Setiap Feature

```
features/<feature>/
├── data/
│   └── repositories/     # Drift queries, API calls
├── domain/               # (Siap digunakan) Entities & use cases
└── presentation/
    ├── pages/            # Screen widgets (ConsumerWidget/StatefulWidget)
    └── widgets/          # Reusable sub-widgets
```

---

## 🛠️ Tech Stack

| Teknologi | Package | Versi | Fungsi |
|-----------|---------|-------|--------|
| **Flutter** | — | Stable | Framework UI |
| **Dart** | — | 3.x | Bahasa pemrograman |
| **State Management** | `flutter_riverpod` | ^2.5.1 | Manajemen state |
| **Routing** | `go_router` | ^14.2.0 | Navigasi deklaratif |
| **Database** | `drift` + `drift_flutter` | ^2.20.0 | ORM SQLite |
| **HTTP** | `dio` | ^5.4.3 | REST API client |
| **Secure Storage** | `flutter_secure_storage` | ^9.2.2 | Simpan JWT/token |
| **Font** | `google_fonts` | ^6.2.1 | Outfit font family |
| **Animasi** | `flutter_animate` | ^4.5.0 | Micro-animations |
| **Chart** | `fl_chart` | ^0.68.0 | Bar/line chart |
| **PDF** | `pdf` + `printing` | ^3.11.1 | Generate struk PDF |
| **Barcode** | `mobile_scanner` | ^5.2.2 | Scan barcode kamera |
| **Bluetooth** | `blue_thermal_printer` | ^1.1.6 | Cetak struk thermal |
| **Share** | `share_plus` | ^12.0.0 | Share content |
| **Image** | `image_picker` | ^1.1.2 | Pilih foto produk |
| **Export** | `excel` | ^4.0.3 | Export laporan Excel |
| **File** | `file_picker` | ^8.0.7 | Pilih file backup |
| **UUID** | `uuid` | ^4.4.2 | Generate UUID |
| **Intl** | `intl` | ^0.19.0 | Format tanggal/currency |

---

## 🗄️ Skema Database (15 Tabel)

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│    products      │────▶│ transaction_items │◀────│  transactions   │
├─────────────────┤     └──────────────────┘     ├─────────────────┤
│ id              │                               │ id              │
│ name            │     ┌──────────────────┐     │ invoice_number  │
│ sku             │     │    categories    │     │ customer_id     │
│ barcode         │◀────│                  │     │ subtotal        │
│ price           │     └──────────────────┘     │ tax_amount      │
│ cost            │                               │ total           │
│ stock           │     ┌──────────────────┐     │ cash_amount     │
│ min_stock       │     │   stock_logs     │     │ payment_method  │
│ image_path      │◀────│                  │     └─────────────────┘
│ is_active       │     └──────────────────┘
│ track_stock     │
│ tax             │
└─────────────────┘     ┌──────────────────┐     ┌─────────────────┐
                        │   customers      │     │   suppliers     │
                        └──────────────────┘     └─────────────────┘

┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│    expenses     │     │    settings      │     │    licenses     │
└─────────────────┘     └──────────────────┘     └─────────────────┘

┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  expense_cats   │     │  notifications   │     │  app_versions   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

---

## 🚀 Cara Menjalankan

### Prasyarat

```bash
# Flutter SDK Stable
flutter --version   # >= 3.19.0

# Android: Pastikan emulator/device terhubung
flutter devices

# Windows: Aktifkan Developer Mode
# Settings → Privacy & Security → For Developers → Developer Mode ON
```

### Clone & Setup

```bash
# 1. Clone repositori
git clone https://github.com/esnpendosa/Chasir.git
cd Chasir/rozitech_pos

# 2. Install dependencies
flutter pub get

# 3. Generate Drift database code
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Buat folder aset (jika belum ada)
mkdir -p assets/images assets/icons assets/fonts assets/lottie

# 5. Jalankan aplikasi
flutter run
```

### Build APK

Untuk instruksi build Android lengkap, terperinci, dan penyelesaian kendala Gradle/Kotlin/Manifest, lihat panduan khusus di [**BUILD_ANDROID.md**](BUILD_ANDROID.md).

Ringkasan perintah build:
```bash
# Bersihkan build lama & stop daemon gradle
flutter clean
flutter pub get
cd android; ./gradlew --stop; cd ..

# Build Release APK
flutter build apk --release
```

### Build Windows

```bash
# Aktifkan Developer Mode terlebih dahulu
flutter build windows --release
```

---

## ⚙️ Konfigurasi

### `lib/core/config/app_config.dart`

```dart
abstract final class AppConfig {
  static const appName = 'Rozitech POS';
  static const appVersion = '1.0.0';
  static const developer = 'Rozitech Multimedia Indonesia';
  static const website = 'https://rozitech.co.id';

  // License API
  static const apiBaseUrl = 'https://api.rozitech.co.id/v1';
  static const licenseCheckIntervalDays = 30;

  // Storage Keys
  static const keyLicenseToken = 'rz_license_token';
  static const keyLicenseKey = 'rz_license_key';
}
```

### Environment

Tidak memerlukan file `.env`. Konfigurasi dilakukan langsung di `app_config.dart`.

---

## 🔒 Sistem Lisensi

```
Startup
  │
  ▼
SplashPage
  │
  ▼
LicenseManager.checkLocalLicense()
  │
  ├── [Token tidak ada] ──────────────▶ ActivationPage
  │                                          │
  ├── [Token expired] ───────────────▶ ActivationPage
  │                                          │
  └── [Valid] ──────────────────────▶ DashboardPage
        │
        └── [Cek interval ≥30 hari] ──▶ _reCheckOnline() [background]
```

- **JWT** disimpan di `FlutterSecureStorage` (Android Keystore / Windows DPAPI)
- **Re-validasi online** dilakukan silent di background setiap 30 hari
- **Offline-safe**: jika server tidak bisa dijangkau, lisensi lokal tetap valid

---

## 📁 Konvensi Kode

### Penamaan File

```
# Pages
<nama>_page.dart          # dashboard_page.dart

# Widgets
<nama>_<jenis>.dart       # product_card.dart, sales_chart.dart

# Repositories
<nama>_repository.dart    # product_repository.dart

# Providers
<nama>_provider.dart      # theme_provider.dart
```

### Penamaan Provider

```dart
// State Provider
final productSearchProvider = StateProvider<String>((ref) => '');

// Future Provider
final licenseStatusProvider = FutureProvider<LicenseStatus>((ref) async {...});

// Stream Provider
final productsStreamProvider = StreamProvider.family<List<Product>, ({...})>(...);

// Notifier Provider
final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

// Simple Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) => ...);
```

### Result Pattern

```dart
// Selalu gunakan Result<T> untuk operasi yang bisa gagal
Future<Result<int>> create(ProductsCompanion companion) async {
  try {
    final id = await _db.into(_db.products).insert(companion);
    return Success(id);
  } catch (e) {
    return Failure('Gagal menyimpan produk: $e', e);
  }
}

// Konsumsi dengan fold()
final result = await repo.create(companion);
result.fold(
  onSuccess: (id) => showSuccessSnackBar('Produk berhasil disimpan'),
  onFailure: (msg, _) => showErrorSnackBar(msg),
);
```

---

## 🤝 Cara Berkontribusi

Lihat [CONTRIBUTING.md](CONTRIBUTING.md) untuk panduan lengkap.

```bash
# 1. Fork repositori
# 2. Buat branch baru
git checkout -b feature/nama-fitur

# 3. Commit dengan pesan yang jelas
git commit -m "feat(products): tambah fitur cetak label barcode"

# 4. Push dan buat Pull Request
git push origin feature/nama-fitur
```

### Commit Convention

```
feat(scope): deskripsi fitur baru
fix(scope): perbaikan bug
refactor(scope): refactoring kode
docs(scope): perubahan dokumentasi
style(scope): perubahan formatting
test(scope): tambah/perbaiki test
chore(scope): update dependency/config
```

---

## 📱 Screenshot

> *(akan diperbarui setelah build pertama)*

| Splash | Dashboard | POS |
|--------|-----------|-----|
| *coming soon* | *coming soon* | *coming soon* |

---

## 🗺️ Roadmap

### v1.0.0 — MVP (Current)
- [x] Arsitektur Clean Architecture + Feature First
- [x] Database Drift (15 tabel)
- [x] Sistem lisensi offline-first
- [x] Modul POS / Kasir lengkap
- [x] Manajemen produk CRUD
- [x] Dashboard KPI
- [x] Laporan harian/bulanan
- [x] Inventaris stok masuk/keluar
- [x] Backup & restore database
- [x] Dark/Light mode

### v1.1.0 — Printing & Scanning
- [x] Bluetooth thermal printing (58mm/80mm)
- [x] Scan barcode via kamera (mobile_scanner)
- [x] Cetak PDF struk
- [x] Export laporan ke Excel

### v1.2.0 — Data & Analytics
- [x] Laporan dari data Drift nyata (bukan mock)
- [x] Simpan pengaturan toko ke DB
- [x] Filter transaksi by tanggal/kasir
- [x] Statistik pelanggan

### v2.0.0 — AI & Cloud Sync
- [x] Integrasi Pembayaran Dinamis (QRIS & Midtrans)
- [x] Sinkronisasi Akun & Data User dengan Laravel Backend
- [ ] AI Asisten (analisis penjualan, rekomendasi stok)
- [ ] Multi-outlet sync
- [ ] Cloud backup opsional

---

## 🐛 Troubleshooting

### `pub get` gagal — konflik `image` package

```yaml
# Tambahkan di pubspec.yaml
dependency_overrides:
  image: ^4.1.3
```

### Windows: symlink error saat build

```
Aktifkan Developer Mode:
Settings → Privacy & Security → For Developers → Developer Mode: ON
```

### Drift: perlu regenerate setelah ubah schema

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### `LicensePage` ambiguous import

```dart
// Di file yang mengimport LicensePage Anda sendiri:
import 'package:flutter/material.dart' hide LicensePage;
import '../features/license/presentation/pages/license_page.dart';
```

---

## 📄 Lisensi

```
Copyright (c) 2024 Rozitech Multimedia Indonesia
All rights reserved.

Aplikasi ini dilindungi hak cipta. Dilarang mendistribusikan,
memodifikasi, atau menggunakan tanpa izin tertulis dari
Rozitech Multimedia Indonesia.
```

---

## 📞 Kontak

| Channel | Info |
|---------|------|
| 🌐 Website | [rozitech.co.id](https://rozitech.co.id) |
| 📧 Email | info@rozitech.co.id |
| 💬 WhatsApp | (hubungi via website) |
| 🐙 GitHub | [@esnpendosa](https://github.com/esnpendosa) |

---

<div align="center">
  <sub>Made with ❤️ by Rozitech Multimedia Indonesia</sub>
</div>
