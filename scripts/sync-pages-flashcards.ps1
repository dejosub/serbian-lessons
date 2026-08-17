[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$lessonRoot = Join-Path $repositoryRoot 'lessons'
$publishedRoot = Join-Path $repositoryRoot 'docs\flashcards'
$manifestPath = Join-Path $publishedRoot 'lessons.json'

$lessons = foreach ($directory in Get-ChildItem -LiteralPath $lessonRoot -Directory | Sort-Object Name) {
    if ($directory.Name -notmatch '^(?<number>\d{2})-(?<slug>.+)$') { continue }

    $source = Join-Path $directory.FullName 'flashcards.html'
    if (-not (Test-Path -LiteralPath $source)) { continue }

    $number = $Matches.number
    $destinationDirectory = Join-Path $publishedRoot "lesson-$number"
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination (Join-Path $destinationDirectory 'index.html') -Force

    $title = (Get-Culture).TextInfo.ToTitleCase(($Matches.slug -replace '-', ' '))

    [ordered]@{
        number = $number
        title  = $title
        source = "lessons/$($directory.Name)/flashcards.html"
    }
}

$lessons | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $manifestPath
Write-Output "Published $($lessons.Count) flash-card decks under docs/flashcards."
