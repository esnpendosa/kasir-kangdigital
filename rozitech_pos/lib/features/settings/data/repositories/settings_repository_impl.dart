import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider));
});

final storeProfileProvider = FutureProvider<Map<String, String?>>((ref) async {
  return ref.watch(settingsRepositoryProvider).getStoreProfile();
});

/// In-memory settings cache for fast reads.
class _SettingsCache {
  static final _SettingsCache _instance = _SettingsCache._internal();
  factory _SettingsCache() => _instance;
  _SettingsCache._internal();

  final Map<String, String?> _cache = {};
  bool _loaded = false;

  void set(String key, String? value) => _cache[key] = value;
  String? get(String key) => _cache[key];
  void invalidate() {
    _cache.clear();
    _loaded = false;
  }
  bool get isLoaded => _loaded;
  void markLoaded() => _loaded = true;
}

/// Repository for reading/writing the Settings key-value table.
class SettingsRepositoryImpl {
  SettingsRepositoryImpl(this._db);
  final AppDatabase _db;

  final _cache = _SettingsCache();

  Future<void> _ensureLoaded() async {
    if (_cache.isLoaded) return;
    final rows = await _db.select(_db.settings).get();
    for (final row in rows) {
      _cache.set(row.key, row.value);
    }
    _cache.markLoaded();
  }

  Future<String?> get(String key) async {
    await _ensureLoaded();
    return _cache.get(key);
  }

  Future<String> getString(String key, {String defaultValue = ''}) async {
    return (await get(key)) ?? defaultValue;
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final v = await get(key);
    if (v == null) return defaultValue;
    return v == 'true';
  }

  Future<double> getDouble(String key, {double defaultValue = 0}) async {
    final v = await get(key);
    return double.tryParse(v ?? '') ?? defaultValue;
  }

  Future<void> set(String key, String? value) async {
    _cache.set(key, value);
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: Value(value)),
        );
  }

  Future<Map<String, String?>> getStoreProfile() async {
    await _ensureLoaded();
    return {
      'store_name': _cache.get('store_name'),
      'store_address': _cache.get('store_address'),
      'store_phone': _cache.get('store_phone'),
      'store_email': _cache.get('store_email'),
      'store_tax_id': _cache.get('store_tax_id'),
      'currency_symbol': _cache.get('currency_symbol'),
      'tax_rate': _cache.get('tax_rate'),
      'receipt_footer': _cache.get('receipt_footer'),
      'printer_paper_width': _cache.get('printer_paper_width') ?? _cache.get('receipt_paper_width'),
      'show_logo_on_receipt': _cache.get('show_logo_on_receipt'),
      'print_logo': _cache.get('print_logo'),
      'store_logo': _cache.get('store_logo'),
      'theme_mode': _cache.get('theme_mode'),
      'payment_bank_name': _cache.get('payment_bank_name'),
      'payment_bank_account': _cache.get('payment_bank_account'),
      'payment_bank_recipient': _cache.get('payment_bank_recipient'),
      'qris_merchant_name': _cache.get('qris_merchant_name'),
      'qris_nmid': _cache.get('qris_nmid'),
    };
  }

  /// Returns ALL settings as a flat map — single DB read, then fully cached.
  /// Use this for bulk reads (e.g. payment gateway configs) to avoid
  /// multiple sequential async calls.
  Future<Map<String, String?>> getAllSettings() async {
    await _ensureLoaded();
    // Return a copy of the internal cache map
    return Map<String, String?>.from(_cache._cache);
  }


  Future<void> saveStoreProfile({
    required String name,
    required String address,
    required String phone,
    String? email,
    String? taxId,
  }) async {
    await set('store_name', name);
    await set('store_address', address);
    await set('store_phone', phone);
    await set('store_email', email);
    await set('store_tax_id', taxId);
  }

  void invalidateCache() => _cache.invalidate();
}
