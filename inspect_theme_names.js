const fs = require('fs');
const path = require('path');

const binPath = 'C:\\Users\\56745\\.gemini\\antigravity\\scratch\\tgpanel-ios-app\\RefInspect\\Payload\\APP.app\\APP';
const buf = fs.readFileSync(binPath, 'latin1');

const matches = [];
let re = /([A-Za-z0-9_]{3,}(?:Theme|Glass|Material|Color|Style|Gradient|Blur)[A-Za-z0-9_]*)/g;
let m;
while ((m = re.exec(buf)) !== null) {
  if (m[1].length > 5 && m[1].length < 40) {
    matches.push(m[1]);
  }
}

console.log('Theme & Material Symbols found:');
const unique = [...new Set(matches)];
unique.slice(0, 80).forEach(s => console.log('  ', s));
