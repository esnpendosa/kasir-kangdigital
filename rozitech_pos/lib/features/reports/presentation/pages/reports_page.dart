import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:excel/excel.dart' as ex;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/report_repository.dart';

final _reportRepoProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(appDatabaseProvider));
});

// State for date range
class _ReportParams {
  final DateTime from;
  final DateTime to;
  const _ReportParams({required this.from, required this.to});
}

final _reportParamsProvider =
    StateProvider<_ReportParams>((ref) {
  final now = DateTime.now();
  return _ReportParams(
    from: DateTime(now.year, now.month, 1),
    to: now,
  );
});

final _salesReportProvider =
    FutureProvider<SalesReportData>((ref) async {
  final params = ref.watch(_reportParamsProvider);
  final repo = ref.watch(_reportRepoProvider);
  return repo.getSalesReport(from: params.from, to: params.to);
});

final _expensesReportProvider =
    FutureProvider<double>((ref) async {
  final params = ref.watch(_reportParamsProvider);
  final repo = ref.watch(_reportRepoProvider);
  return repo.getTotalExpenses(from: params.from, to: params.to);
});

/// Reports page with real DB aggregation.
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(_reportParamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Penjualan'),
            Tab(text: 'Laba Rugi'),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.date_range_rounded, size: 18),
            label: Text(
              '${params.from.toDateString()} - ${params.to.toDateString()}',
              style: const TextStyle(fontSize: 11),
            ),
            onPressed: () => _pickDateRange(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Laporan',
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_view_rounded, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Export Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Export PDF'),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'excel') {
                _exportToExcel();
              } else if (val == 'pdf') {
                _exportToPdf();
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SalesTab(),
          _ProfitTab(),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final params = ref.read(_reportParamsProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: params.from, end: params.to),
    );
    if (range != null) {
      ref.read(_reportParamsProvider.notifier).state =
          _ReportParams(from: range.start, to: range.end);
    }
  }

  Future<void> _exportToPdf() async {
    final params = ref.read(_reportParamsProvider);
    final salesReport = ref.read(_salesReportProvider).value;
    final expensesReport = ref.read(_expensesReportProvider).value ?? 0.0;
    
    if (salesReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan belum dimuat')),
      );
      return;
    }

    final pdf = pw.Document();
    final netProfit = salesReport.grossProfit - expensesReport;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('LAPORAN KINERJA TOKO - CASIR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text('${params.from.toDateString()} - ${params.to.toDateString()}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Financial Summary
            pw.Text('Ringkasan Keuangan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _buildPdfRow('Total Pendapatan', salesReport.totalRevenue.toCurrency()),
                _buildPdfRow('Harga Pokok Penjualan (HPP)', salesReport.totalCogs.toCurrency()),
                _buildPdfRow('Laba Kotor', salesReport.grossProfit.toCurrency()),
                _buildPdfRow('Total Pengeluaran', expensesReport.toCurrency()),
                _buildPdfRow('Laba Bersih', netProfit.toCurrency(), isBold: true),
              ],
            ),
            pw.SizedBox(height: 20),
            
            // Daily breakdown table
            pw.Text('Rincian Penjualan Harian', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tanggal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Transaksi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pendapatan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                for (final row in salesReport.dailyBreakdown)
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(row.date.toDateString())),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${row.transactions}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(row.revenue.toCurrency())),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 20),
            
            // Top products table
            pw.Text('Produk Terlaris', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Nama Produk', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qty Terjual', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pendapatan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Laba', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                for (final prod in salesReport.topProducts)
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(prod.productName)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(prod.qtySold.toStringAsFixed(0))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(prod.revenue.toCurrency())),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(prod.profit.toCurrency())),
                    ],
                  ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'laporan_casir_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  pw.TableRow _buildPdfRow(String label, String value, {bool isBold = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
      ],
    );
  }

  Future<void> _exportToExcel() async {
    final params = ref.read(_reportParamsProvider);
    final salesReport = ref.read(_salesReportProvider).value;
    final expensesReport = ref.read(_expensesReportProvider).value ?? 0.0;
    
    if (salesReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan belum dimuat')),
      );
      return;
    }

    final excel = ex.Excel.createExcel();
    final sheet = excel['Laporan Penjualan'];
    excel.delete('Sheet1'); // Remove default sheet

    ex.CellValue? cellVal(dynamic val) {
      if (val == null) return null;
      if (val is int) return ex.IntCellValue(val);
      if (val is double) return ex.DoubleCellValue(val);
      if (val is bool) return ex.BoolCellValue(val);
      return ex.TextCellValue(val.toString());
    }

    void appendRow(List<dynamic> row) {
      sheet.appendRow(row.map(cellVal).toList());
    }

    appendRow(['LAPORAN KINERJA TOKO - CASIR']);
    appendRow(['Periode: ${params.from.toDateString()} - ${params.to.toDateString()}']);
    appendRow([]); // empty row

    final netProfit = salesReport.grossProfit - expensesReport;
    appendRow(['Ringkasan Keuangan']);
    appendRow(['Total Pendapatan', salesReport.totalRevenue]);
    appendRow(['Harga Pokok Penjualan (HPP)', salesReport.totalCogs]);
    appendRow(['Laba Kotor', salesReport.grossProfit]);
    appendRow(['Total Pengeluaran', expensesReport]);
    appendRow(['Laba Bersih', netProfit]);
    appendRow([]); // empty row

    appendRow(['Rincian Penjualan Harian']);
    appendRow(['Tanggal', 'Jumlah Transaksi', 'Pendapatan']);
    for (final row in salesReport.dailyBreakdown) {
      appendRow([row.date.toDateString(), row.transactions, row.revenue]);
    }
    appendRow([]); // empty row

    appendRow(['Produk Terlaris']);
    appendRow(['Nama Produk', 'Qty Terjual', 'Pendapatan', 'Laba']);
    for (final prod in salesReport.topProducts) {
      appendRow([prod.productName, prod.qtySold, prod.revenue, prod.profit]);
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(fileBytes),
        filename: 'laporan_casir_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );
    }
  }
}

