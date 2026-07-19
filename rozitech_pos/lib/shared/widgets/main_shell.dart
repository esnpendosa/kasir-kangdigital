import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';
import '../../core/providers/role_providers.dart';
import '../../features/users/domain/entities/user.dart';
import '../../features/users/presentation/providers/user_session_notifier.dart';
import 'role_guard.dart';

/// Navigation destination data model.
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

// ─── Navigasi per Role ───────────────────────────────────────────────────────

/// Bottom nav (mobile) — hanya menu utama sesuai role
List<_NavItem> _getBottomNavItems(UserRole role) {
  // Kasir: Dasbor, Kasir, Riwayat, Pengaturan
  if (role.isCashier) {
    return const [
      _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Dasbor',
        route: AppRoutes.dashboard,
      ),
      _NavItem(
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale_rounded,
        label: 'Kasir',
        route: AppRoutes.pos,
      ),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: 'Transaksi',
        route: AppRoutes.transactions,
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Pengaturan',
        route: AppRoutes.settings,
      ),
    ];
  }

  // Manager & Owner: Dasbor, Kasir, Produk, Laporan, Pengaturan
  return const [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dasbor',
      route: AppRoutes.dashboard,
    ),
    _NavItem(
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale_rounded,
      label: 'Kasir',
      route: AppRoutes.pos,
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Produk',
      route: AppRoutes.products,
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Laporan',
      route: AppRoutes.reports,
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Pengaturan',
      route: AppRoutes.settings,
    ),
  ];
}

/// Sidebar nav (desktop/tablet) — lengkap sesuai role
List<_NavItem> _getSideNavItems(UserRole role) {
  final items = <_NavItem>[
    const _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dasbor',
      route: AppRoutes.dashboard,
    ),
    const _NavItem(
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale_rounded,
      label: 'Kasir',
      route: AppRoutes.pos,
    ),
    const _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Transaksi',
      route: AppRoutes.transactions,
    ),
  ];

  // Produk — kasir hanya lihat, tidak edit (navigasi tetap ditampilkan)
  items.add(const _NavItem(
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
    label: 'Produk',
    route: AppRoutes.products,
  ));

  // Fitur khusus manager & owner
  if (role.isManagerOrAbove) {
    items.addAll([
      const _NavItem(
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
        label: 'Kategori',
        route: AppRoutes.categories,
      ),
      const _NavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people_rounded,
        label: 'Pelanggan',
        route: AppRoutes.customers,
      ),
      const _NavItem(
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping_rounded,
        label: 'Supplier',
        route: AppRoutes.suppliers,
      ),
      const _NavItem(
        icon: Icons.warehouse_outlined,
        activeIcon: Icons.warehouse_rounded,
        label: 'Inventaris',
        route: AppRoutes.inventory,
      ),
      const _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: 'Laporan',
        route: AppRoutes.reports,
      ),
      const _NavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: 'Pengeluaran',
        route: AppRoutes.expenses,
      ),
    ]);
  }

  // AI & Backup — hanya manager/owner
  if (role.isManagerOrAbove) {
    items.addAll([
      const _NavItem(
        icon: Icons.smart_toy_outlined,
        activeIcon: Icons.smart_toy_rounded,
        label: 'AI Asisten',
        route: AppRoutes.ai,
      ),
      const _NavItem(
        icon: Icons.backup_outlined,
        activeIcon: Icons.backup_rounded,
        label: 'Backup',
        route: AppRoutes.backup,
      ),
    ]);
  }

  // Lisensi — hanya owner
  if (role.isOwner) {
    items.add(const _NavItem(
      icon: Icons.verified_user_outlined,
      activeIcon: Icons.verified_user_rounded,
      label: 'Lisensi',
      route: AppRoutes.license,
    ));
  }

  items.add(const _NavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Pengaturan',
    route: AppRoutes.settings,
  ));

  return items;
}

/// Responsive main shell that shows:
/// - NavigationRail (tablet/desktop, width ≥ 768)
/// - NavigationBar (mobile, width < 768)
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 768;
    final location = GoRouterState.of(context).matchedLocation;
    final role = ref.watch(currentRoleProvider) ?? UserRole.cashier;

    return PopScope(
      canPop: location == AppRoutes.dashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.dashboard);
      },
      child: isWide
          ? _WideLayout(child: child, location: location, role: role)
          : _NarrowLayout(child: child, location: location, role: role),
    );
  }
}

/// Desktop / tablet layout with a NavigationRail sidebar.
class _WideLayout extends ConsumerWidget {
  const _WideLayout({
    required this.child,
    required this.location,
    required this.role,
  });
  final Widget child;
  final String location;
  final UserRole role;

  int _selectedIndex(List<_NavItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sideItems = _getSideNavItems(role);
    final idx = _selectedIndex(sideItems);
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(userSessionProvider).user;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────────────────
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                right: BorderSide(color: cs.outlineVariant, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header / Logo
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.secondary],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.point_of_sale_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kasir Kita',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'by Kang Digital',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // ── User Info Card ───────────────────────────────────────────
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _UserInfoCard(user: user),
                  ),

                const Divider(height: 1),

                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    itemCount: sideItems.length,
                    itemBuilder: (context, i) {
                      final item = sideItems[i];
                      final isSelected = i == idx;

                      return _SideNavTile(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => context.go(item.route),
                      );
                    },
                  ),
                ),

                // Version footer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'v1.0.0 • Kang Digital',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Kartu info user di sidebar
class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final role = user.role as UserRole;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primary.withValues(alpha: 0.15),
            child: Text(
              (user.displayName as String).isNotEmpty
                  ? (user.displayName as String)[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.displayName as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                RoleBadge(role: role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavTile extends StatelessWidget {
  const _SideNavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.6),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.7),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile layout with a bottom NavigationBar.
class _NarrowLayout extends ConsumerWidget {
  const _NarrowLayout({
    required this.child,
    required this.location,
    required this.role,
  });
  final Widget child;
  final String location;
  final UserRole role;

  int _selectedIndex(List<_NavItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomItems = _getBottomNavItems(role);
    final idx = _selectedIndex(bottomItems);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant, width: 1)),
        ),
        child: NavigationBar(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          selectedIndex: idx,
          onDestinationSelected: (i) => context.go(bottomItems[i].route),
          destinations: bottomItems
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon, color: cs.primary),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
