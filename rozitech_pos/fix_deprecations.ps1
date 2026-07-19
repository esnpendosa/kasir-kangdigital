$dartFiles = Get-ChildItem -Recurse -Filter "*.dart" -Path "lib" | Select-Object -ExpandProperty FullName

$count = 0
foreach ($f in $dartFiles) {
  $orig = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
  $updated = $orig

  # Replace deprecated ColorScheme members
  $updated = $updated -replace '\.surfaceVariant\b', '.surfaceContainerHighest'
  $updated = $updated -replace 'cs\.background\b', 'cs.surface'
  $updated = $updated -replace 'colorScheme\.background\b', 'colorScheme.surface'
  $updated = $updated -replace '\.onBackground\b', '.onSurface'

  # Replace deprecated Share API with SharePlus
  $updated = $updated -replace 'Share\.share\(', 'SharePlus.instance.share(ShareParams(text: '
  $updated = $updated -replace 'Share\.shareXFiles\(', 'SharePlus.instance.share(ShareParams(files: '

  # Fix unnecessary string interpolations like '${someVar}' -> '$someVar' (simple cases)
  # Skip this - risky, could break complex expressions

  if ($updated -ne $orig) {
    [System.IO.File]::WriteAllText($f, $updated, [System.Text.Encoding]::UTF8)
    $count++
    Write-Host "Fixed: $f"
  }
}
Write-Host "Total files updated: $count"
