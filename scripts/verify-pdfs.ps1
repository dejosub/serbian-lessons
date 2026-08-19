param(
  [int[]]$LessonNumbers
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$lessonDirs = Get-ChildItem (Join-Path $root 'lessons') -Directory | Sort-Object Name

if ($LessonNumbers) {
  $prefixes = $LessonNumbers | ForEach-Object { '{0:d2}-' -f $_ }
  $lessonDirs = $lessonDirs | Where-Object {
    $name = $_.Name
    @($prefixes | Where-Object { $name.StartsWith($_) }).Count -gt 0
  }
}

$results = foreach ($dir in $lessonDirs) {
  if ($dir.Name -notmatch '^(\d{2})-') { continue }
  $number = $Matches[1]
  $presentation = Join-Path $dir.FullName 'presentation.html'
  $pdf = Join-Path $dir.FullName "lesson-$number-slides.pdf"
  if (-not (Test-Path -LiteralPath $presentation) -or -not (Test-Path -LiteralPath $pdf)) { continue }

  $html = [IO.File]::ReadAllText($presentation)
  $pdfText = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($pdf))
  $htmlSlides = ([regex]::Matches($html, '<section\s+class="slide"')).Count
  $pdfPages = ([regex]::Matches($pdfText, '/Type\s*/Page(?!s)')).Count
  $images = ([regex]::Matches($pdfText, '/Subtype\s*/Image')).Count
  $mediaBox = ([regex]::Match($pdfText, '/MediaBox\s*\[[^\]]+\]')).Value
  $bytes = (Get-Item -LiteralPath $pdf).Length

  [pscustomobject]@{
    Lesson = $number
    MediaBox = $mediaBox
    HtmlSlides = $htmlSlides
    PdfPages = $pdfPages
    Images = $images
    Bytes = $bytes
    Status = if ($bytes -gt 0 -and $htmlSlides -eq $pdfPages) { 'OK' } else { 'FAIL' }
  }
}

$results | Format-Table -AutoSize
if (@($results | Where-Object Status -eq 'FAIL').Count -gt 0) {
  throw 'One or more slide PDFs failed verification.'
}
