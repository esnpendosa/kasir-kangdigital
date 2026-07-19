import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/entities/supplier.dart';

final _supplierRepoProvider = Provider<SupplierRepositoryImpl>((ref) {
  return SupplierRepositoryImpl(ref.watch(appDatabaseProvider));
});

final _suppliersStreamProvider = StreamProvider<List<Supplier>>((ref) {
  return ref.watch(_supplierRepoProvider).watchSuppliers();
});

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(_suppliersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Supplier')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari supplier...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: suppliersAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allSuppliers) {
                final suppliers = _query.isEmpty
                    ? allSuppliers
                    : allSuppliers
                        .where((s) =>
                            s.name
                                .toLowerCase()
                                .contains(_query.toLowerCase()) ||
                            (s.phone?.contains(_query) ?? false))
                        .toList();

                if (suppliers.isEmpty) {
                  return EmptyStateWidget(
                    title: _query.isEmpty
                        ? 'Belum ada supplier'
                        : 'Supplier tidak ditemukan',
                    subtitle: _query.isEmpty
                        ? 'Tambahkan supplier untuk mengelola pemasok produk Anda'
                        : 'Coba kata kunci lain',
                    icon: Icons.local_shipping_rounded,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: suppliers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _SupplierTile(
                    supplier: suppliers[i],
                    onEdit: () =>
                        _showSupplierDialog(supplier: suppliers[i]),
                    onDelete: () => _deleteSupplier(suppliers[i]),
                  ).animate().fadeIn(delay: (i * 40).ms),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSupplierDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Supplier'),
      ),
    );
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Supplier'),
        content: Text('Hapus "${supplier.name}"? Tindakan ini tidak dapat dibatalkan.'),
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
    if (confirmed == true && supplier.id != null) {
      final result =
          await ref.read(_supplierRepoProvider).deleteSupplier(supplier.id!);
      if (mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message), backgroundColor: Colors.red),
          ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Supplier dihapus'),
                backgroundColor: Colors.green),
          ),
        );
      }
    }
  }

  void _showSupplierDialog({Supplier? supplier}) {
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final contactCtrl =
        TextEditingController(text: supplier?.contactPerson ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');
    final notesCtrl = TextEditingController(text: supplier?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    supplier == null ? 'Tambah Supplier' : 'Edit Supplier',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Supplier*',
                      prefixIcon: Icon(Icons.business_rounded)),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Diperlukan' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Kontak',
                      prefixIcon: Icon(Icons.person_rounded)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Telepon',
                      prefixIcon: Icon(Icons.phone_rounded)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: Icon(Icons.location_on_rounded)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Catatan',
                      prefixIcon: Icon(Icons.notes_rounded)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final repo = ref.read(_supplierRepoProvider);
                      final newSupplier = Supplier(
                        id: supplier?.id,
                        name: nameCtrl.text.trim(),
                        contactPerson: contactCtrl.text.isEmpty
                            ? null
                            : contactCtrl.text.trim(),
                        phone: phoneCtrl.text.isEmpty
                            ? null
                            : phoneCtrl.text.trim(),
                        email: emailCtrl.text.isEmpty
                            ? null
                            : emailCtrl.text.trim(),
                        address: addressCtrl.text.isEmpty
                            ? null
                            : addressCtrl.text.trim(),
                        notes: notesCtrl.text.isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                      );
                      final result = supplier == null
                          ? await repo.createSupplier(newSupplier)
                          : await repo.updateSupplier(newSupplier);
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
                              content: Text(supplier == null
                                  ? 'Supplier ditambahkan'
                                  : 'Supplier diperbarui'),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan'),
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

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
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
              color: cs.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_shipping_rounded, color: cs.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (supplier.contactPerson != null)
                  Text('Kontak: ${supplier.contactPerson}',
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.5))),
                if (supplier.phone != null)
                  Text(supplier.phone!,
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus',
                      style: TextStyle(color: Colors.red))),
            ],
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
          ),
        ],
      ),
    );
  }
}
