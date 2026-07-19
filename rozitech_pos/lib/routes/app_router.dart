import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/license/license_manager.dart';
import '../core/providers/role_providers.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/users/presentation/providers/user_session_notifier.dart';
import '../features/users/presentation/screens/login_screen.dart';
import '../features/users/domain/entities/user.dart';
import '../features/license/presentation/pages/activation_page.dart';
import '../features/license/presentation/pages/license_page.dart';
import '../features/products/presentation/pages/products_page.dart';
import '../features/products/presentation/pages/product_form_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/customers/presentation/pages/customers_page.dart';
import '../features/suppliers/presentation/pages/suppliers_page.dart';
import '../features/sales/presentation/pages/pos_page.dart';
import '../features/sales/presentation/pages/transaction_history_page.dart';
import '../features/inventory/presentation/pages/inventory_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/expenses/presentation/pages/expenses_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/payment_gateway_settings_page.dart';
import '../features/settings/presentation/screens/printer_settings_screen.dart';
import '../features/payment/presentation/pages/payment_selector_page.dart';
import '../features/backup/presentation/pages/backup_page.dart';
import '../features/ai/presentation/pages/ai_assistant_page.dart';
import '../shared/widgets/main_shell.dart';
import '../shared/widgets/role_guard.dart';
import 'splash_page.dart';

