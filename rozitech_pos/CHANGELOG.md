# 📋 Changelog — Rozitech POS

Semua perubahan penting pada proyek ini akan didokumentasikan di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
dan proyek ini mengikuti [Semantic Versioning](https://semver.org/lang/id/).

---

## [Unreleased]

### Planned
- Integrasi Bluetooth thermal printer (58mm/80mm)
- Scan barcode via kamera menggunakan mobile_scanner
- Laporan dari data Drift nyata (bukan mock)
- Persistensi pengaturan toko ke database
- Export laporan ke Excel dan PDF

---

## [1.0.0] — 2026-07-10

### Added
- **Arsitektur** — Clean Architecture + Feature-First folder structure
- **Database** — Drift ORM dengan 15 tabel (Products, Transactions, Categories, dll)
- **State Management** — Riverpod dengan Notifier, FutureProvider, StreamProvider
- **Navigasi** — GoRouter dengan shell navigation dan redirect berbasis lisensi
- **Tema** — Material 3 Light & Dark mode dengan brand palette Indigo/Cyan (Outfit font)

#### Modul License
- Aktivasi lisensi via API online
- Validasi JWT lokal dari FlutterSecureStorage
- Re-validasi background otomatis setiap 30 hari
- Deaktivasi lisensi
- Halaman aktivasi animasi (`ActivationPage`)
- Halaman status lisensi (`LicensePage`)

#### Modul POS / Kasir
- Grid produk responsif dengan animasi tap-to-add
- Keranjang belanja dengan quantity control
- Numpad khusus dengan tombol quick amount
- Kalkulasi subtotal, diskon, pajak, kembalian
- Checkout dengan simpan transaksi ke database
- Penyesuaian stok otomatis saat checkout
- Dialog sukses setelah pembayaran
- Layout responsif (mobile/tablet/desktop)

#### Modul Produk
- CRUD produk lengkap (tambah, edit, hapus soft-delete)
- Pilih foto produk dari galeri
- Barcode field dengan input manual
- Pelacakan stok (track stock on/off)
- Kategori produk
- Harga jual & harga modal
- Tarif pajak per produk
- Pencarian nama, SKU, barcode (reaktif via Drift stream)

#### Modul Dashboard
- Kartu KPI (Total Penjualan, Transaksi, Produk, Stok Menipis)
- Grafik bar chart penjualan mingguan (fl_chart)
- Daftar transaksi terbaru
- Animasi counter untuk KPI

#### Modul Laporan
- Tab Harian, Bulanan, Ringkasan
- KPI cards per periode
- Top 5 produk terlaris (mock data — live data di v1.2.0)
- Tombol export PDF & Excel (stub)

#### Modul Inventaris
- Tab stok masuk / keluar / log
- Bottom sheet form stok masuk
- Log pergerakan stok

#### Modul Lainnya
- Categories — CRUD kategori dengan ikon berwarna
- Customers — Daftar pelanggan dengan poin loyalitas
- Suppliers — Daftar supplier
- Expenses — Pencatatan pengeluaran dengan kategori
- Settings — Profil toko, struk, keuangan, tema, tentang
- Backup — Backup/restore/export database SQLite
- AI Assistant — UI chat dengan AiService interface stub

#### Core
- `Result<T>` sealed class untuk error handling tanpa exception
- `InvoiceGenerator` — format INV-YYYYMMDD-XXXX
- Extensions: `double.toCurrency()`, `String.toCapitalized()`, `DateTime.toShortDate()`
- `AppTheme` — CardThemeData, DialogThemeData (Flutter 3.x compatible)
- Dio HTTP client dengan interceptors

### Fixed
- `image` package conflict antara `pdf` dan `esc_pos_utils` (override ^4.1.3)
- `CardTheme` → `CardThemeData` untuk Flutter 3.x compatibility
- `DialogTheme` → `DialogThemeData` untuk Flutter 3.x compatibility
- `tooltipBgColor` → `getTooltipColor` untuk fl_chart v0.68+ compatibility
- `LicensePage` ambiguous import dengan `flutter/material.dart` (hide LicensePage)
- `isSmallerOrEqualValue` diganti dengan nilai literal untuk low-stock count

---

[Unreleased]: https://github.com/esnpendosa/Chasir/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/esnpendosa/Chasir/releases/tag/v1.0.0
