import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/result.dart';
import '../repositories/product_repository.dart';

/// Handles Excel import and export for product catalog.
class ProductExcelService {
  ProductExcelService(this._repo, this._db);
  final ProductRepository _repo;
  final AppDatabase _db;

  // ─── Column Headers ────────────────────────────────────────────────────────

  static const _headers = [
    'ID',
    'Nama Produk',
    'SKU',
    'Barcode',
    'Deskripsi',
    'Harga Jual',
    'Harga Beli',
    'Stok',
    'Min Stok',
    'Satuan',
    'Pajak (%)',
    'Kategori ID',
    'Aktif',
    'Lacak Stok',
  ];

  // ─── Export ───────────────────────────────────────────────────────────────

  /// Export all active products to an Excel file and share it.
  Future<Result<String>> exportToExcel() async {
    try {
      // Fetch all products
      final products = await (_db.select(_db.products)
            ..where((p) => p.isActive.equals(true))
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .get();

      final excel = Excel.createExcel();
      final sheet = excel['Produk'];

      // Remove default Sheet1 if it exists
      excel.delete('Sheet1');

      // Write header row with bold style
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1976D2'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );

      for (var i = 0; i < _headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(_headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Write data rows
      for (var rowIdx = 0; rowIdx < products.length; rowIdx++) {
        final p = products[rowIdx];
        final row = rowIdx + 1;

        _writeCell(sheet, row, 0, p.id);
        _writeCell(sheet, row, 1, p.name);
        _writeCell(sheet, row, 2, p.sku ?? '');
        _writeCell(sheet, row, 3, p.barcode ?? '');
        _writeCell(sheet, row, 4, p.description ?? '');
        _writeCell(sheet, row, 5, p.price);
        _writeCell(sheet, row, 6, p.cost);
        _writeCell(sheet, row, 7, p.stock);
        _writeCell(sheet, row, 8, p.minStock);
        _writeCell(sheet, row, 9, p.unit);
        _writeCell(sheet, row, 10, p.tax);
        _writeCell(sheet, row, 11, p.categoryId ?? '');
        _writeCell(sheet, row, 12, p.isActive ? 'Ya' : 'Tidak');
        _writeCell(sheet, row, 13, p.trackStock ? 'Ya' : 'Tidak');
      }

      // Set column widths
      sheet.setColumnWidth(1, 30); // Nama Produk
      sheet.setColumnWidth(3, 20); // Barcode
      sheet.setColumnWidth(4, 30); // Deskripsi

      // Save to temp file
      final bytes = excel.encode();
      if (bytes == null) return const Failure('Gagal membuat file Excel');

      final dir = await getApplicationDocumentsDirectory();
      final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${dir.path}/produk_casir_$now.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Share the file
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Data Produk Casir POS - $now',
        ),
      );

      return Success(filePath);
    } catch (e) {
      return Failure('Gagal ekspor: $e', e);
    }
  }

  void _writeCell(Sheet sheet, int row, int col, dynamic value) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    if (value is int) {
      cell.value = IntCellValue(value);
    } else if (value is double) {
      cell.value = DoubleCellValue(value);
    } else {
      cell.value = TextCellValue(value.toString());
    }
  }

  // ─── Import ───────────────────────────────────────────────────────────────

  /// Import products from a specified Excel file path.
  /// Returns a summary of imported, updated, and failed rows.
  Future<Result<ImportSummary>> importFromFilePath(String path) async {
    try {
      final bytes = File(path).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      // Find first sheet
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];
      if (sheet == null) return const Failure('Sheet tidak ditemukan');

      final rows = sheet.rows;
      if (rows.length < 2) return const Failure('File kosong atau hanya berisi header');

      // Parse header row to find column indices
      final headerRow = rows[0];
      final colMap = <String, int>{};
      for (var i = 0; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell?.value != null) {
          colMap[cell!.value.toString().trim()] = i;
        }
      }

      int imported = 0;
      int updated = 0;
      int failed = 0;
      final errors = <String>[];

