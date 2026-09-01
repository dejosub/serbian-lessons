[CmdletBinding()]
param([int[]]$LessonNumbers = 1..4)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$style = '<style id="star-support-style">main:has(.star-tools){grid-template-rows:auto auto 1fr auto}.star-tools{display:grid;grid-template-columns:1fr 1fr;gap:.75rem;margin-bottom:.75rem}.star-tools button{min-height:3.2rem;border:0;border-radius:1rem;padding:.7rem;font:inherit;font-weight:750;background:#e5b94f;color:#17232d}.star-tools button.active{background:#ffe08a}.star-empty{font-size:clamp(1.5rem,6vw,2.5rem)}#card img.star-front-image{max-width:100%;max-height:330px;object-fit:contain}</style>'
$tools = '<div class="star-tools"><button id="star-card" type="button">&#9734; Star</button><button id="star-filter" type="button" aria-pressed="false">Starred only (0)</button></div>'
$scriptTemplate = @'
<script id="star-support-script">(()=>{
const lesson='__LESSON__',key=`serbian-lessons.flashcards.lesson-${lesson}.starred`,deck=cards.map((c,i)=>Array.isArray(c)?{id:(c[0]+'').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')||`card-${i}`,en:c[0],cy:c[1],la:c[2],image:typeof c[3]==='string'&&c[3].startsWith('data:image/')?c[3]:''}:{id:(c.en+'').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')||`card-${i}`,en:c.en,cy:c.sr,la:'',image:''});
let stars=new Set,only=false,h=[],p=-1,cur=-1,back=false,storage=true;try{const x=JSON.parse(localStorage.getItem(key)||'[]');if(Array.isArray(x))stars=new Set(x.filter(id=>deck.some(c=>c.id===id)))}catch(e){storage=false}
const cardEl=document.querySelector('#card'),statusEl=document.querySelector('#status'),prevEl=document.querySelector('#prev'),nextEl=document.querySelector('#next'),starEl=document.querySelector('#star-card'),filterEl=document.querySelector('#star-filter');
const available=()=>deck.map((_,i)=>i).filter(i=>!only||stars.has(deck[i].id));function save(){try{localStorage.setItem(key,JSON.stringify([...stars]))}catch(e){storage=false}}
function draw(){filterEl.textContent=`Starred only (${stars.size})`;filterEl.classList.toggle('active',only);filterEl.setAttribute('aria-pressed',String(only));if(cur<0){cardEl.innerHTML='<div class="star-empty">No starred cards yet.</div>';starEl.disabled=prevEl.disabled=nextEl.disabled=true;statusEl.textContent=storage?'Star a card, then return to this view.':'Stars are available for this session only.';return}const c=deck[cur],marked=stars.has(c.id);if(back){cardEl.innerHTML=`<div><div style="font-size:clamp(1.8rem,8vw,3.25rem);font-weight:720">${c.cy}</div>${c.la?`<div style="font-size:1.2rem;margin-top:1rem;color:#62706b">${c.la}</div>`:''}</div>`}else{cardEl.innerHTML=c.image?`<img class="star-front-image" src="${c.image}" alt="">`:`<div style="font-size:clamp(1.8rem,8vw,3.25rem);font-weight:720">${c.en}</div>`}starEl.disabled=false;starEl.textContent=marked?'\u2605 Starred':'\u2606 Star';starEl.classList.toggle('active',marked);prevEl.disabled=p<=0;nextEl.disabled=available().length<2;statusEl.textContent=storage?`Seen ${p+1} \u00b7 ${available().length} cards in this view`:'Stars are available for this session only.'}
function pick(){const a=available();if(!a.length){cur=-1;draw();return}if(p<h.length-1)h=h.slice(0,p+1);const recent=h.slice(-10),pool=a.filter(i=>!recent.includes(i)),choices=pool.length?pool:a.filter(i=>i!==cur),final=choices.length?choices:a;cur=final[Math.floor(Math.random()*final.length)];h.push(cur);p++;back=false;draw()}
function intercept(el,type,fn){el.addEventListener(type,e=>{e.preventDefault();e.stopImmediatePropagation();fn()},true)}intercept(cardEl,'click',()=>{if(cur>=0){back=!back;draw()}});intercept(nextEl,'click',pick);intercept(prevEl,'click',()=>{if(p>0){p--;cur=h[p];back=false;draw()}});intercept(starEl,'click',()=>{if(cur<0)return;const id=deck[cur].id;stars.has(id)?stars.delete(id):stars.add(id);save();if(only&&!stars.has(id)){h=[];p=-1;pick()}else draw()});intercept(filterEl,'click',()=>{only=!only;h=[];p=-1;cur=-1;pick()});document.addEventListener('keydown',e=>{if(e.key==='ArrowLeft'||e.key==='ArrowRight'){e.preventDefault();e.stopImmediatePropagation();(e.key==='ArrowLeft'?prevEl:nextEl).click()}},true);pick();
})();</script>
'@

foreach ($number in $LessonNumbers) {
    $prefix = '{0:d2}-' -f $number
    $directory = Get-ChildItem (Join-Path $root 'lessons') -Directory | Where-Object Name -Like "$prefix*" | Select-Object -First 1
    if (-not $directory) { throw "Lesson $number not found." }
    $path = Join-Path $directory.FullName 'flashcards.html'
    $html = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
    if ($html.Contains('id="star-support-script"')) { continue }
    $html = $html.Replace('</head>', "$style</head>")
    $html = [regex]::Replace($html, '(<(?:button|div)\s+id="card")', "$tools`$1", 1)
    if (-not $html.Contains('id="status"')) {
        $html = $html.Replace('<div class="controls">', '<p id="status" class="hint" aria-live="polite"></p><div class="controls">')
    }
    $script = $scriptTemplate.Replace('__LESSON__', ('{0:d2}' -f $number))
    $html = $html.Replace('</body>', "$script</body>")
    [IO.File]::WriteAllText($path, $html, (New-Object Text.UTF8Encoding $false))
    Write-Output "Added star support to Lesson $number."
}
