[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$lessonRoot = Join-Path $repositoryRoot 'lessons'
$publishedRoot = Join-Path $repositoryRoot 'docs\flashcards'
$manifestPath = Join-Path $publishedRoot 'lessons.json'
$alphabetSource = Join-Path $repositoryRoot 'flashcards\azbuka'
$alphabetDestination = Join-Path $publishedRoot 'azbuka'

if (Test-Path -LiteralPath $alphabetSource) {
    New-Item -ItemType Directory -Path $alphabetDestination -Force | Out-Null
    Copy-Item -Path (Join-Path $alphabetSource '*') -Destination $alphabetDestination -Recurse -Force
}

$lessons = foreach ($directory in Get-ChildItem -LiteralPath $lessonRoot -Directory | Sort-Object Name) {
    if ($directory.Name -notmatch '^(?<number>\d{2})-(?<slug>.+)$') { continue }

    $source = Join-Path $directory.FullName 'flashcards.html'
    if (-not (Test-Path -LiteralPath $source)) { continue }

    $number = $Matches.number
    $destinationDirectory = Join-Path $publishedRoot "lesson-$number"
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination (Join-Path $destinationDirectory 'index.html') -Force
    $assetSource = Join-Path $directory.FullName 'assets'
    if (Test-Path -LiteralPath $assetSource) {
        Copy-Item -LiteralPath $assetSource -Destination $destinationDirectory -Recurse -Force
    }

    $title = (Get-Culture).TextInfo.ToTitleCase(($Matches.slug -replace '-', ' '))
    $version = (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash.Substring(0, 12).ToLowerInvariant()

    [ordered]@{
        number = $number
        title  = $title
        source = "lessons/$($directory.Name)/flashcards.html"
        version = $version
    }
}

$lessons | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $manifestPath
Write-Output "Published $($lessons.Count) flash-card decks under docs/flashcards."
