[CmdletBinding()]
param(
  [string]$Lessons
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$selectionPath = Join-Path $PSScriptRoot 'publish-lessons.txt'
if ([string]::IsNullOrWhiteSpace($Lessons)) {
  if (-not (Test-Path -LiteralPath $selectionPath)) {
    throw "Lesson selection file not found: $selectionPath"
  }
  $Lessons = (Get-Content -Raw -LiteralPath $selectionPath).Trim()
}
$numbers = if ($Lessons -eq 'all') {
  @(Get-ChildItem (Join-Path $root 'lessons') -Directory | ForEach-Object {
    if ($_.Name -match '^(\d{2})-') { [int]$Matches[1] }
  })
}
else {
  @($Lessons -split ',' | ForEach-Object {
    $value = 0
    if (-not [int]::TryParse($_.Trim(), [ref]$value) -or $value -lt 1 -or $value -gt 99) {
      throw "Invalid lesson number: $_"
    }
    $value
  })
}

Push-Location $root
try {
  & (Join-Path $PSScriptRoot 'export-pdfs.ps1') -LessonNumbers $numbers
  & (Join-Path $PSScriptRoot 'verify-pdfs.ps1') -LessonNumbers $numbers
  & (Join-Path $PSScriptRoot 'sync-pages-flashcards.ps1')

  $mismatches = foreach ($number in $numbers) {
    $prefix = '{0:d2}-' -f $number
    $directory = Get-ChildItem (Join-Path $root 'lessons') -Directory |
      Where-Object Name -Like "$prefix*" |
      Select-Object -First 1
    if (-not $directory) { throw "Lesson $number not found." }

    $source = Join-Path $directory.FullName 'flashcards.html'
    $published = Join-Path $root ('docs\flashcards\lesson-{0:d2}\index.html' -f $number)
    if (-not (Test-Path -LiteralPath $published) -or
        (Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $published).Hash) {
      $number
    }
  }
  if ($mismatches) {
    throw "Published flash-card copies differ for lessons: $($mismatches -join ', ')"
  }

  Write-Output "Published and verified lessons: $($numbers -join ', ')"
}
finally {
  Pop-Location
}
