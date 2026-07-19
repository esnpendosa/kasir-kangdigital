import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Tables
part 'app_database.g.dart';

// ─── Table Definitions ────────────────────────────────────────────────────────

/// Application settings (key-value store).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

/// License information and JWT token.
class Licenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get licenseKey => text()();
  TextColumn get jwtToken => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('inactive'))();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get activatedAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Product categories.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Products / items for sale.
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  RealColumn get stock => real().withDefault(const Constant(0.0))();
  RealColumn get minStock => real().withDefault(const Constant(5.0))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  RealColumn get tax => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get trackStock => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Customers.
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get loyaltyPoints => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Suppliers.
class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Sales transactions header.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text()();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get userId => integer().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('completed'))(); // completed|void|hold
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  RealColumn get cashAmount => real().withDefault(const Constant(0.0))();
  RealColumn get changeAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod =>
      text().withDefault(const Constant('cash'))(); // cash|card|transfer
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Line items within a transaction.
class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productName => text()();
  TextColumn get productSku => text().nullable()();
  RealColumn get price => real()();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  RealColumn get quantity => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get tax => real().withDefault(const Constant(0.0))();
  RealColumn get subtotal => real()();
}

/// Business expenses.
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get reference => text().nullable()();
  DateTimeColumn get expenseDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Stock movement log.
class StockLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get type => text()(); // in|out|adjustment
  RealColumn get quantity => real()();
  RealColumn get quantityBefore => real()();
  RealColumn get quantityAfter => real()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// App users (cashiers / admins).
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get username => text()();
  TextColumn get passwordHash => text()();
  TextColumn get role =>
      text().withDefault(const Constant('cashier'))(); // admin|cashier|manager
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Thermal printer configuration.
class PrinterSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get type => text().withDefault(const Constant('bluetooth'))();
  IntColumn get paperWidth => integer().withDefault(const Constant(58))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Cash drawer sessions.
class CashDrawers extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get openingBalance => real()();
  RealColumn get closingBalance => real().nullable()();
  RealColumn get expectedBalance => real().nullable()();
  RealColumn get difference => real().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // open|closed
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
}

/// Backup manifest records.
class Backups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filename => text()();
  TextColumn get filePath => text()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Cache for generated reports (avoid recalculation).
class ReportsCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get reportType => text()();
  TextColumn get periodKey => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {reportType, periodKey}
      ];
}

// ─── Database ────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Settings,
  Licenses,
  Categories,
  Products,
  Customers,
  Suppliers,
  Transactions,
  TransactionItems,
  Expenses,
  StockLogs,
  Users,
  PrinterSettings,
  CashDrawers,
  Backups,
  ReportsCache,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );

  /// Seeds default settings and a sample admin user.
  Future<void> _seedInitialData() async {
    final passwordHash = BCrypt.hashpw('admin', BCrypt.gensalt(logRounds: 4));
    await batch((b) {
      b.insertAll(settings, [
        SettingsCompanion.insert(
            key: 'store_name', value: const Value('Toko Saya')),
        SettingsCompanion.insert(
            key: 'store_address', value: const Value('Jl. Contoh No. 1')),
        SettingsCompanion.insert(key: 'store_phone', value: const Value('')),
        SettingsCompanion.insert(
            key: 'currency_symbol', value: const Value('Rp')),
        SettingsCompanion.insert(key: 'tax_rate', value: const Value('0')),
        SettingsCompanion.insert(
            key: 'receipt_footer',
            value: const Value('Terima kasih atas kunjungan Anda!')),
        SettingsCompanion.insert(
            key: 'printer_paper_width', value: const Value('58')),
        SettingsCompanion.insert(
            key: 'show_logo_on_receipt', value: const Value('true')),
        SettingsCompanion.insert(
            key: 'payment_bank_name', value: const Value('BCA')),
        SettingsCompanion.insert(
            key: 'payment_bank_account', value: const Value('8730129031')),
        SettingsCompanion.insert(
            key: 'payment_bank_recipient', value: const Value('Kasir Kita')),
        SettingsCompanion.insert(
            key: 'qris_merchant_name', value: const Value('Kasir Kita Gateway')),
        SettingsCompanion.insert(
            key: 'qris_nmid', value: const Value('ID1020304050')),
      ]);
      b.insert(users, UsersCompanion.insert(
        name: 'Administrator',
        username: 'admin',
        passwordHash: passwordHash,
        role: const Value('owner'),
        isActive: const Value(true),
      ));
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'kasirkita_pos');
  }
}
