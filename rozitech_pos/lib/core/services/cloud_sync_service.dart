import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../../../features/license/data/datasources/license_local_datasource.dart';

/// Centralized service untuk sinkronisasi data antara SQLite lokal dan server.
/// Push data ke kangdigital.web.id dan pull data dari server.
///
/// Compatible dengan arsitektur offline-first:
/// - App bisa jalan penuh tanpa internet
/// - Sinkronisasi dilakukan manual atau scheduled
class CloudSyncService {
  final Dio _dio;
  final LicenseLocalDatasource _licenseLocal;

  CloudSyncService({required Dio dio, required LicenseLocalDatasource licenseLocal})
      : _dio = dio,
        _licenseLocal = licenseLocal;

  /// Ambil token dari storage lokal dan set ke header Authorization
  Future<String?> _getAuthToken() async {
    try {
      return await _licenseLocal.getJwtToken();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ─── STORE MANAGEMENT ────────────────────────────────────────────────────

  /// Ambil semua toko milik lisensi ini dari server
  Future<List<Map<String, dynamic>>> getStores() async {
    try {
      final headers = await _authHeaders();
      final response = await _dio.get(
        '${AppConfig.baseUrl}stores',
        options: Options(headers: headers),
      );
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Buat toko baru di server
  Future<Map<String, dynamic>?> createStore({
    required String storeName,
    String? address,
    String? phone,
    String? email,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _dio.post(
        '${AppConfig.baseUrl}stores',
        data: {
          'store_name': storeName,
          'address': address,
          'phone': phone,
          'email': email,
          'currency': 'IDR',
          'currency_symbol': 'Rp',
        },
        options: Options(headers: headers),
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Ping sinkronisasi — update timestamp last_synced_at di server
  Future<bool> syncPing(int storeId) async {
    try {
      final headers = await _authHeaders();
      final response = await _dio.post(
        '${AppConfig.baseUrl}stores/$storeId/sync-ping',
        options: Options(headers: headers),
      );
      return response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ─── PUSH (Android → Server) ─────────────────────────────────────────────

  /// Push batch data ke server. Returns jumlah data yang berhasil di-sync.
  Future<SyncResult> pushBatch({
    required int storeId,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? customers,
    List<Map<String, dynamic>>? transactions,
    List<Map<String, dynamic>>? expenses,
    List<Map<String, dynamic>>? suppliers,
  }) async {
    final results = SyncResult();
    final headers = await _authHeaders();

    // Push categories
    if (categories != null && categories.isNotEmpty) {
      results.categories = await _pushData(
        endpoint: '${AppConfig.baseUrl}sync/$storeId/categories',
        data: categories,
        headers: headers,
      );
    }

    // Push products
    if (products != null && products.isNotEmpty) {
      results.products = await _pushData(
        endpoint: '${AppConfig.baseUrl}sync/$storeId/products',
        data: products,
        headers: headers,
      );
    }

    // Push customers
    if (customers != null && customers.isNotEmpty) {
      results.customers = await _pushData(
        endpoint: '${AppConfig.baseUrl}sync/$storeId/customers',
        data: customers,
        headers: headers,
      );
    }

    // Push transactions
    if (transactions != null && transactions.isNotEmpty) {
      results.transactions = await _pushData(
        endpoint: '${AppConfig.baseUrl}sync/$storeId/transactions',
        data: transactions,
        headers: headers,
      );
    }

    // Push expenses
    if (expenses != null && expenses.isNotEmpty) {
      results.expenses = await _pushData(
        endpoint: '${AppConfig.baseUrl}sync/$storeId/expenses',
        data: expenses,
        headers: headers,
      );
    }

    // Push suppliers
    if (suppliers != null && suppliers.isNotEmpty) {
      results.suppliers = await _pushData(
        endpoint: '${AppConfig.baseUrl}sync/$storeId/suppliers',
        data: suppliers,
        headers: headers,
      );
    }

    // Update ping terakhir
    await syncPing(storeId);

    results.success = true;
    results.syncedAt = DateTime.now();
    return results;
  }

  Future<int> _pushData({
    required String endpoint,
    required List<Map<String, dynamic>> data,
    required Map<String, String> headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: {'data': data},
        options: Options(headers: headers),
      );
      if (response.data['success'] == true) {
        return response.data['synced'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ─── PULL (Server → Android) ─────────────────────────────────────────────

  /// Pull semua data dari server untuk store tertentu.
  /// Berguna untuk restore ke device baru atau fresh install.
  Future<PullResult?> pullAll(int storeId, {DateTime? since}) async {
    try {
      final headers = await _authHeaders();
      String url = '${AppConfig.baseUrl}sync/$storeId/pull';
      if (since != null) {
        url += '?since=${since.toIso8601String()}';
      }

      final response = await _dio.get(
        url,
        options: Options(headers: headers, receiveTimeout: const Duration(seconds: 60)),
      );

      if (response.data['success'] == true) {
        return PullResult.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── REPORTS ─────────────────────────────────────────────────────────────

  /// Ambil laporan dari server
  Future<Map<String, dynamic>?> getReport(int storeId, {String? from, String? to}) async {
    try {
      final headers = await _authHeaders();
      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final response = await _dio.get(
        '${AppConfig.baseUrl}sync/$storeId/report',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Hasil operasi push sync
class SyncResult {
  bool success = false;
  int categories = 0;
  int products = 0;
  int customers = 0;
  int transactions = 0;
  int expenses = 0;
  int suppliers = 0;
  DateTime? syncedAt;

  int get total => categories + products + customers + transactions + expenses + suppliers;

  @override
  String toString() =>
      'SyncResult(success=$success, total=$total, categories=$categories, products=$products, '
      'customers=$customers, transactions=$transactions, expenses=$expenses, suppliers=$suppliers)';
}

/// Hasil operasi pull sync
class PullResult {
  final Map<String, dynamic> store;
  final List<dynamic> categories;
  final List<dynamic> products;
  final List<dynamic> customers;
  final List<dynamic> suppliers;
  final List<dynamic> transactions;
  final List<dynamic> expenses;
  final Map<String, dynamic> counts;
  final String serverTime;

  const PullResult({
    required this.store,
    required this.categories,
    required this.products,
    required this.customers,
    required this.suppliers,
    required this.transactions,
    required this.expenses,
    required this.counts,
    required this.serverTime,
  });

  factory PullResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PullResult(
      store: Map<String, dynamic>.from(json['store'] ?? {}),
      categories: List<dynamic>.from(data['categories'] ?? []),
      products: List<dynamic>.from(data['products'] ?? []),
      customers: List<dynamic>.from(data['customers'] ?? []),
      suppliers: List<dynamic>.from(data['suppliers'] ?? []),
      transactions: List<dynamic>.from(data['transactions'] ?? []),
      expenses: List<dynamic>.from(data['expenses'] ?? []),
      counts: Map<String, dynamic>.from(json['counts'] ?? {}),
      serverTime: json['server_time'] ?? '',
    );
  }

  int get totalRecords =>
      categories.length +
      products.length +
      customers.length +
      suppliers.length +
      transactions.length +
      expenses.length;
}
