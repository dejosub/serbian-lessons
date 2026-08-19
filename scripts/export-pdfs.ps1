param(
  [int[]]$LessonNumbers
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path -LiteralPath $edge)) { throw "Microsoft Edge not found at $edge" }

$lessonDirs = Get-ChildItem (Join-Path $root 'lessons') -Directory | Sort-Object Name
if ($LessonNumbers) {
  $wanted = $LessonNumbers | ForEach-Object { '{0:d2}-' -f $_ }
  $lessonDirs = $lessonDirs | Where-Object {
    $name = $_.Name
    $wanted | Where-Object { $name.StartsWith($_) }
  }
}

foreach ($dir in $lessonDirs) {
  if ($dir.Name -notmatch '^(\d{2})-') { continue }
  $number = $Matches[1]
  $jobs = @(
    @{ Input = 'presentation.html'; Output = "lesson-$number-slides.pdf" },
    @{ Input = 'vocabulary.html'; Output = "lesson-$number-vocabulary.pdf" }
  )
  foreach ($job in $jobs) {
    $inputPath = Join-Path $dir.FullName $job.Input
    if (-not (Test-Path -LiteralPath $inputPath)) { continue }
    $outputPath = Join-Path $dir.FullName $job.Output
    $url = 'file:///' + $inputPath.Replace('\', '/')
    & $edge --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="$outputPath" $url
    if (-not (Test-Path -LiteralPath $outputPath) -or (Get-Item -LiteralPath $outputPath).Length -eq 0) {
      throw "PDF export failed: $outputPath"
    }
  }
}

