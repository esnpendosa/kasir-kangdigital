import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart' as db_provider;
import '../../../../core/providers/role_providers.dart';
import '../../../../routes/app_router.dart';
import '../../../users/domain/entities/user.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/product_excel_service.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_bar.dart';

/// Products listing page with search, filter, grid/list toggle,
/// and Excel import/export functionality.
class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(productSearchProvider);
    final categoryFilter = ref.watch(productCategoryFilterProvider);
    final role = ref.watch(currentRoleProvider) ?? UserRole.cashier;
    final canEdit = role.canEditProducts;

    final productsAsync = ref.watch(
      productsStreamProvider((search: search, categoryId: categoryFilter)),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _ProductsHeader(),
            // ── Filter Bar ──────────────────────────────────────────────
            const ProductFilterBar(),
            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: productsAsync.when(
                loading: () => _buildSkeleton(),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Error: $e'),
                    ],
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) return _EmptyProducts();
                  return _ProductGrid(products: products);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canEdit ? _ProductsFab() : null,
    );
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ProductsHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider) ?? UserRole.cashier;
    final canEdit = role.canEditProducts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Kelola produk Anda',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
          // Excel action buttons (Only for owner/manager)
          if (canEdit) _ExcelActionButton(),
        ],
      ),
    );
  }
}

// ─── Excel Action Button (popup menu) ────────────────────────────────────────

class _ExcelActionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_ExcelAction>(
      tooltip: 'Import / Export Excel',
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.table_chart_rounded, color: Color(0xFF1976D2)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _ExcelAction.export,
          child: ListTile(
            leading: Icon(Icons.upload_file_rounded, color: Color(0xFF388E3C)),
            title: Text('Ekspor ke Excel'),
            subtitle: Text('Simpan semua produk'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: _ExcelAction.import,
          child: ListTile(
            leading: Icon(Icons.download_rounded, color: Color(0xFF1976D2)),
            title: Text('Impor dari Excel'),
            subtitle: Text('Tambah / update produk'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _ExcelAction.template,
          child: ListTile(
            leading: Icon(Icons.file_download_outlined, color: Color(0xFF757575)),
            title: Text('Unduh Template'),
            subtitle: Text('Format Excel kosong'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (action) => _handleAction(context, ref, action),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _ExcelAction action,
  ) async {
    final db = ref.read(db_provider.databaseProvider);
    final repo = ref.read(productRepositoryProvider);
    final service = ProductExcelService(repo, db);

    switch (action) {
      case _ExcelAction.export:
        await _doExport(context, service);
        break;
      case _ExcelAction.import:
        await _doImport(context, service);
        break;
      case _ExcelAction.template:
        await _doTemplate(context, service);
        break;
    }
  }

  Future<void> _doExport(BuildContext context, ProductExcelService service) async {
    _showLoading(context, 'Mengekspor data produk...');
    final result = await service.exportToExcel();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    result.fold(
      onFailure: (msg, _) => _showError(context, msg),
      onSuccess: (_) => _showSuccess(context, 'Data produk berhasil diekspor ke Excel!'),
    );
  }

  Future<void> _doImport(BuildContext context, ProductExcelService service) async {
    // Show import confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: Color(0xFF1976D2)),
            SizedBox(width: 8),
            Text('Impor dari Excel'),
          ],
        ),
        content: const Text(
          'Pilih file Excel (.xlsx) yang berisi data produk.\n\n'
          '• Produk dengan ID yang cocok akan diperbarui\n'
          '• Produk tanpa ID akan ditambahkan sebagai baru\n'
          '• Gunakan template untuk format yang benar',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Pilih File'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Pick file first before showing the loading modal
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );

    if (pickerResult == null || pickerResult.files.isEmpty || !context.mounted) {
      return; // user cancelled picking
    }

    final path = pickerResult.files.single.path;
    if (path == null) {
      _showError(context, 'Path file tidak valid.');
      return;
    }

    // Now show loading dialog safely
    _showLoading(context, 'Mengimpor data produk...');
    final result = await service.importFromFilePath(path);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    result.fold(
      onFailure: (msg, _) => _showError(context, msg),
      onSuccess: (summary) => _showImportSummary(context, summary),
    );
  }

  Future<void> _doTemplate(BuildContext context, ProductExcelService service) async {
    _showLoading(context, 'Membuat template Excel...');
    final result = await service.downloadTemplate();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    result.fold(
      onFailure: (msg, _) => _showError(context, msg),
      onSuccess: (_) => _showSuccess(context, 'Template berhasil dibuat!'),
    );
  }

  void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showImportSummary(BuildContext context, ImportSummary summary) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.summarize_rounded, color: Color(0xFF388E3C)),
            SizedBox(width: 8),
            Text('Hasil Import'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(
              icon: Icons.add_circle_rounded,
              color: const Color(0xFF388E3C),
              label: 'Produk baru ditambahkan',
              value: summary.imported,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.update_rounded,
              color: const Color(0xFF1976D2),
              label: 'Produk diperbarui',
              value: summary.updated,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.error_outline_rounded,
              color: const Color(0xFFD32F2F),
              label: 'Baris gagal',
              value: summary.failed,
            ),
            if (summary.errors.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Detail error:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: 4),
              ...summary.errors.take(5).map((e) => Text(
                    '• $e',
                    style: const TextStyle(fontSize: 12),
                  )),
              if (summary.errors.length > 5)
                Text(
                  '... dan ${summary.errors.length - 5} error lainnya',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

enum _ExcelAction { export, import, template }

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _ProductsFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push(AppRoutes.productAdd),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Produk'),
    );
  }
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        return ProductCard(product: products[i])
            .animate()
            .fadeIn(delay: (i * 40).ms)
            .slideY(begin: 0.1);
      },
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 40, color: cs.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada produk',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk pertama Anda',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: cs.surface.withValues(alpha: 0.5),
        );
  }
}
