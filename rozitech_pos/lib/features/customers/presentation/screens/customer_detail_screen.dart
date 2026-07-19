import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../../sales/data/repositories/transaction_repository_impl.dart';
import '../../../sales/domain/entities/transaction.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pelanggan')),
      body: FutureBuilder(
        future: CustomerRepositoryImpl(db).getCustomerById(customerId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          final customer = snap.data?.fold((_) => null, (c) => c);
          if (customer == null) {
            return const Center(child: Text('Pelanggan tidak ditemukan'));
          }
          return _CustomerDetailBody(customer: customer, db: db);
        },
      ),
    );
  }
}

class _CustomerDetailBody extends ConsumerWidget {
  const _CustomerDetailBody({required this.customer, required this.db});
  final Customer customer;
  final dynamic db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text(customer.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          if (customer.phone != null)
                            Text(customer.phone!,
                                style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                if (customer.email != null) ...[
                  const Divider(height: 24),
                  _InfoRow(
                      icon: Icons.email_outlined, label: customer.email!),
                ],
                if (customer.address != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: customer.address!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Riwayat Transaksi',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FutureBuilder(
          future: TransactionRepositoryImpl(db)
              .getTransactions()
              .then((r) => r.getOrElse((_) => []).where(
                    (t) => t.customerId == customer.id,
                  ).toList()),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            final txs = snap.data ?? <SalesTransaction>[];
            if (txs.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada transaksi'),
              ));
            }
            return Column(
              children: txs
                  .map((t) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(t.transactionNumber),
                          subtitle: Text(
                              DateFormatter.formatDateTime(t.createdAt)),
                          trailing: Text(
                            CurrencyFormatter.format(t.total),
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}
