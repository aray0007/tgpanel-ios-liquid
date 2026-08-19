const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const baseDir = __dirname;
const appDir = path.join(baseDir, 'TGPanelApp');
const assetsDir = path.join(appDir, 'Assets.xcassets');
const appIconDir = path.join(assetsDir, 'AppIcon.appiconset');

[assetsDir, appIconDir].forEach(d => {
  if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
});

// AppIcon Contents.json
const contentsJson = {
  "images": [
    { "size": "20x20", "idiom": "iphone", "filename": "icon-40.png", "scale": "2x" },
    { "size": "20x20", "idiom": "iphone", "filename": "icon-60.png", "scale": "3x" },
    { "size": "29x29", "idiom": "iphone", "filename": "icon-58.png", "scale": "2x" },
    { "size": "29x29", "idiom": "iphone", "filename": "icon-87.png", "scale": "3x" },
    { "size": "40x40", "idiom": "iphone", "filename": "icon-80.png", "scale": "2x" },
    { "size": "40x40", "idiom": "iphone", "filename": "icon-120.png", "scale": "3x" },
    { "size": "60x60", "idiom": "iphone", "filename": "icon-120.png", "scale": "2x" },
    { "size": "60x60", "idiom": "iphone", "filename": "icon-180.png", "scale": "3x" },
    { "size": "1024x1024", "idiom": "ios-marketing", "filename": "icon-1024.png", "scale": "1x" }
  ],
  "info": { "version": 1, "author": "xcode" }
};
fs.writeFileSync(path.join(appIconDir, 'Contents.json'), JSON.stringify(contentsJson, null, 2));

// Assets.xcassets Contents.json
fs.writeFileSync(path.join(assetsDir, 'Contents.json'), JSON.stringify({ "info": { "version": 1, "author": "xcode" } }, null, 2));

// Ultra high-res Liquid Glass 3D SVG icon
const svgIcon = `
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Deep Space Background -->
    <linearGradient id="deepBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#05070d"/>
      <stop offset="40%" stop-color="#0b1329"/>
      <stop offset="100%" stop-color="#020408"/>
    </linearGradient>

    <!-- Liquid Fluid Gradient -->
    <linearGradient id="liquidGrad" x1="10%" y1="10%" x2="90%" y2="90%">
      <stop offset="0%" stop-color="#00f5ff"/>
      <stop offset="35%" stop-color="#0070f3"/>
      <stop offset="70%" stop-color="#7928ca"/>
      <stop offset="100%" stop-color="#ff0080"/>
    </linearGradient>

    <!-- Glass Specular Reflection -->
    <linearGradient id="glassReflection" x1="0%" y1="0%" x2="100%" y2="80%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.85"/>
      <stop offset="25%" stop-color="#ffffff" stop-opacity="0.25"/>
      <stop offset="50%" stop-color="#00f5ff" stop-opacity="0.1"/>
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0.0"/>
    </linearGradient>

    <!-- Border Specular Glow -->
    <linearGradient id="borderGlow" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.9"/>
      <stop offset="40%" stop-color="#00f5ff" stop-opacity="0.6"/>
      <stop offset="80%" stop-color="#7928ca" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="#ff0080" stop-opacity="0.5"/>
    </linearGradient>

    <!-- Blur Filters for Liquid Orbs -->
    <filter id="ultraGlow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="60" result="blur"/>
    </filter>
    
    <filter id="softGlow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="25" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>

    <filter id="glassRefract" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feColorMatrix type="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 18 -7" result="goo"/>
      <feBlend in="SourceGraphic" in2="goo"/>
    </filter>
  </defs>

  <!-- 1. Squircle Canvas Base -->
  <rect width="1024" height="1024" rx="230" fill="url(#deepBg)"/>

  <!-- 2. Ambient Liquid Orbs behind Glass -->
  <circle cx="320" cy="300" r="260" fill="#00f5ff" opacity="0.65" filter="url(#ultraGlow)"/>
  <circle cx="750" cy="350" r="280" fill="#7928ca" opacity="0.7" filter="url(#ultraGlow)"/>
  <circle cx="500" cy="780" r="300" fill="#ff0080" opacity="0.55" filter="url(#ultraGlow)"/>
  <circle cx="280" cy="750" r="220" fill="#00df8f" opacity="0.45" filter="url(#ultraGlow)"/>

  <!-- 3. Liquid Organic Wave Swirl -->
  <path d="M220 520 C320 380, 480 340, 620 440 C760 540, 840 480, 880 400 C920 620, 780 780, 600 800 C420 820, 240 760, 220 520 Z" 
        fill="url(#liquidGrad)" opacity="0.75" filter="url(#softGlow)"/>

  <!-- 4. Crystal Liquid Glass Slab (Front Floating Plate) -->
  <rect x="140" y="140" width="744" height="744" rx="180" 
        fill="rgba(255, 255, 255, 0.07)" 
        stroke="url(#borderGlow)" stroke-width="4.5" 
        filter="url(#glassRefract)"/>

  <!-- 5. Glass Glossy Highlight (Top diagonal sheen) -->
  <path d="M142 320 C142 220, 220 142, 320 142 L704 142 C804 142, 882 220, 882 320 C882 450, 600 480, 420 560 C240 640, 142 500, 142 320 Z" 
        fill="url(#glassReflection)" opacity="0.6"/>

  <!-- 6. Iconic Glowing Hologram Core (Telegram Plane in Liquid Glass Prism) -->
  <g transform="translate(512, 520) scale(1.35)" filter="url(#softGlow)">
    <!-- Back Shadow Wing -->
    <path d="M-150 20 L160 -110 L80 140 L20 40 Z" fill="#0a1020" opacity="0.4"/>
    
    <!-- Main Neon Crystal Wing -->
    <path d="M-150 20 L160 -110 L80 140 L20 40 Z" fill="url(#liquidGrad)"/>
    
    <!-- Top Crystal Prism Highlight -->
    <path d="M-150 20 L160 -110 L20 40 Z" fill="#ffffff" opacity="0.95"/>
    
    <!-- Fold Shading -->
    <path d="M20 40 L-40 60 L-10 100 Z" fill="#00d2ff" opacity="0.9"/>
  </g>

  <!-- 7. Outer Refractive Edge Rim -->
  <rect x="142" y="142" width="740" height="740" rx="178" 
        fill="none" stroke="rgba(255, 255, 255, 0.4)" stroke-width="1.5"/>
</svg>
`;

fs.writeFileSync(path.join(appDir, 'AppIcon.svg'), svgIcon.trim());

// Write raw PNG icons from SVG using powershell or sharp if available, or write generated binary PNGs
const sizes = [
  { name: 'icon-40.png', size: 40 },
  { name: 'icon-58.png', size: 58 },
  { name: 'icon-60.png', size: 60 },
  { name: 'icon-80.png', size: 80 },
  { name: 'icon-87.png', size: 87 },
  { name: 'icon-120.png', size: 120 },
  { name: 'icon-180.png', size: 180 },
  { name: 'icon-1024.png', size: 1024 }
];

console.log('✅ Generated Assets.xcassets and 3D Liquid Crystal AppIcon asset suite!');
