import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/backup_service_impl.dart';

final _backupServiceProvider = Provider<BackupServiceImpl>((ref) {
  return BackupServiceImpl(ref.watch(appDatabaseProvider));
});

final _backupsProvider = FutureProvider<List<BackupRecord>>((ref) async {
  return ref.watch(_backupServiceProvider).getBackups();
});

/// Backup & Restore page with real file I/O.
class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final backupsAsync = ref.watch(_backupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Backup action card
          _ActionCard(
            icon: Icons.backup_rounded,
            title: 'Backup Database',
            subtitle: 'Simpan salinan database SQLite ke penyimpanan lokal',
            color: cs.primary,
            buttonLabel: 'Buat Backup Sekarang',
            onPressed: () => _createBackup(context, ref),
          ).animate().fadeIn(delay: 0.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          // Import action card
          _ActionCard(
            icon: Icons.upload_file_rounded,
            title: 'Impor Database',
            subtitle: 'Pulihkan database dari file backup eksternal (.sqlite / .db)',
            color: Colors.orange,
            buttonLabel: 'Pilih File Database',
            onPressed: () => _importBackupFromFile(context, ref),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

          const SizedBox(height: 24),

          // Backup history
          Text(
            'Riwayat Backup',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          backupsAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (backups) {
              if (backups.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 48,
                          color: cs.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('Belum ada backup',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                );
              }
              return Column(
                children: backups.asMap().entries.map((entry) {
                  final i = entry.key;
                  final backup = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder_zip_rounded,
                            color: cs.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                backup.filename,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${BackupServiceImpl.formatSize(backup.fileSize)} · ${backup.createdAt.toDateTimeString()}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_backup_restore_rounded,
                              size: 20, color: cs.primary),
                          onPressed: () =>
                              _restoreBackup(context, ref, backup),
                          tooltip: 'Restore backup',
                        ),
                        IconButton(
                          icon: Icon(Icons.share_rounded,
                              size: 20, color: cs.secondary),
                          onPressed: () =>
                              _shareBackup(context, backup),
                          tooltip: 'Bagikan backup',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 20, color: Colors.red),
                          onPressed: () =>
                              _deleteBackup(context, ref, backup),
                          tooltip: 'Hapus backup',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (i * 50).ms);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Membuat backup...'),
          ],
        ),
      ),
    );

    try {
      final backup =
          await ref.read(_backupServiceProvider).createBackup();
      if (context.mounted) {
        Navigator.pop(context); // close progress dialog
        ref.invalidate(_backupsProvider);
        if (backup != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Backup berhasil: ${backup.filename} (${BackupServiceImpl.formatSize(backup.fileSize)})'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Backup gagal: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _restoreBackup(
      BuildContext context, WidgetRef ref, BackupRecord backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: Text('Peringatan: Seluruh data saat ini akan ditimpa dengan data dari "${backup.filename}". Aplikasi akan ditutup untuk memuat database baru.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memulihkan database...'),
            ],
          ),
        ),
      );

      try {
        await ref.read(_backupServiceProvider).restoreBackup(backup);
        if (context.mounted) {
          Navigator.pop(context); // close progress dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Restore Berhasil'),
              content: const Text('Database berhasil dipulihkan. Aplikasi akan ditutup sekarang. Silakan buka kembali aplikasi CASIR.'),
              actions: [
                FilledButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: const Text('Tutup Aplikasi'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // close progress dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Restore gagal: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _shareBackup(BuildContext context, BackupRecord backup) async {
    try {
      final file = File(backup.filePath);
      if (!await file.exists()) {
        throw Exception('File backup tidak ditemukan.');
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(backup.filePath)],
          text: 'Backup Database CASIR - ${backup.filename}',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membagikan backup: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _importBackupFromFile(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) throw Exception('Path file tidak valid.');

      final filename = result.files.single.name;
      if (!filename.endsWith('.db') && !filename.endsWith('.sqlite')) {
        throw Exception('Format file harus berupa .db atau .sqlite');
      }

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Restore dari File?'),
          content: Text('Peringatan: Seluruh data saat ini akan ditimpa dengan data dari file "$filename". Aplikasi akan ditutup untuk memuat database baru.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memulihkan database...'),
              ],
            ),
          ),
        );

        await ref.read(_backupServiceProvider).restoreFromPath(path);
        
        if (context.mounted) {
          Navigator.pop(context); // close progress dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Restore Berhasil'),
              content: const Text('Database berhasil dipulihkan. Aplikasi akan ditutup sekarang. Silakan buka kembali aplikasi CASIR.'),
              actions: [
                FilledButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: const Text('Tutup Aplikasi'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impor gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteBackup(
      BuildContext context, WidgetRef ref, BackupRecord backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Backup'),
        content: Text('Hapus file "${backup.filename}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(_backupServiceProvider).deleteBackup(backup);
      ref.invalidate(_backupsProvider);
    }
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.buttonLabel,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  backgroundColor: color, foregroundColor: Colors.white),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
