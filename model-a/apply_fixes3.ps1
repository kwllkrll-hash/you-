$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# 1. CSS Additions
$cssToAdd = @"

/* =========================================
   Phase 2 Fixes (Grids, Search, Stats, Bugfixes)
   ========================================= */

/* Fix: Missing Grid Layouts for inner pages */
.news-grid, .gallery-grid, .partner-grid, .course-grid, .report-grid, .stats-row {
  display: grid;
  gap: 2rem;
}

/* Specific Grid Columns */
.news-grid { grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); }
.gallery-grid { grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.partner-grid { grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); align-items: center; justify-items: center; }
.course-grid { grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); }
.report-grid { grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); }
.stats-row { grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }

/* Card Styles */
.news-card, .course-card, .report-card {
  background: var(--surface);
  border-radius: var(--r-xl);
  overflow: hidden;
  box-shadow: var(--sh-md);
  transition: all 0.3s ease;
  border: 1px solid var(--border);
}
.news-card:hover, .course-card:hover, .report-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--sh-lg);
}
.news-card .thumb img { width: 100%; height: 200px; object-fit: cover; }
.news-card .body { padding: 1.5rem; }
.course-card .body { padding: 1.5rem; text-align: center; }
.course-icon { font-size: 3rem; margin-bottom: 1rem; }

.gallery-card {
  position: relative;
  border-radius: var(--r-xl);
  overflow: hidden;
  aspect-ratio: 4/3;
}
.gallery-card img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease; }
.gallery-card:hover img { transform: scale(1.1); }
.gallery-card .meta {
  position: absolute; bottom: 0; left: 0; right: 0;
  background: linear-gradient(0deg, rgba(0,0,0,0.8), transparent);
  padding: 2rem 1rem 1rem; color: #fff; text-align: center;
}

.partner-card {
  background: var(--surface);
  padding: 2rem;
  border-radius: var(--r-xl);
  box-shadow: var(--sh-sm);
  text-align: center;
  transition: transform 0.3s ease;
  width: 100%;
}
.partner-card:hover { transform: scale(1.05); }
.partner-card .logo { font-size: 3rem; margin-bottom: 1rem; }

.stat-box {
  background: var(--surface);
  padding: 2rem;
  border-radius: var(--r-xl);
  text-align: center;
  box-shadow: var(--sh-md);
}
.stat-box .number { font-size: 3rem; font-weight: 900; color: var(--you-green); margin-bottom: 0.5rem; }

/* Fix: Stats Text Visibility */
.stat-label {
  color: #ffffff !important;
  text-shadow: 0px 2px 4px rgba(0,0,0,0.7) !important;
  font-size: 1.2rem !important;
  font-weight: 800 !important;
  opacity: 1 !important;
}

/* Fix: Disappearing Story Images */
.story-card {
  isolation: isolate;
  z-index: 1;
}
.story-card img {
  z-index: -1 !important;
}

/* Fix: Large Search Box */
.search-box-large {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: var(--surface);
  padding: 1rem 1.5rem;
  border-radius: var(--r-full);
  box-shadow: var(--sh-lg);
  max-width: 800px;
  margin: 0 auto 3rem;
  border: 2px solid var(--border);
  transition: all 0.3s ease;
}
.search-box-large:focus-within {
  border-color: var(--you-green);
  box-shadow: 0 0 20px rgba(91, 168, 41, 0.2);
}
.search-box-large .search-icon {
  font-size: 2rem;
  color: var(--text-muted);
}
.search-box-large input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 1.5rem;
  color: var(--text);
  outline: none;
  font-family: inherit;
}
.search-box-large button {
  background: linear-gradient(135deg, var(--you-green), var(--you-green-400));
  color: #fff;
  border: none;
  padding: 1rem 2.5rem;
  font-size: 1.2rem;
  font-weight: 800;
  border-radius: var(--r-full);
  cursor: pointer;
  transition: transform 0.2s ease;
}
.search-box-large button:hover {
  transform: scale(1.05);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .search-box-large {
    flex-direction: column;
    border-radius: var(--r-xl);
    padding: 1.5rem;
  }
  .search-box-large input { font-size: 1.2rem; text-align: center; }
  .search-box-large button { width: 100%; }
}

"@

$tokensCss = "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\shared\tokens.css"
$currentCss = [System.IO.File]::ReadAllText($tokensCss, $utf8NoBom)
if (-not $currentCss.Contains("Phase 2 Fixes")) {
    $currentCss = $currentCss + "`r`n" + $cssToAdd
    [System.IO.File]::WriteAllText($tokensCss, $currentCss, $utf8NoBom)
    Write-Host "Appended Phase 2 CSS to tokens.css"
}

# 2. Update Search Box HTML in search.html
$searchHtml = "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\model-a\search.html"
$htmlContent = [System.IO.File]::ReadAllText($searchHtml, $utf8NoBom)

$oldSearchBox = @"
      <div class="search-box reveal">
        <input type="text" id="searchInput" data-ar-ph="ابحث عن مشروع، خبر، تقرير..." data-en-ph="Search projects, news, reports..." placeholder="ابحث عن مشروع، خبر، تقرير...">
        <button onclick="performSearch()" data-ar="بحث" data-en="Search">🔍 بحث</button>
      </div>
"@

$newSearchBox = @"
      <div class="search-box-large reveal">
        <div class="search-icon">🔎</div>
        <input type="text" id="searchInput" data-ar-ph="ما الذي تبحث عنه؟ مشاريع، أخبار، تقارير..." data-en-ph="What are you looking for? Projects, News, Reports..." placeholder="ما الذي تبحث عنه؟ مشاريع، أخبار، تقارير...">
        <button onclick="performSearch()" data-ar="بحث متقدم" data-en="Advanced Search">بحث متقدم</button>
      </div>
"@

if ($htmlContent.Contains('<div class="search-box reveal">')) {
    $htmlContent = $htmlContent.Replace($oldSearchBox, $newSearchBox)
    [System.IO.File]::WriteAllText($searchHtml, $htmlContent, $utf8NoBom)
    Write-Host "Updated search box in search.html"
}

Write-Host "All Phase 2 Tasks Completed!"
