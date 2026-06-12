$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# 1. Append CSS for logo to tokens.css
$cssPath = "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\shared\tokens.css"
$logoCssPath = "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\shared\logo-styles.css"
$cssContent = [System.IO.File]::ReadAllText($cssPath, $utf8NoBom)
$logoCss = [System.IO.File]::ReadAllText($logoCssPath, $utf8NoBom)

if (-not $cssContent.Contains("Logo Size Harmonization")) {
    $cssContent = $cssContent + "`r`n" + $logoCss
    [System.IO.File]::WriteAllText($cssPath, $cssContent, $utf8NoBom)
    Write-Host "Appended logo CSS to tokens.css"
}

# 2. Replace missing genspark images
$htmlFiles = Get-ChildItem -Path "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\model-a" -Filter *.html -Recurse
$imageDir = "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\images"
$images = Get-ChildItem -Path $imageDir -Filter *.jpg | Select-Object -ExpandProperty Name

$imgCount = $images.Count
$imgIndex = 0

foreach ($file in $htmlFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    $originalContent = $content

    $relativePath = $file.FullName.Substring("c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\model-a".Length)
    $depth = ($relativePath -split "\\").Count - 2
    if ($depth -lt 0) { $depth = 0 }
    
    $prefix = "../"
    for ($i = 0; $i -lt $depth; $i++) {
        $prefix += "../"
    }
    $imgPrefix = $prefix + "images/"

    $gensparkRegex = 'https://www\.genspark\.ai/api/files/s/[a-zA-Z0-9_]+'
    $matches = [regex]::Matches($content, $gensparkRegex)
    if ($matches.Count -gt 0) {
        foreach ($match in $matches) {
            $imgName = $images[$imgIndex % $imgCount]
            $imgIndex++
            $newSrc = $imgPrefix + $imgName
            $content = $content.Replace($match.Value, $newSrc)
        }
    }

    if ($content -cne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        Write-Host "Fixed missing images in: $($file.Name)"
    }
}
Write-Host "All tasks completed successfully!"
