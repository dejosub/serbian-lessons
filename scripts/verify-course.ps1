[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$required = @(
  'slides.md',
  'student-handout.md',
  'teacher-guide.md',
  'homework.md',
  'dictionary.md',
  'flashcards.md',
  'presentation.html',
  'flashcards.html',
  'vocabulary.html'
)

Push-Location $root
try {
  $temporaryVerification = Join-Path $root '.tmp-verify'
  if (Test-Path -LiteralPath $temporaryVerification) {
    $resolvedTemporary = (Resolve-Path -LiteralPath $temporaryVerification).Path
    if (-not $resolvedTemporary.StartsWith($root) -or
        (Split-Path $resolvedTemporary -Leaf) -ne '.tmp-verify') {
      throw "Refusing to remove unexpected temporary path: $resolvedTemporary"
    }
    Remove-Item -LiteralPath $resolvedTemporary -Recurse -Force
  }

  $syntaxErrors = @()
  foreach ($script in Get-ChildItem $PSScriptRoot -Filter '*.ps1') {
    $tokens = $null
    $errors = $null
    [void][Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$errors)
    $syntaxErrors += $errors
  }
  if ($syntaxErrors) {
    $syntaxErrors | Format-List
    throw 'One or more PowerShell scripts contain syntax errors.'
  }

  $lessonDirectories = @(Get-ChildItem (Join-Path $root 'lessons') -Directory | Where-Object Name -Match '^\d{2}-' | Sort-Object Name)
  $missing = foreach ($directory in $lessonDirectories) {
    $number = $directory.Name.Substring(0, 2)
    foreach ($name in $required + "lesson-$number-slides.pdf" + "lesson-$number-vocabulary.pdf") {
      $path = Join-Path $directory.FullName $name
      if (-not (Test-Path -LiteralPath $path)) { $path }
      elseif ($name.EndsWith('.pdf') -and (Get-Item -LiteralPath $path).Length -eq 0) { "$path (empty)" }
    }
  }
  if ($missing) { throw "Missing or empty deliverables:`n$($missing -join "`n")" }

  & (Join-Path $PSScriptRoot 'verify-pdfs.ps1')

  $manifest = Get-Content -Raw (Join-Path $root 'docs\flashcards\lessons.json') | ConvertFrom-Json
  if ($manifest.Count -ne $lessonDirectories.Count) {
    throw "Flash-card manifest has $($manifest.Count) entries for $($lessonDirectories.Count) lessons."
  }

  $mismatches = foreach ($directory in $lessonDirectories) {
    $number = $directory.Name.Substring(0, 2)
    $source = Join-Path $directory.FullName 'flashcards.html'
    $published = Join-Path $root "docs\flashcards\lesson-$number\index.html"
    if (-not (Test-Path -LiteralPath $published) -or
        (Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $published).Hash) {
      $number
    }
  }
  if ($mismatches) { throw "Published flash-card mismatches: $($mismatches -join ', ')" }

  & git diff --check
  if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }

  Write-Output "Course verification passed for $($lessonDirectories.Count) lessons."
  & git status --short
}
finally {
  Pop-Location
}
