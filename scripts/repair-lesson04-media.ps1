$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false)
$root = Split-Path -Parent $PSScriptRoot

function Read-Utf8([string]$path) { [IO.File]::ReadAllText($path, $utf8) }
function Write-Utf8([string]$path, [string]$text) { [IO.File]::WriteAllText($path, $text, $utf8) }

# This family uses deda, never deka. Apply the preference to authored web/source files.
$textFiles = Get-ChildItem (Join-Path $root 'lessons'), (Join-Path $root 'docs') -Recurse -File |
  Where-Object { $_.Extension -in '.md', '.html', '.json' }
foreach ($file in $textFiles) {
  $text = Read-Utf8 $file.FullName
  $text = $text.Replace('deke', 'dede').Replace('deka', 'deda').Replace('деке', 'деде').Replace('дека', 'деда')
  Write-Utf8 $file.FullName $text
}

$lesson = Join-Path $root 'lessons/04-at-the-table'
$names = @('pita','hleb','sir','salata','voda','kafa','sarma','cevapi','pasulj')

# Propagate Lesson 4's new cumulative vocabulary through the currently planned lessons.
foreach ($number in 5..7) {
  $dictionary = Get-ChildItem (Join-Path $root 'lessons') -Directory | Where-Object Name -Like ("{0:d2}-*" -f $number) |
    ForEach-Object { Join-Path $_.FullName 'dictionary.md' }
  if ($dictionary -and (Test-Path $dictionary)) {
    $text = Read-Utf8 $dictionary
    if (-not $text.Contains('| sarma | сарма |')) {
      $addition = "| kafa | кафа | coffee | 4 |`r`n| sarma | сарма | stuffed cabbage rolls | 4 |`r`n| ćevapi | ћевапи | grilled minced-meat sausages | 4 |`r`n| pasulj | пасуљ | beans; bean stew | 4 |"
      $text = $text.Replace('| kafa | кафа | coffee | 4 |', $addition)
      Write-Utf8 $dictionary $text
    }
  }

  $vocabulary = Get-ChildItem (Join-Path $root 'lessons') -Directory | Where-Object Name -Like ("{0:d2}-*" -f $number) |
    ForEach-Object { Join-Path $_.FullName 'vocabulary.html' }
  if ($vocabulary -and (Test-Path $vocabulary)) {
    $html = Read-Utf8 $vocabulary
    if (-not $html.Contains('["sarma","сарма"')) {
      $html = $html.Replace('["kafa","кафа","coffee","4"]', '["kafa","кафа","coffee","4"],["sarma","сарма","stuffed cabbage rolls","4"],["ćevapi","ћевапи","grilled minced-meat sausages","4"],["pasulj","пасуљ","beans; bean stew","4"]')
      Write-Utf8 $vocabulary $html
    }
  }
}

# Add a dedicated photo slide and keep page counters accurate.
$presentationPath = Join-Path $lesson 'presentation.html'
$presentation = Read-Utf8 $presentationPath
if (-not $presentation.Contains('Three Serbian dishes')) {
  $marker = '<section class="slide" data-page="6 / 14"><h1>Ask for something</h1>'
  $newSlide = '<section class="slide" data-page="6 / 15"><h1>Three Serbian dishes</h1><div style="display:grid;grid-template-columns:repeat(3,1fr);gap:18px;text-align:center;font-size:18pt"><div><img src="assets/sarma.jpg" style="width:100%;height:230px;object-fit:cover;border-radius:10px"><br><b>сарма</b> · sarma</div><div><img src="assets/cevapi.jpg" style="width:100%;height:230px;object-fit:cover;border-radius:10px"><br><b>ћевапи</b> · ćevapi</div><div><img src="assets/pasulj.jpg" style="width:100%;height:230px;object-fit:cover;border-radius:10px"><br><b>пасуљ</b> · pasulj</div></div><p>Which would you choose? Ask for it in Serbian.</p></section>'
  $presentation = $presentation.Replace($marker, "$newSlide`r`n$marker")
}
$page = 0
$presentation = [regex]::Replace($presentation, 'data-page="\d+ / \d+"', { param($m) $script:page++; 'data-page="' + $script:page + ' / 15"' })
Write-Utf8 $presentationPath $presentation

# Add photo-backed cards to the interactive deck.
$flashPath = Join-Path $lesson 'flashcards.html'
$flash = Read-Utf8 $flashPath
if (-not $flash.Contains("['sarma','сарма'")) {
  $needle = "['coffee','кафа','kafa',"
  $start = $flash.IndexOf($needle)
  $close = $flash.IndexOf(']', $start)
  $insert = ",['sarma','сарма','sarma','assets/sarma.jpg'],['ćevapi','ћевапи','ćevapi','assets/cevapi.jpg'],['bean stew / beans','пасуљ','pasulj','assets/pasulj.jpg']"
  $flash = $flash.Insert($close + 1, $insert)
  Write-Utf8 $flashPath $flash
}

