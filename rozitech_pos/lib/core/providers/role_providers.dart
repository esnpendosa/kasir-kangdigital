import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/users/presentation/providers/user_session_notifier.dart';
import '../../features/users/domain/entities/user.dart';

/// Provider untuk mendapatkan role user yang sedang login.
/// Mengembalikan null jika belum login.
final currentRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(userSessionProvider).user?.role;
});

/// Provider shortcut: apakah user punya role manajer atau lebih tinggi
final isManagerOrAboveProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role?.isManagerOrAbove ?? false;
});

/// Provider shortcut: apakah user adalah owner
final isOwnerProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role?.isOwner ?? false;
});

/// Provider shortcut: apakah user adalah kasir
final isCashierProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role?.isCashier ?? false;
});

// ─── Specific Feature Permission Providers ─────────────────────────────────

final canEditProductsProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canEditProducts ?? false;
});

final canViewReportsProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canViewReports ?? false;
});

final canViewFullReportsProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canViewFullReports ?? false;
});

final canManageExpensesProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canManageExpenses ?? false;
});

final canManageUsersProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canManageUsers ?? false;
});

final canManageLicenseProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canManageLicense ?? false;
});

final canViewInventoryProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canViewInventory ?? false;
});

final canEditInventoryProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canEditInventory ?? false;
});

final canVoidTransactionProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canVoidTransaction ?? false;
});

final canGiveDiscountProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canGiveDiscount ?? false;
});

final canViewCostPriceProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canViewCostPrice ?? false;
});

final canAccessBackupProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canAccessBackup ?? false;
});

final canAccessAIProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canAccessAI ?? false;
});

final canManageSuppliersProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canManageSuppliers ?? false;
});

final canEditSettingsProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canEditSettings ?? false;
});

final canManageCategoriesProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canManageCategories ?? false;
});

final canManageCustomersProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider)?.canManageCustomers ?? false;
});
