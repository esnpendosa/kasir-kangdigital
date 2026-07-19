import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';

final _expensesProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExpenseRepositoryImpl(db).watchExpenses();
});

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() =>
      _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String? _filterCategory;

  Future<void> _showExpenseDialog({Expense? expense}) async {
    final descCtrl = TextEditingController(text: expense?.description ?? '');
    final amtCtrl = TextEditingController(
        text: expense?.amount != null ? expense!.amount.toString() : '');
    String category = expense?.category ?? ExpenseCategory.other;
    DateTime date = expense?.expenseDate ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(expense == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: ExpenseCategory.predefined
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setS(() => category = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Deskripsi'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Diperlukan' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amtCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Jumlah (Rp)', prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Diperlukan';
                      if (double.tryParse(v) == null) return 'Harus angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                        'Tanggal: ${DateFormatter.formatShortDate(date)}'),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setS(() => date = picked);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final db = ref.read(appDatabaseProvider);
                final repo = ExpenseRepositoryImpl(db);
                final e = Expense(
                  id: expense?.id,
                  category: category,
                  description: descCtrl.text.trim(),
                  amount: double.parse(amtCtrl.text),
                  expenseDate: date,
                );
                if (expense == null) {
                  await repo.createExpense(e);
                } else {
                  await repo.updateExpense(e);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(_expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (v) => setState(() => _filterCategory = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Semua Kategori')),
              ...ExpenseCategory.predefined.map(
                (c) => PopupMenuItem(value: c, child: Text(c)),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Pengeluaran'),
      ),
      body: expensesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          final filtered = _filterCategory == null
              ? expenses
              : expenses
                  .where((e) => e.category == _filterCategory)
                  .toList();

          if (filtered.isEmpty) {
            return EmptyStateWidget(
              title: 'Belum ada pengeluaran',
              icon: Icons.receipt_long_outlined,
              action: () => _showExpenseDialog(),
              actionLabel: 'Tambah Pengeluaran',
            );
          }

          double total = filtered.fold(0, (s, e) => s + e.amount);

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pengeluaran',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      CurrencyFormatter.format(total),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final e = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt_outlined,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer),
                        ),
                        title: Text(e.description,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${e.category} · ${DateFormatter.formatShortDate(e.expenseDate)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.format(e.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).colorScheme.error,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18),
                              onPressed: () =>
                                  _showExpenseDialog(expense: e),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