// ─── Sales Tab ──────────────────────────────────────────────────────────────

class _SalesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(_salesReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (report) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI Row
          Row(
            children: [
              _ReportKpi(
                label: 'Total Penjualan',
                value: report.totalRevenue.toCurrency(),
                icon: Icons.trending_up_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _ReportKpi(
                label: 'Laba Kotor',
                value: report.grossProfit.toCurrency(),
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.green,
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.2),

          const SizedBox(height: 12),

          Row(
            children: [
              _ReportKpi(
                label: 'Jumlah Transaksi',
                value: '${report.totalTransactions}',
                icon: Icons.receipt_long_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _ReportKpi(
                label: 'Rata-rata Transaksi',
                value: report.avgTransactionValue.toCurrency(),
                icon: Icons.analytics_rounded,
                color: Colors.purple,
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

          const SizedBox(height: 20),

          // Daily chart
          if (report.dailyBreakdown.isNotEmpty) ...[
            Text('Grafik Penjualan Harian',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _DailyBarChart(data: report.dailyBreakdown),
            const SizedBox(height: 20),
          ],

          // Top products
          Text(
            'Produk Terlaris',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          if (report.topProducts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Belum ada data penjualan',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5))),
              ),
            )
          else
            ...report.topProducts.asMap().entries.map((entry) {
              final i = entry.key;
              final product = entry.value;
              final cs = Theme.of(context).colorScheme;
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.productName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(
                              '${product.qtySold.toStringAsFixed(0)} terjual',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(product.revenue.toCurrency(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        Text('Laba: ${product.profit.toCurrency()}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.withValues(alpha: 0.8))),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 50).ms);
            }),
        ],
      ),
    );
  }
}

// ─── Profit Tab ──────────────────────────────────────────────────────────────

class _ProfitTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(_salesReportProvider);
    final expensesAsync = ref.watch(_expensesReportProvider);
    final cs = Theme.of(context).colorScheme;

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sales) {
        final totalExpenses = expensesAsync.valueOrNull ?? 0;
        final netProfit = sales.grossProfit - totalExpenses;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // P&L Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: netProfit >= 0
                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                      : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Laba Bersih',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    netProfit.toCurrency(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: 20),

            // P&L breakdown
            _PLRow(
              label: 'Total Pendapatan',
              value: sales.totalRevenue,
              isPositive: true,
            ),
            _PLRow(
              label: 'Harga Pokok Penjualan (HPP)',
              value: -sales.totalCogs,
              isPositive: false,
            ),
            const Divider(),
            _PLRow(
              label: 'Laba Kotor',
              value: sales.grossProfit,
              isPositive: sales.grossProfit >= 0,
              isBold: true,
            ),
            _PLRow(
              label: 'Total Pengeluaran',
              value: -totalExpenses,
              isPositive: false,
            ),
            const Divider(),
            _PLRow(
              label: 'Laba Bersih',
              value: netProfit,
              isPositive: netProfit >= 0,
              isBold: true,
            ),

            const SizedBox(height: 24),

            // Margin info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Margin Laba Kotor',
                    value: sales.totalRevenue > 0
                        ? '${(sales.grossProfit / sales.totalRevenue * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Margin Laba Bersih',
                    value: sales.totalRevenue > 0
                        ? '${(netProfit / sales.totalRevenue * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Total Transaksi',
                    value: '${sales.totalTransactions}',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Supporting Widgets ──────────────────────────────────────────────────────

class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart({required this.data});
  final List<DailyReportRow> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxY = data.map((d) => d.revenue).fold<double>(0, (a, b) => a > b ? a : b) * 1.2;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1000 : maxY,
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.revenue,
                  color: cs.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  return Text(
                    '${data[i].date.day}',
                    style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

class _ReportKpi extends StatelessWidget {
  const _ReportKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}

class _PLRow extends StatelessWidget {
  const _PLRow({
    required this.label,
    required this.value,
    required this.isPositive,
    this.isBold = false,
  });
  final String label;
  final double value;
  final bool isPositive;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isPositive ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: cs.onSurface,
              )),
          Text(
            value.toCurrency(),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