      // Process data rows (skip header)
      for (var rowIdx = 1; rowIdx < rows.length; rowIdx++) {
        final row = rows[rowIdx];

        // Skip empty rows
        if (row.every((cell) => cell == null || cell.value == null)) continue;

        try {
          final name = _cellStr(row, colMap['Nama Produk']);
          if (name == null || name.isEmpty) {
            failed++;
            errors.add('Baris ${rowIdx + 1}: Nama produk kosong');
            continue;
          }

          final price = _cellDouble(row, colMap['Harga Jual']) ?? 0.0;
          final cost = _cellDouble(row, colMap['Harga Beli']) ?? 0.0;
          final stock = _cellDouble(row, colMap['Stok']) ?? 0.0;
          final minStock = _cellDouble(row, colMap['Min Stok']) ?? 5.0;
          final tax = _cellDouble(row, colMap['Pajak (%)']) ?? 0.0;
          final sku = _cellStr(row, colMap['SKU']);
          final barcode = _cellStr(row, colMap['Barcode']);
          final description = _cellStr(row, colMap['Deskripsi']);
          final unit = _cellStr(row, colMap['Satuan']) ?? 'pcs';
          final categoryId = _cellInt(row, colMap['Kategori ID']);
          final isActiveStr = _cellStr(row, colMap['Aktif'])?.toLowerCase();
          final isActive = isActiveStr != 'tidak' && isActiveStr != 'false' && isActiveStr != '0';
          final trackStockStr = _cellStr(row, colMap['Lacak Stok'])?.toLowerCase();
          final trackStock = trackStockStr != 'tidak' && trackStockStr != 'false' && trackStockStr != '0';

          // Check if ID provided → update existing
          final id = _cellInt(row, colMap['ID']);
          if (id != null && id > 0) {
            final existing = await _repo.getById(id);
            if (existing != null) {
              final companion = ProductsCompanion(
                id: Value(id),
                name: Value(name),
                sku: Value(sku),
                barcode: Value(barcode),
                description: Value(description),
                price: Value(price),
                cost: Value(cost),
                stock: Value(stock),
                minStock: Value(minStock),
                unit: Value(unit),
                tax: Value(tax),
                categoryId: Value(categoryId),
                isActive: Value(isActive),
                trackStock: Value(trackStock),
                updatedAt: Value(DateTime.now()),
              );
              final res = await _repo.update(companion);
              res.fold(
                onFailure: (msg, _) { failed++; errors.add('Baris ${rowIdx + 1}: $msg'); },
                onSuccess: (_) => updated++,
              );
              continue;
            }
          }

          // Insert new product
          final companion = ProductsCompanion(
            name: Value(name),
            sku: Value(sku),
            barcode: Value(barcode),
            description: Value(description),
            price: Value(price),
            cost: Value(cost),
            stock: Value(stock),
            minStock: Value(minStock),
            unit: Value(unit),
            tax: Value(tax),
            categoryId: Value(categoryId),
            isActive: Value(isActive),
            trackStock: Value(trackStock),
          );
          final res = await _repo.create(companion);
          res.fold(
            onFailure: (msg, _) { failed++; errors.add('Baris ${rowIdx + 1}: $msg'); },
            onSuccess: (_) => imported++,
          );
        } catch (e) {
          failed++;
          errors.add('Baris ${rowIdx + 1}: $e');
        }
      }

      return Success(ImportSummary(
        imported: imported,
        updated: updated,
        failed: failed,
        errors: errors,
      ));
    } catch (e) {
      return Failure('Gagal impor: $e', e);
    }
  }

  // ─── Template ─────────────────────────────────────────────────────────────

  /// Download an empty Excel template with the correct headers.
  Future<Result<String>> downloadTemplate() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Produk'];
      excel.delete('Sheet1');

      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1976D2'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );

      for (var i = 0; i < _headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(_headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Sample row
      final sampleStyle = CellStyle(
        italic: true,
        fontColorHex: ExcelColor.fromHexString('#757575'),
      );
      final samples = [
        '', 'Contoh Produk', 'SKU001', '8991234567890',
        'Deskripsi produk', '10000', '7000', '50',
        '5', 'pcs', '0', '', 'Ya', 'Ya',
      ];
      for (var i = 0; i < samples.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1),
        );
        cell.value = TextCellValue(samples[i]);
        cell.cellStyle = sampleStyle;
      }

      sheet.setColumnWidth(1, 30);

      final bytes = excel.encode();
      if (bytes == null) return const Failure('Gagal membuat template');

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/template_produk_casir.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Template Import Produk Casir POS',
        ),
      );

      return Success(filePath);
    } catch (e) {
      return Failure('Gagal buat template: $e', e);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String? _cellStr(List<Data?> row, int? col) {
    if (col == null || col >= row.length) return null;
    final v = row[col]?.value;
    if (v == null) return null;
    return v.toString().trim().isEmpty ? null : v.toString().trim();
  }

  double? _cellDouble(List<Data?> row, int? col) {
    if (col == null || col >= row.length) return null;
    final v = row[col]?.value;
    if (v == null) return null;
    if (v is DoubleCellValue) return v.value;
    if (v is IntCellValue) return v.value.toDouble();
    return double.tryParse(v.toString());
  }

  int? _cellInt(List<Data?> row, int? col) {
    if (col == null || col >= row.length) return null;
    final v = row[col]?.value;
    if (v == null) return null;
    if (v is IntCellValue) return v.value;
    if (v is DoubleCellValue) return v.value.toInt();
    return int.tryParse(v.toString());
  }
}

/// Summary result of an import operation.
class ImportSummary {
  const ImportSummary({
    required this.imported,
    required this.updated,
    required this.failed,
    required this.errors,
  });

  final int imported;
  final int updated;
  final int failed;
  final List<String> errors;

  int get total => imported + updated + failed;
}
