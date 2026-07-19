# 🤝 Panduan Kontribusi — Rozitech POS

Terima kasih telah tertarik berkontribusi pada **Rozitech POS**!
Dokumen ini menjelaskan standar, alur kerja, dan konvensi yang digunakan di proyek ini.

---

## 📋 Daftar Isi

1. [Setup Lingkungan Pengembangan](#1-setup-lingkungan-pengembangan)
2. [Alur Kerja Git](#2-alur-kerja-git)
3. [Konvensi Commit](#3-konvensi-commit)
4. [Standar Kode Dart/Flutter](#4-standar-kode-dartflutter)
5. [Arsitektur Feature Module](#5-arsitektur-feature-module)
6. [Menambah Fitur Baru](#6-menambah-fitur-baru)
7. [Menambah Tabel Database Baru](#7-menambah-tabel-database-baru)
8. [Standar UI/UX](#8-standar-uiux)
9. [Testing](#9-testing)
10. [Pull Request Checklist](#10-pull-request-checklist)

---

## 1. Setup Lingkungan Pengembangan

### Prasyarat

```bash
# Flutter Stable channel
flutter channel stable
flutter upgrade

# Verifikasi
flutter doctor -v
```

### Clone dan Install

```bash
git clone https://github.com/esnpendosa/Chasir.git
cd Chasir/rozitech_pos
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### IDE yang Direkomendasikan

- **Visual Studio Code** dengan ekstensi:
  - Flutter
  - Dart
  - Riverpod Snippets
  - Error Lens
  - GitLens

- **Android Studio / IntelliJ IDEA** dengan plugin Flutter & Dart

### Konfigurasi VS Code (`settings.json`)

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit"
  },
  "dart.lineLength": 100,
  "dart.showTodos": true
}
```

---

## 2. Alur Kerja Git

### Branch Strategy

```
main                    ← Production-ready (protected)
  └── develop           ← Integration branch
        ├── feature/*   ← Fitur baru
        ├── fix/*       ← Bug fix
        ├── refactor/*  ← Refactoring
        └── docs/*      ← Dokumentasi
```

### Alur Pengembangan

```bash
# 1. Update develop
git checkout develop
git pull origin develop

# 2. Buat branch baru
git checkout -b feature/pos-barcode-scanner

# 3. Koding & commit bertahap
git add .
git commit -m "feat(sales): tambah integrasi mobile_scanner untuk POS"

# 4. Push branch
git push origin feature/pos-barcode-scanner

# 5. Buat Pull Request → develop
# 6. Setelah review & approve → merge
# 7. Hapus branch lokal setelah merge
git branch -d feature/pos-barcode-scanner
```

---

## 3. Konvensi Commit

Gunakan format **Conventional Commits**:

```
<type>(<scope>): <deskripsi singkat>

[body opsional — jelaskan WHY bukan WHAT]

[footer opsional — closes #issue]
```

### Types

| Type | Kapan Digunakan |
|------|----------------|
| `feat` | Fitur baru |
| `fix` | Perbaikan bug |
| `refactor` | Refactoring (tanpa perubahan fungsional) |
| `docs` | Perubahan dokumentasi saja |
| `style` | Formatting, whitespace (tanpa perubahan logika) |
| `test` | Tambah atau perbaiki test |
| `chore` | Update dependency, konfigurasi CI, dll |
| `perf` | Peningkatan performa |
| `build` | Perubahan build system (pubspec, gradle, dll) |

### Scopes

| Scope | Modul |
|-------|-------|
| `core` | Core utilities, config, database |
| `license` | Sistem lisensi |
| `dashboard` | Dashboard & KPI |
| `products` | Manajemen produk |
| `sales` | POS & transaksi |
| `inventory` | Inventaris stok |
| `reports` | Laporan |
| `customers` | Pelanggan |
| `suppliers` | Supplier |
| `expenses` | Pengeluaran |
| `settings` | Pengaturan |
| `backup` | Backup/restore |
| `ai` | AI Asisten |
| `theme` | Tema & warna |
| `router` | Navigasi |

### Contoh

```bash
feat(sales): tambah barcode scanner ke halaman POS
fix(products): perbaiki validasi harga yang menerima nilai negatif
refactor(core): ekstrak invoice generator ke utility class
docs(readme): update instruksi setup untuk Windows
chore(deps): upgrade flutter_riverpod ke 2.6.0
```

---

## 4. Standar Kode Dart/Flutter

### Formatting

```bash
# Format semua file
dart format lib/ test/

# Cek tanpa mengubah
dart format --output=none lib/
```

### Linting

```bash
flutter analyze
```

### Aturan Umum

```dart
// ✅ BENAR: final untuk variabel yang tidak diubah
final username = 'admin';
const maxRetry = 3;

// ❌ SALAH: var jika tidak perlu reassignment
var username = 'admin';

// ✅ BENAR: Named parameters untuk fungsi > 2 argumen
void adjustStock({
  required int productId,
  required double quantity,
  required String type,
});

// ✅ BENAR: Gunakan Result<T> untuk operasi yang bisa gagal
Future<Result<int>> createProduct(ProductsCompanion data);

// ❌ SALAH: Jangan throw exception lintas layer
Future<int> createProduct(ProductsCompanion data) async {
  throw Exception('error'); // Jangan ini
}

// ✅ BENAR: Dokumentasi public API
/// Menghitung kembalian dari pembayaran tunai.
///
/// [cashAmount] harus >= [total] sinon kembalian negatif.
double calculateChange(double cashAmount, double total) {
  return cashAmount - total;
}
```

### Import Order

```dart
// 1. Dart SDK
import 'dart:io';
import 'dart:convert';

// 2. Flutter packages
import 'package:flutter/material.dart';

// 3. External packages (pub.dev)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. Internal project imports (relatif)
import '../../../../core/database/app_database.dart';
import '../../data/repositories/product_repository.dart';
```

---

## 5. Arsitektur Feature Module

Setiap fitur mengikuti struktur berikut:

```
features/<feature_name>/
├── data/
│   ├── repositories/
│   │   └── <feature>_repository.dart   ← Drift queries & API calls
│   └── datasources/                    ← (opsional) Remote/Local datasource
├── domain/                             ← (siap digunakan)
│   ├── entities/                       ← Business objects
│   └── usecases/                       ← Business logic
└── presentation/
    ├── pages/
    │   └── <feature>_page.dart         ← Screen (ConsumerWidget)
    └── widgets/
        └── <widget_name>.dart          ← Sub-widgets
```

### Aturan Dependency

```
presentation → data (repository)
presentation → core (database, utils)
data → core (database, network, utils)
core → external packages ONLY
```

**Presentasi TIDAK BOLEH** mengakses database langsung — selalu lewat repository.

---

## 6. Menambah Fitur Baru

### Contoh: Menambah Fitur Diskon

#### Step 1: Repository

```dart
// lib/features/discounts/data/repositories/discount_repository.dart

class DiscountRepository {
  DiscountRepository(this._db);
  final AppDatabase _db;

  Stream<List<Discount>> watchAll() {
    return _db.select(_db.discounts).watch();
  }

  Future<Result<int>> create(DiscountsCompanion companion) async {
    try {
      final id = await _db.into(_db.discounts).insert(companion);
      return Success(id);
    } catch (e) {
      return Failure('Gagal menyimpan diskon: $e', e);
    }
  }
}

final discountRepositoryProvider = Provider<DiscountRepository>(
  (ref) => DiscountRepository(ref.watch(databaseProvider)),
);
```

#### Step 2: Provider Stream

```dart
final discountsStreamProvider = StreamProvider<List<Discount>>((ref) {
  return ref.watch(discountRepositoryProvider).watchAll();
});
```

#### Step 3: Page

```dart
// lib/features/discounts/presentation/pages/discounts_page.dart

class DiscountsPage extends ConsumerWidget {
  const DiscountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discountsAsync = ref.watch(discountsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diskon')),
      body: discountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (discounts) => _DiscountList(discounts: discounts),
      ),
    );
  }
}
```

#### Step 4: Daftarkan Route

```dart
// lib/routes/app_router.dart
GoRoute(
  path: '/discounts',
  builder: (_, __) => const DiscountsPage(),
),
```

#### Step 5: Tambahkan ke Navigation Shell

```dart
// lib/shared/widgets/main_shell.dart
// Tambahkan entry ke _destinations list
```

---

## 7. Menambah Tabel Database Baru

#### Step 1: Definisi Tabel

```dart
// lib/core/database/app_database.dart

class Discounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get percentage => real()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### Step 2: Daftarkan ke AppDatabase

```dart
@DriftDatabase(tables: [
  // ... tabel yang sudah ada
  Discounts, // ← tambahkan di sini
])
class AppDatabase extends _$AppDatabase {
```

#### Step 3: Naikkan versi schema

```dart
@override
int get schemaVersion => 2; // naik dari 1 ke 2

@override
MigrationStrategy get migration => MigrationStrategy(
  from: 1,
  to: 2,
  migrate: (m) async {
    await m.createTable(discounts);
  },
);
```

#### Step 4: Regenerate kode Drift

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 8. Standar UI/UX

### Theme System

Selalu gunakan warna dari `ColorScheme`, **jangan hardcode hex**:

```dart
// ✅ BENAR
Container(color: Theme.of(context).colorScheme.surface)
Icon(Icons.star, color: cs.primary)

// ❌ SALAH
Container(color: Colors.white)
Container(color: Color(0xFF6366F1))
```

### Spacing & Sizing

Gunakan kelipatan 4:

```dart
// ✅ Standard spacing
const SizedBox(height: 8)   // xs
const SizedBox(height: 12)  // sm
const SizedBox(height: 16)  // md
const SizedBox(height: 24)  // lg
const SizedBox(height: 32)  // xl

// ✅ Standard border radius
BorderRadius.circular(8)   // chip, tag
BorderRadius.circular(12)  // button, input
BorderRadius.circular(16)  // card
BorderRadius.circular(20)  // bottom sheet
BorderRadius.circular(24)  // dialog
```

### Animasi

Gunakan `flutter_animate` untuk micro-animations:

```dart
// Fade in dari bawah
Widget().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2)

// Scale dari tengah
Widget().animate().scale(curve: Curves.easeOutBack)

// Shimmer loading
Widget().animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: cs.surface)
```

### Responsif

```dart
// Gunakan breakpoint 768px untuk mobile/tablet
final isWide = MediaQuery.sizeOf(context).width >= 768;

// Contoh
isWide
  ? NavigationRail(...)
  : NavigationBar(...)
```

---

## 9. Testing

### Unit Test Repository

```dart
// test/features/products/product_repository_test.dart

void main() {
  late AppDatabase db;
  late ProductRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProductRepository(db);
  });

  tearDown(() => db.close());

  test('create product returns success', () async {
    final result = await repo.create(
      ProductsCompanion.insert(
        name: 'Test Product',
        price: 10000,
        cost: Value(8000),
      ),
    );
    expect(result, isA<Success<int>>());
  });
}
```

### Menjalankan Test

```bash
flutter test
flutter test --coverage
```

---

## 10. Pull Request Checklist

Sebelum membuat PR, pastikan:

- [ ] `flutter analyze` tidak mengeluarkan **error**
- [ ] `dart format` sudah dijalankan
- [ ] `flutter pub run build_runner build` dijalankan jika ada perubahan schema
- [ ] PR description menjelaskan: apa yang diubah, mengapa, dan cara test
- [ ] Screenshot/recording untuk perubahan UI
- [ ] Tidak ada `print()` statement yang tertinggal
- [ ] Semua string user-facing menggunakan Bahasa Indonesia
- [ ] `Result<T>` digunakan untuk operasi yang bisa gagal
- [ ] Tidak ada hardcoded color/string di widget

---

## 📞 Butuh Bantuan?

Buka [GitHub Issue](https://github.com/esnpendosa/Chasir/issues) atau hubungi tim Rozitech di [rozitech.co.id](https://rozitech.co.id).
