import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../../../core/providers/database_provider.dart';

final _customerRepoProvider = Provider<CustomerRepositoryImpl>((ref) {
  return CustomerRepositoryImpl(ref.watch(appDatabaseProvider));
});

final _customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(_customerRepoProvider).watchCustomers();
});

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(_customersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pelanggan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari pelanggan...',
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
            child: customersAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allCustomers) {
                final customers = _query.isEmpty
                    ? allCustomers
                    : allCustomers
                        .where((c) =>
                            c.name
                                .toLowerCase()
                                .contains(_query.toLowerCase()) ||
                            (c.phone?.contains(_query) ?? false))
                        .toList();

                if (customers.isEmpty) {
                  return EmptyStateWidget(
                    title: _query.isEmpty
                        ? 'Belum ada pelanggan'
                        : 'Pelanggan tidak ditemukan',
                    subtitle: _query.isEmpty
                        ? 'Tambahkan data pelanggan untuk manajemen lebih mudah'
                        : 'Coba kata kunci lain',
                    icon: Icons.people_outline_rounded,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = customers[i];
                    return _CustomerTile(
                      customer: c,
                      onEdit: () => _showCustomerDialog(c),
                      onDelete: () => _deleteCustomer(c),
                    ).animate().fadeIn(delay: (i * 30).ms);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(null),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Pelanggan'),
      ),
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    if (customer.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text('Hapus "${customer.name}"?'),
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
    if (confirmed == true && mounted) {
      final result = await ref
          .read(_customerRepoProvider)
          .deleteCustomer(customer.id!);
      if (mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message), backgroundColor: Colors.red),
          ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Pelanggan dihapus'),
                backgroundColor: Colors.green),
          ),
        );
      }
    }
  }

  void _showCustomerDialog(Customer? customer) {
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    final emailCtrl = TextEditingController(text: customer?.email ?? '');
    final addressCtrl = TextEditingController(text: customer?.address ?? '');
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
                    customer == null
                        ? 'Tambah Pelanggan'
                        : 'Edit Pelanggan',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan*',
                      prefixIcon: Icon(Icons.person_rounded)),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Diperlukan' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      prefixIcon: Icon(Icons.phone_rounded)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email (opsional)',
                      prefixIcon: Icon(Icons.email_rounded)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Alamat (opsional)',
                      prefixIcon: Icon(Icons.location_on_rounded)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final repo = ref.read(_customerRepoProvider);
                      final newCustomer = Customer(
                        id: customer?.id,
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.isEmpty
                            ? null
                            : phoneCtrl.text.trim(),
                        email: emailCtrl.text.isEmpty
                            ? null
                            : emailCtrl.text.trim(),
                        address: addressCtrl.text.isEmpty
                            ? null
                            : addressCtrl.text.trim(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final result = customer == null
                          ? await repo.createCustomer(newCustomer)
                          : await repo.updateCustomer(newCustomer);
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
                              content: Text(customer == null
                                  ? 'Pelanggan ditambahkan'
                                  : 'Pelanggan diperbarui'),
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

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });
  final Customer customer;
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
          CircleAvatar(
            backgroundColor: cs.primary.withValues(alpha: 0.15),
            child: Text(
              customer.name.isNotEmpty
                  ? customer.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (customer.phone != null)
                  Text(customer.phone!,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: cs.onSurface.withValues(alpha: 0.5)),
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
