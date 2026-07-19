import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';

final _expenseRepoProvider = Provider<ExpenseRepositoryImpl>((ref) {
  return ExpenseRepositoryImpl(ref.watch(appDatabaseProvider));
});

final _expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(_expenseRepoProvider).watchExpenses();
});

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(_expensesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter kategori',
            onSelected: (v) => setState(() => _selectedCategory = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Semua Kategori')),
              ...ExpenseCategory.predefined.map(
                (c) => PopupMenuItem(value: c, child: Text(c)),
              ),
            ],
          ),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allExpenses) {
          final expenses = _selectedCategory == null
              ? allExpenses
              : allExpenses
                  .where((e) => e.category == _selectedCategory)
                  .toList();

          final totalThisMonth = expenses.where((e) {
            final now = DateTime.now();
            return e.expenseDate.year == now.year &&
                e.expenseDate.month == now.month;
          }).fold<double>(0, (s, e) => s + e.amount);

          return Column(
            children: [
              // Summary card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pengeluaran Bulan Ini',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        Text(
                          totalThisMonth.toCurrency(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),

              if (_selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Chip(
                        label: Text(_selectedCategory!),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedCategory = null),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: expenses.isEmpty
                    ? const EmptyStateWidget(
                        title: 'Belum ada pengeluaran',
                        subtitle:
                            'Catat pengeluaran operasional toko Anda di sini',
                        icon: Icons.money_off_rounded,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: expenses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final expense = expenses[i];
                          return _ExpenseTile(
                            expense: expense,
                            onEdit: () => _showAddExpense(
                                context, expense: expense),
                            onDelete: () => _deleteExpense(expense),
                          ).animate().fadeIn(delay: (i * 30).ms);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpense(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Pengeluaran'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: Text(
            'Hapus pengeluaran "${expense.description}"? Tindakan ini tidak dapat dibatalkan.'),
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

    if (confirmed == true && expense.id != null) {
      final result =
          await ref.read(_expenseRepoProvider).deleteExpense(expense.id!);
      if (mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(f.message), backgroundColor: Colors.red),
          ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Pengeluaran dihapus'),
                backgroundColor: Colors.green),
          ),
        );
      }
    }
  }

  void _showAddExpense(BuildContext context, {Expense? expense}) {
    final descCtrl =
        TextEditingController(text: expense?.description ?? '');
    final amountCtrl = TextEditingController(
        text: expense != null ? expense.amount.toStringAsFixed(0) : '');
    String category =
        expense?.category ?? ExpenseCategory.predefined.first;
    DateTime expenseDate = expense?.expenseDate ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    expense == null
                        ? 'Tambah Pengeluaran'
                        : 'Edit Pengeluaran',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      prefixIcon: Icon(Icons.description_rounded)),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Diperlukan' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      prefixText: 'Rp ',
                      prefixIcon: Icon(Icons.payments_rounded)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Diperlukan';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Masukkan jumlah yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_rounded)),
                  items: ExpenseCategory.predefined
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) =>
                      setStateLocal(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text(expenseDate.toDateString()),
                  subtitle: const Text('Tanggal Pengeluaran'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: expenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setStateLocal(() => expenseDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final repo = ref.read(_expenseRepoProvider);
                      final newExpense = Expense(
                        id: expense?.id,
                        category: category,
                        description: descCtrl.text.trim(),
                        amount: double.parse(amountCtrl.text),
                        expenseDate: expenseDate,
                      );
                      final result = expense == null
                          ? await repo.createExpense(newExpense)
                          : await repo.updateExpense(newExpense);
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
                              content: Text(expense == null
                                  ? 'Pengeluaran ditambahkan'
                                  : 'Pengeluaran diperbarui'),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    child: const Text('Simpan Pengeluaran'),
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

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });
  final Expense expense;
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
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.money_off_rounded, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(expense.category,
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(expense.amount.toCurrency(),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w700)),
              Text(expense.expenseDate.toDateString(),
                  style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.4))),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                size: 20, color: cs.onSurface.withValues(alpha: 0.5)),
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
