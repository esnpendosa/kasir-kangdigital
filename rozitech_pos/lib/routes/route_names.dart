/// All route path constants for Casir POS.
abstract final class RouteNames {
  // ─── Public (no auth) ──────────────────────────────────────────────────────
  static const splash = '/';
  static const license = '/license';
  static const licenseManage = '/license/manage';
  static const login = '/login';

  // ─── Main App (requires auth) ──────────────────────────────────────────────
  static const dashboard = '/dashboard';

  // Sales
  static const sales = '/sales';
  static const salesHistory = '/sales/history';
  static const salesDetail = '/sales/:id';

  // Products
  static const products = '/products';
  static const productsAdd = '/products/add';
  static const productsDetail = '/products/:id';

  // Categories
  static const categories = '/categories';

  // Customers
  static const customers = '/customers';
  static const customersDetail = '/customers/:id';

  // Suppliers
  static const suppliers = '/suppliers';

  // Inventory
  static const inventory = '/inventory';

  // Expenses
  static const expenses = '/expenses';

  // Reports
  static const reports = '/reports';

  // Settings
  static const settings = '/settings';
  static const settingsPrinter = '/settings/printer';
  static const settingsUsers = '/settings/users';

  // Backup
  static const backup = '/backup';

  // AI
  static const ai = '/ai';

  // Helpers
  static String salesDetailPath(int id) => '/sales/$id';
  static String productsDetailPath(int id) => '/products/$id';
  static String customersDetailPath(int id) => '/customers/$id';
}
