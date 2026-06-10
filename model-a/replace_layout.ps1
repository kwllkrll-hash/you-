# PowerShell script to synchronize layout components (Header, Drawer, Footer, Admin Modal) across all public pages
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# List of files to process
$files = @(
  'about.html',
  'programs.html',
  'projects.html',
  'news.html',
  'volunteers.html',
  'training.html',
  'partners.html',
  'stories.html',
  'contact.html',
  'support.html',
  'transparency.html',
  'search.html',
  'privacy.html',
  'terms.html',
  '404.html'
)

# Read index.html as the source template (using UTF8 to preserve Arabic encoding)
$indexContent = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# Helper function to extract content by regex
function Get-MatchValue($pattern, $source) {
    $match = [regex]::Match($source, $pattern)
    if ($match.Success) {
        return $match.Value
    }
    return $null
}

# Regex patterns to extract from index.html
$headerPattern = "(?is)<!-- Header \(glass\) -->\s*<header.*?</header>|<header class=`"site-header`" data-header>.*?</header>"
$drawerPattern = "(?is)<!-- Magical Drawer -->\s*<aside.*?</aside>|<aside class=`"magical-drawer`" data-nav-menu>.*?</aside>"
$footerPattern = "(?is)<!-- ========== FOOTER ========== -->\s*<footer.*?</footer>|<footer class=`"site-footer`">.*?</footer>"
$modalPattern  = "(?is)<!-- ========== ADMIN LOGIN MODAL ========== -->\s*<div class=`"admin-modal-overlay`".*?</div>\s*</div>|<div class=`"admin-modal-overlay`" id=`"adminLoginModal`".*?</div>\s*</div>"
$scriptPattern = "(?is)<script src=`"\.\./shared/app\.js`"></script>\s*<script>.*?</script>"

$newHeader = Get-MatchValue $headerPattern $indexContent
$newDrawer = Get-MatchValue $drawerPattern $indexContent
$newFooter = Get-MatchValue $footerPattern $indexContent
$newModal  = Get-MatchValue $modalPattern $indexContent
$newScript = Get-MatchValue $scriptPattern $indexContent

if (-not $newHeader) { throw "Failed to extract Header from index.html" }
if (-not $newDrawer) { throw "Failed to extract Drawer from index.html" }
if (-not $newFooter) { throw "Failed to extract Footer from index.html" }
if (-not $newModal)  { throw "Failed to extract Admin Modal from index.html" }
if (-not $newScript) { throw "Failed to extract Script Block from index.html" }

Write-Host "Extracted all components successfully from index.html!"

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        Write-Warning "File not found: $file"
        continue
    }

    Write-Host "Processing $file..."
    
    # Read file content with UTF8 to preserve Arabic characters
    $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

    # 1. Replace internal <style> block with link tag
    $content = [regex]::Replace($content, "(?is)<style>.*?</style>", '<link rel="stylesheet" href="a.css">')

    # 2. Remove backdrop element (now created dynamically in app.js)
    $content = [regex]::Replace($content, "(?is)<div class=`"nav-backdrop`" data-nav-backdrop></div>\s*", "")

    # 3. Replace Header
    if ([regex]::IsMatch($content, $headerPattern)) {
        $content = [regex]::Replace($content, $headerPattern, $newHeader)
    } else {
        Write-Warning "Header pattern not matched in $file. Trying generic replacement."
        $content = [regex]::Replace($content, "(?is)<header class=`"site-header`".*?</header>", $newHeader)
    }

    # 4. Replace Drawer
    if ([regex]::IsMatch($content, $drawerPattern)) {
        $content = [regex]::Replace($content, $drawerPattern, $newDrawer)
    } else {
        Write-Warning "Drawer pattern not matched in $file. Trying generic replacement."
        $content = [regex]::Replace($content, "(?is)<aside class=`"magical-drawer`".*?</aside>", $newDrawer)
    }

    # 5. Replace Footer
    if ([regex]::IsMatch($content, $footerPattern)) {
        $content = [regex]::Replace($content, $footerPattern, $newFooter)
    } else {
        Write-Warning "Footer pattern not matched in $file. Trying generic replacement."
        $content = [regex]::Replace($content, "(?is)<footer class=`"site-footer`".*?</footer>", $newFooter)
    }

    # 6. Replace Admin Login Modal
    if ([regex]::IsMatch($content, $modalPattern)) {
        $content = [regex]::Replace($content, $modalPattern, $newModal)
    } else {
        Write-Warning "Modal pattern not matched in $file. Trying generic replacement."
        $content = [regex]::Replace($content, "(?is)<div class=`"admin-modal-overlay`".*?</div>\s*</div>", $newModal)
    }

    # 7. Replace Script Block
    if ([regex]::IsMatch($content, $scriptPattern)) {
        $content = [regex]::Replace($content, $scriptPattern, $newScript)
    } else {
        Write-Warning "Script block pattern not matched in $file. Trying generic replacement."
        $content = [regex]::Replace($content, "(?is)<script src=`"\.\./shared/app\.js`"></script>.*?<script>.*?</script>", $newScript)
    }

    # Write the updated content back to the file using UTF8
    [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Successfully updated $file"
}

Write-Host "All files processed successfully!"
