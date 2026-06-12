const fs = require('fs');
const path = require('path');

const baseDir = __dirname;

const images = [
  "IMG-20260605-WA0002.jpg",
  "IMG-20260605-WA0005.jpg",
  "IMG-20260605-WA0010.jpg",
  "IMG-20260605-WA0021.jpg",
  "IMG-20260605-WA0032.jpg",
  "IMG-20260605-WA0045.jpg",
  "IMG-20260605-WA0053.jpg",
  "IMG-20260605-WA0076.jpg"
];

// Helper to recursively get files
function getFiles(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat && stat.isDirectory()) {
      results = results.concat(getFiles(fullPath));
    } else if (file.endsWith('.html')) {
      results.push(fullPath);
    }
  });
  return results;
}

const htmlFiles = getFiles(baseDir);
console.log(`Found ${htmlFiles.length} HTML files.`);

htmlFiles.forEach(filePath => {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // 1. Replace logo.svg with logo-full.png
  if (content.includes('logo.svg')) {
    content = content.replace(/logo\.svg/g, 'logo-full.png');
    modified = true;
  }

  // 2. Remove Admin button from footer
  const adminBtn = '<button class="btn btn-outline" style="margin-top: 1rem; padding: 0.4rem 1rem;" onclick="openAdminLogin()" data-ar="🔒 بوابة الإدارة" data-en="🔒 Admin Portal">🔒 بوابة الإدارة</button>';
  if (content.includes(adminBtn)) {
    content = content.replace(adminBtn, '');
    modified = true;
  }

  // 3. Replace unsplash images with local ones
  const unsplashRegex = /https:\/\/images\.unsplash\.com\/[^\s"'>]+/g;
  if (unsplashRegex.test(content)) {
    // Determine the relative path prefix to images folder
    // baseDir is model-a/
    // If the file is in model-a/admin/, relative path is ../../images/
    // If the file is in model-a/, relative path is ../images/
    const relativeDepth = path.relative(baseDir, path.dirname(filePath));
    const prefix = relativeDepth ? '../../images/' : '../images/';
    
    let imgIndex = 0;
    content = content.replace(unsplashRegex, () => {
      const imgName = images[imgIndex % images.length];
      imgIndex++;
      return prefix + imgName;
    });
    modified = true;
  }

  if (modified) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated: ${path.relative(baseDir, filePath)}`);
  }
});

// 4. Update shared/tokens.css with legendary design overrides
const tokensPath = path.join(baseDir, '..', 'shared', 'tokens.css');
if (fs.existsSync(tokensPath)) {
  let cssContent = fs.readFileSync(tokensPath, 'utf8');
  
  const overrides = `
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
`;

  if (!cssContent.includes('/* --- LEGENDARY DESIGN OVERRIDES --- */')) {
    fs.writeFileSync(tokensPath, cssContent + overrides, 'utf8');
    console.log('Updated: shared/tokens.css with legendary overrides.');
  } else {
    console.log('shared/tokens.css already contains overrides.');
  }
} else {
  console.log('shared/tokens.css not found!');
}

console.log('All fixes applied successfully!');
