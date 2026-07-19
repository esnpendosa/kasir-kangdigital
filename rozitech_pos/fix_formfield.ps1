$files = @(
  "lib\features\expenses\presentation\pages\expenses_page.dart",
  "lib\features\expenses\presentation\screens\expense_list_screen.dart",
  "lib\features\inventory\presentation\pages\inventory_page.dart",
  "lib\features\inventory\presentation\screens\stock_screen.dart",
  "lib\features\users\presentation\screens\user_management_screen.dart"
)
foreach ($f in $files) {
  if (Test-Path $f) {
    $c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
    # Replace `value:` that directly follows a TextFormField opening
    # More targeted: replace standalone `      value:` lines with `      initialValue:` only inside TextFormField
    $u = $c -replace '(TextFormField\([^)]*?\n\s*)value:', '$1initialValue:'
    if ($u -ne $c) {
      [System.IO.File]::WriteAllText($f, $u, [System.Text.Encoding]::UTF8)
      Write-Host "Fixed TextFormField value->initialValue: $f"
    } else {
      Write-Host "No match: $f"
    }
  } else {
    Write-Host "Not found: $f"
  }
}
Write-Host "Done"
