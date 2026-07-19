import 'package:equatable/equatable.dart';

/// User roles.
enum UserRole { owner, manager, cashier }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Pemilik';
      case UserRole.manager:
        return 'Manajer';
      case UserRole.cashier:
        return 'Kasir';
    }
  }

  String get name => toString().split('.').last;

  // ─── Feature Permissions ───────────────────────────────────────────────────

  /// Bisa akses halaman Dasbor (semua bisa, tapi isi berbeda)
  bool get canViewDashboard => true;

  /// Bisa mengoperasikan kasir / POS
  bool get canUsePOS => true;

  /// Bisa lihat riwayat transaksi
  bool get canViewTransactions => true;

  /// Bisa batalkan / refund transaksi
  bool get canVoidTransaction =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa tambah/edit/hapus produk
  bool get canEditProducts =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa lihat daftar produk (kasir bisa lihat tapi tidak edit)
  bool get canViewProducts => true;

  /// Bisa kelola kategori
  bool get canManageCategories =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa kelola pelanggan (tambah/edit)
  bool get canManageCustomers =>
      this == UserRole.owner || this == UserRole.manager;

  /// Kasir hanya bisa lihat pelanggan untuk memilih saat transaksi
  bool get canViewCustomers => true;

  /// Bisa kelola supplier
  bool get canManageSuppliers =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa lihat data inventaris
  bool get canViewInventory =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa input stok masuk / update stok
  bool get canEditInventory => this == UserRole.owner;

  /// Bisa lihat laporan keuangan
  bool get canViewReports =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa lihat laporan lengkap (profit, HPP, dll)
  bool get canViewFullReports => this == UserRole.owner;

  /// Bisa input / lihat pengeluaran
  bool get canManageExpenses =>
      this == UserRole.owner || this == UserRole.manager;

  /// Kasir hanya bisa input pengeluaran kecil (petty cash)
  bool get canInputPettyCash => this == UserRole.cashier;

  /// Bisa kelola pengguna / kasir
  bool get canManageUsers => this == UserRole.owner;

  /// Bisa kelola lisensi aplikasi
  bool get canManageLicense => this == UserRole.owner;

  /// Bisa akses pengaturan aplikasi
  bool get canViewSettings => true;

  /// Bisa ubah pengaturan printer, payment gateway, dll
  bool get canEditSettings =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa buka laci kas (cash drawer)
  bool get canOpenCashDrawer => true;

  /// Bisa beri diskon manual saat transaksi
  bool get canGiveDiscount =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa lihat harga modal / HPP produk
  bool get canViewCostPrice =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa akses backup & cloud sync
  bool get canAccessBackup =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa akses AI Assistant
  bool get canAccessAI =>
      this == UserRole.owner || this == UserRole.manager;

  /// Bisa akses menu Supplier
  bool get canViewSuppliers =>
      this == UserRole.owner || this == UserRole.manager;

  // ─── Convenience Checks ────────────────────────────────────────────────────

  bool get isOwner => this == UserRole.owner;
  bool get isManager => this == UserRole.manager;
  bool get isCashier => this == UserRole.cashier;

  /// Apakah role ini punya akses level "manajer atau lebih"
  bool get isManagerOrAbove =>
      this == UserRole.owner || this == UserRole.manager;
}

/// Domain entity for an application user.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.isActive,
    this.passwordHash,
    this.lastLoginAt,
    this.createdAt,
  });

  final int id;
  final String username;
  final String displayName;
  final UserRole role;
  final bool isActive;
  final String? passwordHash;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  static UserRole roleFromString(String s) {
    return UserRole.values.firstWhere(
      (r) => r.name == s,
      orElse: () => UserRole.cashier,
    );
  }

  @override
  List<Object?> get props => [id, username, role, isActive];
}
