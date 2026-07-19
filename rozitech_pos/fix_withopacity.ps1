$files = @(
  "lib\features\sales\presentation\pages\transaction_history_page.dart",
  "lib\core\theme\app_theme.dart",
  "lib\core\widgets\barcode_scanner_widget.dart",
  "lib\core\widgets\empty_state_widget.dart",
  "lib\core\widgets\error_widget.dart",
  "lib\core\widgets\loading_widget.dart",
  "lib\features\ai\presentation\pages\ai_assistant_page.dart",
  "lib\features\backup\presentation\pages\backup_page.dart",
  "lib\features\categories\presentation\pages\categories_page.dart",
  "lib\features\customers\presentation\pages\customers_page.dart",
  "lib\features\dashboard\presentation\pages\dashboard_page.dart",
  "lib\features\dashboard\presentation\widgets\dashboard_stat_card.dart",
  "lib\features\dashboard\presentation\widgets\sales_chart.dart",
  "lib\features\expenses\presentation\pages\expenses_page.dart",
  "lib\features\inventory\presentation\pages\inventory_page.dart",
  "lib\features\license\presentation\pages\activation_page.dart",
  "lib\features\license\presentation\pages\license_page.dart",
  "lib\features\products\presentation\pages\products_page.dart",
  "lib\features\products\presentation\widgets\barcode_preview_dialog.dart",
  "lib\features\products\presentation\widgets\product_card.dart",
  "lib\features\reports\presentation\pages\reports_page.dart",
  "lib\features\sales\presentation\pages\pos_page.dart",
  "lib\features\sales\presentation\widgets\product_grid_pos.dart",
  "lib\features\suppliers\presentation\pages\suppliers_page.dart",
  "lib\features\users\presentation\screens\login_screen.dart",
  "lib\routes\splash_page.dart",
  "lib\shared\widgets\main_shell.dart",
  "lib\features\sales\presentation\widgets\cart_panel.dart"
)

foreach ($f in $files) {
  if (Test-Path $f) {
    $content = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
    $updated = $content -replace '\.withOpacity\(', '.withValues(alpha: '
    [System.IO.File]::WriteAllText($f, $updated, [System.Text.Encoding]::UTF8)
    Write-Host "Fixed: $f"
  } else {
    Write-Host "Not found: $f"
  }
}
Write-Host "Done"