# Extend the printable dictionary/cards data and photo map.
$vocabPath = Join-Path $lesson 'vocabulary.html'
$vocab = Read-Utf8 $vocabPath
if (-not $vocab.Contains('["sarma","сарма"')) {
  $vocab = $vocab.Replace('["kafa","кафа","coffee","4"]', '["kafa","кафа","coffee","4"],["sarma","сарма","stuffed cabbage rolls","4"],["ćevapi","ћевапи","grilled minced-meat sausages","4"],["pasulj","пасуљ","beans; bean stew","4"]')
  $vocab = $vocab.Replace('["coffee","кафа · kafa","4"]', '["coffee","кафа · kafa","4"],["sarma / stuffed cabbage rolls","сарма · sarma","4"],["ćevapi / grilled minced-meat sausages","ћевапи · ćevapi","4"],["bean stew / beans","пасуљ · pasulj","4"]')
}
$photoMap = 'const photos={"pie / pita":"assets/pita.jpg","bread":"assets/hleb.jpg","cheese":"assets/sir.jpg","salad":"assets/salata.jpg","water":"assets/voda.jpg","coffee":"assets/kafa.jpg","sarma / stuffed cabbage rolls":"assets/sarma.jpg","ćevapi / grilled minced-meat sausages":"assets/cevapi.jpg","bean stew / beans":"assets/pasulj.jpg"};const rows='
$vocab = [regex]::Replace($vocab, 'const photos=\{.*?\};const rows=', $photoMap)
Write-Utf8 $vocabPath $vocab

function Data-Url([string]$name) {
  $bytes = [IO.File]::ReadAllBytes((Join-Path $lesson "assets/$name.jpg"))
  'data:image/jpeg;base64,' + [Convert]::ToBase64String($bytes)
}

function Embed-OrderedImages([string]$path) {
  $text = Read-Utf8 $path
  $matches = [regex]::Matches($text, 'data:image/jpeg;base64,[^"'']+')
  if ($matches.Count -gt 0) {
    $script:imageIndex = 0
    $text = [regex]::Replace($text, 'data:image/jpeg;base64,[^"'']+', {
      param($match)
      if ($script:imageIndex -ge $names.Count) { throw "Too many embedded images in $path" }
      $replacement = "assets/$($names[$script:imageIndex]).jpg"
      $script:imageIndex++
      $replacement
    })
  }
  foreach ($name in $names) {
    $text = $text.Replace("assets/$name.jpg", (Data-Url $name))
  }
  Write-Utf8 $path $text
}

foreach ($file in 'presentation.html','flashcards.html','vocabulary.html') {
  Embed-OrderedImages (Join-Path $lesson $file)
}

# Lesson 4 uses a classic 4:3 classroom-slide canvas; keep photo-heavy pages compact.
$presentation = Read-Utf8 $presentationPath
$presentation = $presentation.Replace('@page{size:13.333in 7.5in;margin:0}', '@page{size:10in 7.5in;margin:0}')
$presentation = $presentation.Replace('.slide{width:13.333in;height:7.5in;', '.slide{width:10in;height:7.5in;')
$presentation = $presentation.Replace('Amaya kaže: „Da, molim. Pita je veoma ukusna!”</blockquote>', 'Amaya kaže: „Da, molim. Pita je veoma ukusna!” Marko kaže: „Ne, hvala. Sit sam.” Deda kaže: „Ukusno je!”</blockquote>')
$presentation = $presentation.Replace('Амаја каже: „Да, молим. Пита је веома укусна!”</blockquote>', 'Амаја каже: „Да, молим. Пита је веома укусна!”<br>Марко каже: „Не, хвала. Сит сам.”<br>Деда каже: „Укусно је!”</blockquote>')
Write-Utf8 $presentationPath $presentation

# Keep Lesson 5's browser deck responsive while enforcing one landscape slide per printed page.
$lesson5 = Get-ChildItem (Join-Path $root 'lessons') -Directory | Where-Object Name -Like '05-*' | Select-Object -First 1
if ($lesson5) {
  $path = Join-Path $lesson5.FullName 'presentation.html'
  $html = Read-Utf8 $path
  if (-not $html.Contains('@page{size:13.333in 7.5in')) {
    $html = $html.Replace(':root{', '@page{size:13.333in 7.5in;margin:0}:root{')
    $html = $html.Replace('*{box-sizing:border-box}', '*{box-sizing:border-box;-webkit-print-color-adjust:exact;print-color-adjust:exact}')
    $html = $html.Replace('.slide{width:min(1120px,100vw);min-height:min(630px,56.25vw);margin:24px auto;', '.slide{width:13.333in;height:7.5in;min-height:7.5in;margin:0;')
    $html = $html.Replace('box-shadow:0 10px 35px #0008;border-top:12px solid var(--green)}', 'overflow:hidden;box-shadow:none;border-top:12px solid var(--green);break-after:page;page-break-after:always}.slide:last-child{break-after:auto;page-break-after:auto}')
    Write-Utf8 $path $html
  }
}

