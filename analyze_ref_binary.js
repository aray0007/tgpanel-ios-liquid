const fs = require('fs');
const path = require('path');

const binPath = 'C:\\Users\\56745\\.gemini\\antigravity\\scratch\\tgpanel-ios-app\\RefInspect\\Payload\\APP.app\\APP';

console.log('Analyzing binary:', binPath);
const buf = fs.readFileSync(binPath);
console.log('Read binary, size:', buf.length);

// Extract strings
const strList = [];
let cur = [];
for (let i = 0; i < buf.length; i++) {
  const b = buf[i];
  if (b >= 32 && b <= 126) {
    cur.push(String.fromCharCode(b));
  } else {
    if (cur.length >= 4) {
      strList.push(cur.join(''));
    }
    cur = [];
  }
}

console.log('Total extracted ASCII strings:', strList.length);

// Search for Swift module / View names
const swiftViews = strList.filter(s => s.includes('View') || s.includes('Controller') || s.includes('Style') || s.includes('Theme') || s.includes('Material') || s.includes('Gradient') || s.includes('Liquid') || s.includes('Glass'));
console.log(`Matching UI symbols: ${swiftViews.length}`);

const uniqueViews = [...new Set(swiftViews)].filter(s => s.length < 60 && !s.startsWith('/'));
console.log('\nTop 60 UI Symbols in reference app:');
uniqueViews.slice(0, 80).forEach(s => console.log('  ', s));

// Check specifically for custom SwiftUI libraries or packages
const frameworks = strList.filter(s => s.includes('.framework') || s.includes('.dylib') || s.includes('github.com'));
console.log('\nFrameworks / Git Repos:');
[...new Set(frameworks)].forEach(f => console.log('  ', f));
