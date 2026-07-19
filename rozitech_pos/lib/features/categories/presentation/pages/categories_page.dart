import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';

final _categoryRepoProvider = Provider<CategoryRepositoryImpl>((ref) {
  return CategoryRepositoryImpl(ref.watch(appDatabaseProvider));
});

final _categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(_categoryRepoProvider).watchCategories();
});

/// Categories page with real DB data.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  static const _iconColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(_categoriesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: categoriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyStateWidget(
              title: 'Belum ada kategori',
              subtitle: 'Buat kategori untuk mengelompokkan produk Anda',
              icon: Icons.category_rounded,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final color = _iconColors[i % _iconColors.length];
              return _CategoryTile(
                category: cat,
                color: color,
                onEdit: () => _showCategoryDialog(context, ref, category: cat),
                onDelete: () => _deleteCategory(context, ref, cat),
              ).animate().fadeIn(delay: (i * 40).ms);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  Future<void> _deleteCategory(
      BuildContext context, WidgetRef ref, Category category) async {
    if (category.id == null) return;
    final repo = ref.read(_categoryRepoProvider);
    final count = await repo.getProductCountForCategory(category.id!);
    if (!context.mounted) return;

    if (count > 0) {
      final reassign = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Hapus Kategori'),
          content: Text(
              'Kategori "${category.name}" memiliki $count produk. '
              'Produk akan dipindahkan ke "Tanpa Kategori".'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Pindahkan & Hapus'),
            ),
          ],
        ),
      );
      if (reassign != true) return;
      await repo.deleteCategory(category.id!, reassign: true);
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Hapus Kategori'),
          content: Text('Hapus kategori "${category.name}"?'),
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
      if (confirmed != true || !context.mounted) return;
      final result = await repo.deleteCategory(category.id!);
      if (context.mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(f.message), backgroundColor: Colors.red)),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Kategori dihapus'),
                  backgroundColor: Colors.green)),
        );
      }
    }
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref,
      {Category? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final descCtrl =
        TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nama Kategori*',
                    prefixIcon: Icon(Icons.category_rounded)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Diperlukan' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    prefixIcon: Icon(Icons.notes_rounded)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final repo = ref.read(_categoryRepoProvider);
              final newCategory = Category(
                id: category?.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.isEmpty
                    ? null
                    : descCtrl.text.trim(),
              );
              final result = category == null
                  ? await repo.createCategory(newCategory)
                  : await repo.updateCategory(newCategory);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                result.fold(
                  (f) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(f.message),
                        backgroundColor: Colors.red),
                  ),
                  (_) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(category == null
                          ? 'Kategori ditambahkan'
                          : 'Kategori diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });
  final Category category;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.category_rounded, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (category.description != null)
                  Text(category.description!,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
