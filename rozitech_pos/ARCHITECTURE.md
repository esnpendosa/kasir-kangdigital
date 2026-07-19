# 🏗️ Arsitektur Rozitech POS

## Diagram Arsitektur Keseluruhan

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                          │
│                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │
│  │ SplashPage│  │ PosPage  │  │Dashboard │  │ProductsPage  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘   │
│       │              │              │                │            │
│       └──────────────┴──────────────┴────────────────┘            │
│                              │                                    │
│                    Riverpod Providers                             │
│                              │                                    │
└──────────────────────────────┼────────────────────────────────────┘
                               │
┌──────────────────────────────┼────────────────────────────────────┐
│                          DATA LAYER                               │
│                              │                                    │
│  ┌───────────────────────────▼──────────────────────────────┐    │
│  │              Repositories                                  │    │
│  │  ProductRepository | CartRepository | LicenseManager      │    │
│  └───────────────────────────┬──────────────────────────────┘    │
│                              │                                    │
│         ┌────────────────────┼───────────────────┐               │
│         │                    │                   │               │
│  ┌──────▼──────┐    ┌────────▼──────┐   ┌───────▼───────┐       │
│  │ AppDatabase  │    │  Dio Client   │   │ SecureStorage │       │
│  │  (Drift)     │    │  (REST API)   │   │ (JWT/Token)   │       │
│  └──────┬──────┘    └───────────────┘   └───────────────┘       │
│         │                                                        │
└─────────┼──────────────────────────────────────────────────────  ┘
          │
┌─────────▼────────────────┐
│      SQLite Database      │
│  (app_database.db)        │
│  Platform path:           │
│  Android: /data/data/.../│
│  Windows: %APPDATA%/.../  │
└───────────────────────────┘
```

---

## State Management Flow (Riverpod)

```
Widget (ConsumerWidget)
    │
    │ ref.watch(provider)
    ▼
Provider Layer
    │
    ├── StateProvider<T>          → Simple mutable state (search, filter)
    ├── FutureProvider<T>         → Async one-shot (license check)
    ├── StreamProvider<T>         → Reactive DB stream (products list)
    └── NotifierProvider<N, T>   → Complex state with methods (cart)
            │
            ▼
    Repository / Manager
            │
            ▼
    AppDatabase (Drift) / Dio (HTTP)
```

---

## Navigation Flow

```
App Start
    │
    ▼
SplashPage (/)
    │
    ├── [License Loading] → Stay on Splash
    ├── [License Valid]   → /dashboard (via GoRouter redirect)
    └── [License Invalid] → /activation

/activation
    │
    └── [Activated] → /dashboard (via ref.invalidate)

/dashboard  (inside ShellRoute = MainShell)
    ├── /products
    │     ├── /products/add
    │     └── /products/edit/:id
    ├── /pos
    ├── /transactions
    ├── /inventory
    ├── /reports
    ├── /categories
    ├── /customers
    ├── /suppliers
    ├── /expenses
    ├── /settings
    ├── /license
    ├── /backup
    └── /ai
