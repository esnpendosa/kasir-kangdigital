import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/sales/domain/entities/transaction.dart';
import 'extensions.dart';

class ReceiptPdfGenerator {
  static Future<Uint8List> generate(
    SalesTransaction tx, {
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required String receiptFooter,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, 180 * PdfPageFormat.mm, marginAll: 2 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Store Header
              pw.Center(
                child: pw.Text(
                  storeName,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                ),
              ),
              if (storeAddress.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    storeAddress,
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                ),
              if (storePhone.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    'Telp: $storePhone',
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                ),
              pw.Divider(thickness: 0.5),

              // Tx Details
              pw.Text('No: ${tx.transactionNumber}', style: const pw.TextStyle(fontSize: 7)),
              pw.Text('Tgl: ${tx.createdAt.toDateTimeString()}', style: const pw.TextStyle(fontSize: 7)),
              pw.Text('Kasir: User #${tx.userId}', style: const pw.TextStyle(fontSize: 7)),
              pw.Divider(thickness: 0.5),

              // Items
              for (final item in tx.items)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.productName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${item.quantity.toStringAsFixed(0)} x ${item.sellingPrice.toCurrency()}', style: const pw.TextStyle(fontSize: 7)),
                          pw.Text(item.lineTotal.toCurrency(), style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                    ],
                  ),
                ),
              pw.Divider(thickness: 0.5),

              // Summary
              _buildRow('Subtotal', tx.subtotal.toCurrency()),
              if (tx.discountAmount > 0)
                _buildRow('Diskon', '-${tx.discountAmount.toCurrency()}'),
              if (tx.taxAmount > 0)
                _buildRow('Pajak', tx.taxAmount.toCurrency()),
              pw.Divider(thickness: 0.5),
              _buildRow('TOTAL', tx.total.toCurrency(), isBold: true),
              _buildRow('Bayar', tx.paymentAmount.toCurrency()),
              _buildRow('Kembalian', tx.changeAmount.toCurrency()),
              pw.Divider(thickness: 0.5),

              // Footer
              pw.Center(
                child: pw.Text(
                  receiptFooter.isNotEmpty ? receiptFooter : 'Terima kasih atas kunjungan Anda!',
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Dibuat via CASIR POS',
                  style: pw.TextStyle(fontSize: 6, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value, style: pw.TextStyle(fontSize: 7, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }
}
