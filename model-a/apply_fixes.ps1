$dir = "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\model-a"
$htmlFiles = Get-ChildItem -Path $dir -Filter *.html -Recurse

$images = @(
    "IMG-20260605-WA0002.jpg",
    "IMG-20260605-WA0005.jpg",
    "IMG-20260605-WA0010.jpg",
    "IMG-20260605-WA0021.jpg",
    "IMG-20260605-WA0032.jpg",
    "IMG-20260605-WA0045.jpg",
    "IMG-20260605-WA0053.jpg",
    "IMG-20260605-WA0076.jpg"
)

foreach ($file in $htmlFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $modified = $false

    # 1. Replace logo.svg with logo-full.png
    if ($content.Contains("logo.svg")) {
        $content = $content.Replace("logo.svg", "logo-full.png")
        $modified = $true
    }

    # 2. Remove Admin button from footer using a 100% ASCII regex pattern to avoid encoding issues
    $adminBtnRegex = '(?i)<button\s+class="btn\s+btn-outline"\s+style="[^"]*"\s+onclick="openAdminLogin\(\)"[^>]*>.*?</button>'
    if ([regex]::IsMatch($content, $adminBtnRegex)) {
        $content = [regex]::Replace($content, $adminBtnRegex, "")
        $modified = $true
    }

    # 3. Replace unsplash images with local ones
    $unsplashRegex = 'https://images\.unsplash\.com/[^''"\s>]+'
    $unsplashMatches = [regex]::Matches($content, $unsplashRegex)
    if ($unsplashMatches.Count -gt 0) {
        $relativeDepth = ""
        if ($file.FullName.Contains("admin")) {
            $relativeDepth = "../../images/"
        } else {
            $relativeDepth = "../images/"
        }

        $imgIndex = 0
        foreach ($match in $unsplashMatches) {
            $url = $match.Value
            $localImg = $relativeDepth + $images[$imgIndex % $images.Count]
            $imgIndex++
            
            $escapedUrl = [regex]::Escape($url)
            $regex = [regex]$escapedUrl
            $content = $regex.Replace($content, $localImg, 1)
        }
        $modified = $true
    }

    if ($modified) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        Write-Host "Updated: $($file.Name)"
    }
}

# 4. Modify shared/tokens.css
$tokensPath = "c:\xampp\htdocs\pro\code_sandbox_light_git_ce4c12b6_1780968182\shared\tokens.css"
if (Test-Path $tokensPath) {
    $cssContent = [System.IO.File]::ReadAllText($tokensPath)
    if (-not $cssContent.Contains("/* --- LEGENDARY DESIGN OVERRIDES --- */")) {
        $overrides = @"


/* --- LEGENDARY DESIGN OVERRIDES --- */

/* 1. Dark mode compatibility for the PNG logo */
[data-theme="dark"] .brand img,
[data-theme="dark"] .drawer-logo,
[data-theme="dark"] .footer-brand img,
[data-theme="dark"] .admin-logo,
[data-theme="dark"] .sidebar-header img {
  filter: brightness(0) invert(1) !important;
}

/* 2. Hero Title responsiveness and overflow clipping fix */
.hero-title {
  padding-inline: 0.05em 0.15em !important;
  line-height: 1.25 !important;
  overflow: visible !important;
  display: inline-block !important;
  max-width: 100% !important;
  word-wrap: break-word !important;
}

/* 3. Gradient Improvements for Heroes and Footer (Purple-Blue-Green) */
.hero-magical,
.page-hero {
  background: linear-gradient(135deg, var(--you-purple) 0%, var(--you-navy) 50%, var(--you-green-600) 100%) !important;
}

.site-footer {
  background: linear-gradient(135deg, var(--you-purple-dark) 0%, var(--you-navy-700) 50%, var(--you-green-600) 100%) !important;
}

/* Theme compatibility for dark mode gradients */
[data-theme="dark"] .hero-magical,
[data-theme="dark"] .page-hero {
  background: linear-gradient(135deg, var(--you-purple-dark) 0%, #061930 50%, #153008 100%) !important;
}

[data-theme="dark"] .site-footer {
  background: linear-gradient(135deg, var(--you-purple-dark) 0%, #04101e 50%, #0c1a05 100%) !important;
}
"@
        [System.IO.File]::WriteAllText($tokensPath, $cssContent + $overrides)
        Write-Host "Updated shared/tokens.css with overrides."
    } else {
        Write-Host "shared/tokens.css already contains overrides."
    }
} else {
    Write-Host "shared/tokens.css not found!"
}

Write-Host "All fixes applied successfully!"
