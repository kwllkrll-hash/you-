const fs = require('fs');
const path = require('path');

const files = [
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

// Read index.html to get the template components
const indexContent = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');

// Helper to extract component
function extractComponent(regexes, name) {
  for (const regex of regexes) {
    const match = indexContent.match(regex);
    if (match) return match[0];
  }
  console.error(`Failed to extract ${name} from index.html`);
  process.exit(1);
}

// Extract components from index.html
const newHeader = extractComponent([
  /<!-- Header \(glass\) -->\s*<header[\s\S]*?<\/header>/i,
  /<header class="site-header" data-header>[\s\S]*?<\/header>/i
], 'Header');

const newDrawer = extractComponent([
  /<!-- Magical Drawer -->\s*<aside[\s\S]*?<\/aside>/i,
  /<aside class="magical-drawer" data-nav-menu>[\s\S]*?<\/aside>/i
], 'Drawer');

const newFooter = extractComponent([
  /<!-- ========== FOOTER ========== -->\s*<footer[\s\S]*?<\/footer>/i,
  /<footer class="site-footer">[\s\S]*?<\/footer>/i
], 'Footer');

const newModal = extractComponent([
  /<!-- ========== ADMIN LOGIN MODAL ========== -->\s*<div class="admin-modal-overlay"[\s\S]*?<\/div>\s*<\/div>/i,
  /<div class="admin-modal-overlay" id="adminLoginModal"[\s\S]*?<\/div>\s*<\/div>/i
], 'Admin Modal');

const newScript = extractComponent([
  /<script src="\.\.\/shared\/app\.js"><\/script>\s*<script>[\s\S]*?<\/script>/i
], 'Script Block');

console.log("Successfully extracted all components from index.html!");

files.forEach(file => {
  const filePath = path.join(__dirname, file);
  if (!fs.existsSync(filePath)) {
    console.warn(`File not found: ${file}`);
    return;
  }

  let content = fs.readFileSync(filePath, 'utf8');

  // 1. Replace style block with link tag if any
  content = content.replace(/<style>[\s\S]*?<\/style>/i, '<link rel="stylesheet" href="a.css">');

  // 2. Remove backdrop if exists
  content = content.replace(/<div class="nav-backdrop" data-nav-backdrop><\/div>\s*/gi, '');

  // 3. Replace Header
  let headerReplaced = false;
  const headerRegexes = [
    /<!-- Header \(glass\) -->\s*<header[\s\S]*?<\/header>/i,
    /<header class="site-header" data-header>[\s\S]*?<\/header>/i
  ];
  for (const regex of headerRegexes) {
    if (regex.test(content)) {
      content = content.replace(regex, newHeader);
      headerReplaced = true;
      break;
    }
  }
  if (!headerReplaced) {
    console.warn(`Header not matched in ${file}, attempting generic replacement.`);
    content = content.replace(/<header class="site-header"[\s\S]*?<\/header>/i, newHeader);
  }

  // 4. Replace Drawer
  let drawerReplaced = false;
  const drawerRegexes = [
    /<!-- Magical Drawer -->\s*<aside[\s\S]*?<\/aside>/i,
    /<aside class="magical-drawer" data-nav-menu>[\s\S]*?<\/aside>/i
  ];
  for (const regex of drawerRegexes) {
    if (regex.test(content)) {
      content = content.replace(regex, newDrawer);
      drawerReplaced = true;
      break;
    }
  }
  if (!drawerReplaced) {
    console.warn(`Drawer not matched in ${file}, attempting generic replacement.`);
    content = content.replace(/<aside class="magical-drawer"[\s\S]*?<\/aside>/i, newDrawer);
  }

  // 5. Replace Footer
  let footerReplaced = false;
  const footerRegexes = [
    /<!-- ========== FOOTER ========== -->\s*<footer[\s\S]*?<\/footer>/i,
    /<footer class="site-footer">[\s\S]*?<\/footer>/i
  ];
  for (const regex of footerRegexes) {
    if (regex.test(content)) {
      content = content.replace(regex, newFooter);
      footerReplaced = true;
      break;
    }
  }
  if (!footerReplaced) {
    console.warn(`Footer not matched in ${file}, attempting generic replacement.`);
    content = content.replace(/<footer class="site-footer"[\s\S]*?<\/footer>/i, newFooter);
  }

  // 6. Replace Admin Login Modal
  let modalReplaced = false;
  const modalRegexes = [
    /<!-- ========== ADMIN LOGIN MODAL ========== -->\s*<div class="admin-modal-overlay"[\s\S]*?<\/div>\s*<\/div>/i,
    /<div class="admin-modal-overlay" id="adminLoginModal"[\s\S]*?<\/div>\s*<\/div>/i
  ];
  for (const regex of modalRegexes) {
    if (regex.test(content)) {
      content = content.replace(regex, newModal);
      modalReplaced = true;
      break;
    }
  }
  if (!modalReplaced) {
    console.warn(`Modal not matched in ${file}, attempting generic replacement.`);
    content = content.replace(/<div class="admin-modal-overlay"[\s\S]*?<\/div>\s*<\/div>/i, newModal);
  }

  // 7. Replace Script Block
  let scriptReplaced = false;
  const scriptRegexes = [
    /<script src="\.\.\/shared\/app\.js"><\/script>\s*<script>[\s\S]*?<\/script>/i
  ];
  for (const regex of scriptRegexes) {
    if (regex.test(content)) {
      content = content.replace(regex, newScript);
      scriptReplaced = true;
      break;
    }
  }
  if (!scriptReplaced) {
    console.warn(`Script block not matched in ${file}, attempting generic replacement.`);
    content = content.replace(/<script src="\.\.\/shared\/app\.js"><\/script>[\s\S]*?<script>[\s\S]*?<\/script>/i, newScript);
  }

  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`Successfully updated: ${file}`);
});

console.log("All files synchronized successfully!");

