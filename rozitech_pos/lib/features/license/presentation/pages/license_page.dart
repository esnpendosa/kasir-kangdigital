import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/license/license_manager.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/extensions.dart';

final _currentLicenseProvider = FutureProvider<License?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.select(db.licenses).get();
  return rows.isNotEmpty ? rows.last : null;
});

/// License info page within the main shell (settings area).
class LicensePage extends ConsumerWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licenseAsync = ref.watch(licenseStatusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lisensi')),
      body: licenseAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (status) {
          final isValid = status == LicenseStatus.valid;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isValid
                          ? [const Color(0xFF059669), const Color(0xFF0284C7)]
                          : [const Color(0xFFDC2626), const Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isValid
                            ? Icons.verified_rounded
                            : Icons.gpp_bad_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isValid ? 'Lisensi Aktif' : 'Lisensi Tidak Valid',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isValid
                            ? 'Aplikasi Anda terlisensi dan siap digunakan'
                            : 'Silakan aktifkan lisensi Anda',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(),

                const SizedBox(height: 24),

                // Info tiles
                _InfoCard(
                  icon: Icons.apps_rounded,
                  label: 'Aplikasi',
                  value: 'CASIR v1.0.0',
                ),
                ref.watch(_currentLicenseProvider).when(
                      data: (license) {
                        if (license == null) return const SizedBox.shrink();
                        return Column(
                          children: [
                            _InfoCard(
                              icon: Icons.key_rounded,
                              label: 'Kunci Lisensi',
                              value: license.licenseKey,
                            ),
                            if (license.activatedAt != null)
                              _InfoCard(
                                icon: Icons.calendar_today_rounded,
                                label: 'Tanggal Aktivasi',
                                value: license.activatedAt!.toDateTimeString(),
                              ),
                            _InfoCard(
                              icon: Icons.event_busy_rounded,
                              label: 'Tanggal Kadaluarsa',
                              value: license.expiresAt != null
                                  ? license.expiresAt!.toDateString()
                                  : 'Selamanya (Lifetime)',
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                _InfoCard(
                  icon: Icons.business_rounded,
                  label: 'Developer',
                  value: 'Kang Digital',
                ),
                _InfoCard(
                  icon: Icons.language_rounded,
                  label: 'Website',
                  value: 'https://kangdigital.web.id',
                ),

                const SizedBox(height: 24),

                if (isValid)
                  OutlinedButton.icon(
                    onPressed: () => _confirmDeactivate(context, ref),
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.red),
                    label: const Text('Nonaktifkan Lisensi',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize:
                          const Size(double.infinity, 48),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeactivate(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nonaktifkan Lisensi?'),
        content: const Text(
            'Aplikasi tidak dapat digunakan sampai Anda mengaktifkan lisensi baru.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nonaktifkan',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(licenseManagerProvider).deactivate();
      ref.invalidate(licenseStatusProvider);
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.5))),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
