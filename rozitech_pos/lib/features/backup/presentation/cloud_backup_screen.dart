import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/providers/cloud_providers.dart';
import '../../../core/services/cloud_backup_service.dart';
import '../../../core/config/app_config.dart';

/// Cloud Backup Screen — Upload/download backup database ke/dari server hPanel
///
/// Fitur:
/// - Upload backup SQLite ke cloud (kangdigital.web.id)
/// - List semua backup tersimpan di cloud
/// - Download backup dari cloud ke device
/// - Hapus backup lama
class CloudBackupScreen extends ConsumerStatefulWidget {
  final int storeId;
  final String storeName;

  const CloudBackupScreen({super.key, required this.storeId, required this.storeName});

  @override
  ConsumerState<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends ConsumerState<CloudBackupScreen> {
  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(backupNotifierProvider);
    final backupsAsync = ref.watch(backupListProvider(widget.storeId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cloud Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.storeName, style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(backupListProvider(widget.storeId)),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Upload Banner ────────────────────────────────────────────────
          _buildUploadSection(uploadState),

          // ─── Backup List ──────────────────────────────────────────────────
          Expanded(
            child: backupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
              error: (e, _) => _buildErrorWidget(e.toString()),
              data: (backups) => backups.isEmpty
                  ? _buildEmptyWidget()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: backups.length,
                      itemBuilder: (ctx, i) => _buildBackupCard(backups[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(BackupUploadState uploadState) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withAlpha(40),
            const Color(0xFF1A1A2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withAlpha(80)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Upload button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_upload, color: Color(0xFF6C63FF), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Backup ke Cloud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      'Simpan database ke server\nkangdigital.web.id',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: uploadState.isUploading ? null : () => _startUpload(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: uploadState.isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Upload', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          // Progress bar
          if (uploadState.isUploading || (uploadState.progress > 0 && uploadState.progress < 1)) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: uploadState.progress,
              backgroundColor: const Color(0xFF2A2A3E),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${(uploadState.progress * 100).toStringAsFixed(0)}% terupload...',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],

          // Result message
          if (!uploadState.isUploading && uploadState.lastResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: uploadState.lastResult!.success
                    ? const Color(0xFF10B981).withAlpha(30)
                    : Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    uploadState.lastResult!.success ? Icons.check_circle : Icons.error,
                    color: uploadState.lastResult!.success ? const Color(0xFF10B981) : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      uploadState.lastResult!.success
                          ? 'Backup berhasil! ${uploadState.lastResult!.fileSize}'
                          : uploadState.lastResult!.error ?? 'Upload gagal',
                      style: TextStyle(
                        color: uploadState.lastResult!.success ? const Color(0xFF10B981) : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupCard(BackupInfo backup) {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storage, color: Color(0xFF10B981), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.originalFilename,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${backup.fileSizeFormatted} • ${_formatDate(backup.createdAt)}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (backup.appVersion != null || backup.deviceId != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (backup.appVersion != null)
                    _chip('v${backup.appVersion}', Colors.blue),
                  if (backup.deviceId != null)
                    _chip(backup.deviceId!.substring(0, 8.clamp(0, backup.deviceId!.length)), Colors.purple),
                ],
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadBackup(backup),
                    icon: const Icon(Icons.download, size: 16, color: Color(0xFF6C63FF)),
                    label: const Text('Download', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6C63FF), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(backup),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withAlpha(100), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10)),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_queue, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Belum ada backup tersimpan', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Tap "Upload" untuk membuat backup pertama', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Gagal memuat daftar backup', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(color: Colors.red, fontSize: 11)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(backupListProvider(widget.storeId)),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _startUpload() async {
    // Path database SQLite lokal
    final dbDir = await getDatabasesPath();
    final dbPath = '$dbDir/${AppConfig.dbName}';

    if (!File(dbPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File database tidak ditemukan'), backgroundColor: Colors.red),
      );
      return;
    }

    await ref.read(backupNotifierProvider.notifier).upload(
      storeId: widget.storeId,
      dbFilePath: dbPath,
      appVersion: AppConfig.appVersion,
      notes: 'Manual backup dari aplikasi',
    );

    // Refresh list setelah upload
    if (mounted) {
      ref.invalidate(backupListProvider(widget.storeId));
    }
  }

  Future<String> getDatabasesPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<void> _downloadBackup(BackupInfo backup) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/downloaded_${backup.originalFilename}';

    final result = await ref.read(cloudBackupServiceProvider).downloadBackup(
      storeId: widget.storeId,
      backupId: backup.id,
      savePath: savePath,
      onProgress: (p) {},
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? 'Download selesai: $savePath' : (result.error ?? 'Download gagal')),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(BackupInfo backup) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Hapus Backup?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Hapus "${backup.originalFilename}" dari cloud? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(cloudBackupServiceProvider).deleteBackup(widget.storeId, backup.id);
              if (mounted) {
                if (success) ref.invalidate(backupListProvider(widget.storeId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Backup dihapus' : 'Gagal menghapus'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