// Named route constants
abstract final class AppRoutes {
  static const splash = '/';
  static const activation = '/activation';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const productAdd = '/products/add';
  static const productEdit = '/products/edit/:id';
  static const categories = '/categories';
  static const customers = '/customers';
  static const suppliers = '/suppliers';
  static const pos = '/pos';
  static const transactions = '/transactions';
  static const inventory = '/inventory';
  static const reports = '/reports';
  static const expenses = '/expenses';
  static const settings = '/settings';
  static const settingsPrinter = '/settings/printer';
  static const settingsPaymentGateway = '/settings/payment-gateway';
  static const payment = '/payment';
  static const license = '/license';
  static const backup = '/backup';
  static const ai = '/ai';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Helper: buat builder yang otomatis guard ke AccessDeniedPage
Widget _guardedPage({
  required WidgetRef ref,
  required bool Function(UserRole) permission,
  required Widget child,
  String? deniedMessage,
}) {
  final role = ref.read(currentRoleProvider) ?? UserRole.cashier;
  if (permission(role)) return child;
  return AccessDeniedPage(message: deniedMessage);
}

/// App router provider — uses [licenseStatusProvider] for redirect logic.
final routerProvider = Provider<GoRouter>((ref) {
  final licenseStatusAsync = ref.watch(licenseStatusProvider);
  final userSession = ref.watch(userSessionProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // While loading, stay on splash
      if (licenseStatusAsync.isLoading) return null;

      final status = licenseStatusAsync.valueOrNull;
      final isOnActivation = state.matchedLocation == AppRoutes.activation;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;

      // 1. License Check
      if (status == LicenseStatus.notFound || status == LicenseStatus.expired) {
        if (!isOnActivation) return AppRoutes.activation;
        return null;
      }

      // 2. User Login Check
      final isLoggedIn = userSession.isLoggedIn;
      final isSessionLoading = userSession.isLoading;

      if (isSessionLoading && isOnSplash) return null;

      if (!isLoggedIn && !isSessionLoading) {
        if (!isOnLogin && !isOnActivation && !isOnSplash) {
          return AppRoutes.login;
        }
        return null;
      }

      // 3. Prevent going to Login/Activation if already logged in
      if (isLoggedIn && (isOnLogin || isOnActivation)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // ─── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),

      // ─── License Activation (no shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.activation,
        builder: (_, __) => const ActivationPage(),
      ),

      // ─── User Login (no shell) ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),

      // ─── Payment Selector (full screen, no shell) ───────────────────────────
      GoRoute(
        path: AppRoutes.payment,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final totalStr = state.uri.queryParameters['total'] ?? '0';
          final total = double.tryParse(totalStr) ?? 0;
          return PaymentSelectorPage(totalAmount: total);
        },
      ),

      // ─── Printer Settings (full screen, no shell) ───────────────────────────
      GoRoute(
        path: AppRoutes.settingsPrinter,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PrinterSettingsScreen(),
      ),

      // ─── Payment Gateway Settings (full screen, no shell) ──────────────────
      GoRoute(
        path: AppRoutes.settingsPaymentGateway,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PaymentGatewaySettingsPage(),
      ),

      // ─── Main Shell (side nav + bottom nav) ────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Dashboard — semua role bisa, konten berbeda (diatur di DashboardPage)
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),

          // POS — semua role bisa
          GoRoute(
            path: AppRoutes.pos,
            builder: (_, __) => const PosPage(),
          ),

          // Transaksi — semua role bisa (kasir hanya lihat transaksinya sendiri)
          GoRoute(
            path: AppRoutes.transactions,
            builder: (_, __) => const TransactionHistoryPage(),
          ),

          // Produk — semua bisa lihat, kasir tidak bisa edit (diatur di ProductsPage)
          GoRoute(
            path: AppRoutes.products,
            builder: (_, __) => const ProductsPage(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) {
                  return Consumer(
                    builder: (ctx, ref, _) => _guardedPage(
                      ref: ref,
                      permission: (r) => r.canEditProducts,
                      child: const ProductFormPage(),
                      deniedMessage: 'Hanya Manajer dan Pemilik yang dapat menambah produk.',
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) {
                  return Consumer(
                    builder: (ctx, ref, _) => _guardedPage(
                      ref: ref,
                      permission: (r) => r.canEditProducts,
                      child: ProductFormPage(
                        productId: int.tryParse(state.pathParameters['id'] ?? ''),
                      ),
                      deniedMessage: 'Hanya Manajer dan Pemilik yang dapat mengedit produk.',
                    ),
                  );
                },
              ),
            ],
          ),

          // Kategori — hanya manager/owner
          GoRoute(
            path: AppRoutes.categories,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canManageCategories,
                child: const CategoriesPage(),
                deniedMessage: 'Hanya Manajer dan Pemilik yang dapat mengelola kategori.',
              ),
            ),
          ),

          // Pelanggan — manager/owner
          GoRoute(
            path: AppRoutes.customers,
            builder: (_, __) => const CustomersPage(), // akses lihat semua bisa, edit diatur di dalam page
          ),

          // Supplier — hanya manager/owner
          GoRoute(
            path: AppRoutes.suppliers,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canViewSuppliers,
                child: const SuppliersPage(),
                deniedMessage: 'Hanya Manajer dan Pemilik yang dapat mengakses data supplier.',
              ),
            ),
          ),

          // Inventaris — hanya manager/owner
          GoRoute(
            path: AppRoutes.inventory,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canViewInventory,
                child: const InventoryPage(),
                deniedMessage: 'Hanya Manajer dan Pemilik yang dapat melihat inventaris.',
              ),
            ),
          ),

          // Laporan — hanya manager/owner
          GoRoute(
            path: AppRoutes.reports,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canViewReports,
                child: const ReportsPage(),
                deniedMessage: 'Hanya Manajer dan Pemilik yang dapat melihat laporan.',
              ),
            ),
          ),

          // Pengeluaran — manager/owner (kasir tidak bisa)
          GoRoute(
            path: AppRoutes.expenses,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canManageExpenses,
                child: const ExpensesPage(),
                deniedMessage: 'Hanya Manajer dan Pemilik yang dapat mengelola pengeluaran.',
              ),
            ),
          ),

          // Pengaturan — semua bisa akses, konten dibatasi di dalam SettingsPage
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsPage(),
          ),

          // Lisensi — hanya owner
          GoRoute(
            path: AppRoutes.license,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canManageLicense,
                child: const LicensePage(),
                deniedMessage: 'Hanya Pemilik yang dapat mengelola lisensi.',
              ),
            ),
          ),

          // Backup & Sync — hanya manager/owner
          GoRoute(
            path: AppRoutes.backup,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canAccessBackup,
                child: const BackupPage(),
                deniedMessage: 'Hanya Manajer dan Pemilik yang dapat mengakses backup.',
              ),
            ),
          ),

          // AI Asisten — hanya manager/owner
          GoRoute(
            path: AppRoutes.ai,
            builder: (_, __) => Consumer(
              builder: (ctx, ref, _) => _guardedPage(
                ref: ref,
                permission: (r) => r.canAccessAI,
                child: const AiAssistantPage(),
                deniedMessage: 'Hanya Manajer dan Pemilik yang dapat mengakses AI Asisten.',
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Halaman tidak ditemukan\n${state.error}',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
});
