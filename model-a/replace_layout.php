<?php
$files = [
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
];

$indexContent = file_get_contents(__DIR__ . '/index.html');

// Extract header
$headerMatch = [];
if (preg_match('/<!-- Header \(glass\) -->\s*<header[\s\S]*?<\/header>/i', $indexContent, $headerMatch)) {
    $newHeader = $headerMatch[0];
} else if (preg_match('/<header class="site-header" data-header>[\s\S]*?<\/header>/i', $indexContent, $headerMatch)) {
    $newHeader = $headerMatch[0];
} else {
    die("Failed to extract header from index.html\n");
}

// Extract drawer
$drawerMatch = [];
if (preg_match('/<!-- Magical Drawer -->\s*<aside[\s\S]*?<\/aside>/i', $indexContent, $drawerMatch)) {
    $newDrawer = $drawerMatch[0];
} else if (preg_match('/<aside class="magical-drawer" data-nav-menu>[\s\S]*?<\/aside>/i', $indexContent, $drawerMatch)) {
    $newDrawer = $drawerMatch[0];
} else {
    die("Failed to extract drawer from index.html\n");
}

foreach ($files as $file) {
    $filePath = __DIR__ . '/' . $file;
    if (!file_exists($filePath)) {
        echo "File not found: $file\n";
        continue;
    }

    $content = file_get_contents($filePath);

    // 1. Replace style block with link
    $content = preg_replace('/<style>[\s\S]*?<\/style>/i', '<link rel="stylesheet" href="a.css">', $content);

    // 2. Remove backdrop if exists
    $content = preg_replace('/<div class="nav-backdrop" data-nav-backdrop><\/div>\s*/i', '', $content);

    // 3. Replace old header
    $content = preg_replace('/<!-- Header \(glass\) -->\s*<header[\s\S]*?<\/header>/i', $newHeader, $content);
    $content = preg_replace('/<header class="site-header" data-header>[\s\S]*?<\/header>/i', $newHeader, $content);

    // 4. Replace old drawer
    $content = preg_replace('/<!-- Magical Drawer -->\s*<aside[\s\S]*?<\/aside>/i', $newDrawer, $content);
    $content = preg_replace('/<aside class="magical-drawer" data-nav-menu>[\s\S]*?<\/aside>/i', $newDrawer, $content);

    file_put_contents($filePath, $content);
    echo "Successfully updated: $file\n";
}