```

---

## Database Schema Detail

### Tabel `products`

| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|-----------|
| `id` | INTEGER | PK, AutoIncrement | |
| `name` | TEXT | NOT NULL | Nama produk |
| `sku` | TEXT | NULLABLE | Kode produk |
| `barcode` | TEXT | NULLABLE | Barcode EAN/QR |
| `description` | TEXT | NULLABLE | Deskripsi |
| `price` | REAL | NOT NULL | Harga jual |
| `cost` | REAL | DEFAULT 0 | Harga modal |
| `stock` | REAL | DEFAULT 0 | Stok saat ini |
| `min_stock` | REAL | DEFAULT 0 | Batas stok minimum |
| `tax` | REAL | DEFAULT 0 | Tarif pajak (%) |
| `category_id` | INTEGER | FK → categories | |
| `image_path` | TEXT | NULLABLE | Path gambar lokal |
| `is_active` | BOOLEAN | DEFAULT true | Soft delete flag |
| `track_stock` | BOOLEAN | DEFAULT true | Lacak stok? |
| `created_at` | DATETIME | DEFAULT now | |
| `updated_at` | DATETIME | NULLABLE | |

### Tabel `transactions`

| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| `id` | INTEGER PK | |
| `invoice_number` | TEXT | Format: INV-YYYYMMDD-XXXX |
| `customer_id` | INTEGER FK | Nullable (pelanggan umum) |
| `subtotal` | REAL | Sebelum diskon global |
| `discount_amount` | REAL | Nominal diskon |
| `tax_amount` | REAL | Nominal pajak |
| `total` | REAL | Total yang harus dibayar |
| `cash_amount` | REAL | Uang yang diterima |
| `change_amount` | REAL | Kembalian |
| `payment_method` | TEXT | cash/transfer/card |
| `status` | TEXT | completed/voided/refunded |
| `notes` | TEXT | Catatan |
| `created_at` | DATETIME | Waktu transaksi |

### Tabel `transaction_items`

| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| `id` | INTEGER PK | |
| `transaction_id` | INTEGER FK | → transactions |
| `product_id` | INTEGER FK | → products |
| `product_name` | TEXT | Snapshot nama produk |
| `product_sku` | TEXT | Snapshot SKU |
| `price` | REAL | Harga saat transaksi |
| `cost` | REAL | Modal saat transaksi |
| `quantity` | REAL | Jumlah |
| `discount` | REAL | Diskon per item (%) |
| `tax` | REAL | Pajak per item (%) |
| `subtotal` | REAL | Total per item |

---

## License System Detail

### JWT Validation Flow

```
checkLocalLicense()
    │
    ├── Read JWT from FlutterSecureStorage
    │       │
    │       └── [null] → LicenseStatus.notFound
    │
    ├── Query licenses table from Drift DB
    │       │
    │       └── [empty] → LicenseStatus.notFound
    │
    ├── Check license.status == 'active'
    │       │
    │       └── [not active] → LicenseStatus.expired
    │
    ├── Check license.expires_at vs DateTime.now()
    │       │
    │       └── [expired] → LicenseStatus.expired
    │
    ├── Check last_checked_at interval >= 30 days
    │       │
    │       └── [due] → _reCheckOnline(token) [BACKGROUND, non-blocking]
    │
    └── → LicenseStatus.valid
```

### Secure Storage Keys

| Key | Nilai |
|-----|-------|
| `rz_license_token` | JWT access token |
| `rz_license_key` | License key string |

---

## Error Handling Pattern

```dart
// Result<T> digunakan di semua operasi yang bisa gagal

sealed class Result<T> {
  bool get isSuccess;
  bool get isFailure;
  T? get dataOrNull;
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Object? error) onFailure,
  });
}

final class Success<T> extends Result<T> { final T data; }
final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
}

// Pola penggunaan di UI
final result = await repo.create(companion);
result.fold(
  onSuccess: (id) => context.pop(true),
  onFailure: (msg, _) => showSnackBar(msg),
);
```

---

## Dependency Injection

Semua dependency di-inject melalui Riverpod Provider — tidak ada service locator manual:

```dart
// Database (singleton)
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// Repository (depends on database)
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(databaseProvider)),
);

// Use in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(productRepositoryProvider);
    // ...
  }
}
```

---

## Naming Conventions

| Komponen | Konvensi | Contoh |
|----------|----------|--------|
| File | `snake_case.dart` | `product_repository.dart` |
| Class | `PascalCase` | `ProductRepository` |
| Method | `camelCase` | `getById()`, `watchAll()` |
| Variable | `camelCase` | `productId`, `isLoading` |
| Constant | `camelCase` | `appVersion`, `apiBaseUrl` |
| Provider | `camelCase + Provider` | `productRepositoryProvider` |
| Page | `PascalCase + Page` | `ProductsPage` |
| Widget | `_PascalCase` (private) | `_ProductCard` |
| Table | `PascalCase` | `Products`, `Transactions` |
| Companion | `TableNameCompanion` | `ProductsCompanion` |
