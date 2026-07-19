import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/role_providers.dart';
import '../../features/users/domain/entities/user.dart';

/// Widget yang hanya menampilkan [child] jika kondisi permission terpenuhi.
///
/// Jika tidak punya akses:
/// - Secara default tampilkan [fallback] (defaultnya: widget kosong)
/// - Set [showFallback] = true untuk tampilkan pesan "Akses Ditolak"
///
/// Penggunaan:
/// ```dart
/// RoleGuard(
///   permission: (role) => role.canEditProducts,
///   child: ElevatedButton(onPressed: _edit, child: Text('Edit')),
/// )
/// ```
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.showFallback = false,
  });

  /// Fungsi yang menerima [UserRole] dan mengembalikan bool apakah diizinkan
  final bool Function(UserRole role) permission;

  /// Widget yang ditampilkan jika punya akses
  final Widget child;

  /// Widget alternatif jika tidak punya akses (opsional)
  final Widget? fallback;

  /// Jika true dan fallback null, tampilkan pesan default "Akses Ditolak"
  final bool showFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);

    if (role == null) return const SizedBox.shrink();

    final hasAccess = permission(role);

    if (hasAccess) return child;

    if (fallback != null) return fallback!;

    if (showFallback) return const _AccessDeniedWidget();

    return const SizedBox.shrink();
  }
}

/// Widget "Akses Ditolak" default — ditampilkan sebagai halaman penuh
class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline_rounded, color: cs.error, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                'Akses Ditolak',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                message ?? 'Anda tidak memiliki izin untuk mengakses fitur ini.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline widget kecil "Akses Ditolak"
class _AccessDeniedWidget extends StatelessWidget {
  const _AccessDeniedWidget();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: cs.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Fitur ini memerlukan hak akses lebih tinggi.',
              style: TextStyle(color: cs.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge label role untuk ditampilkan di UI
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, icon) = switch (role) {
      UserRole.owner => (const Color(0xFFF59E0B), Icons.verified_rounded),
      UserRole.manager => (const Color(0xFF6C63FF), Icons.manage_accounts_rounded),
      UserRole.cashier => (const Color(0xFF10B981), Icons.point_of_sale_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            role.label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
