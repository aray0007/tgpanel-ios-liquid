const fs = require('fs');
const path = require('path');

const binPath = 'C:\\Users\\56745\\.gemini\\antigravity\\scratch\\tgpanel-ios-app\\RefInspect\\Payload\\APP.app\\APP';
const buf = fs.readFileSync(binPath, 'latin1');

function findNear(term, radius = 500) {
  let idx = 0;
  const results = [];
  while ((idx = buf.indexOf(term, idx)) !== -1) {
    const start = Math.max(0, idx - radius);
    const end = Math.min(buf.length, idx + term.length + radius);
    results.push(buf.substring(start, end).replace(/[\x00-\x1f]/g, ' '));
    idx += term.length;
    if (results.length > 5) break;
  }
  return results;
}

console.log('=== FloatingThemeOption / AppTheme ===');
findNear('AppTheme').forEach(r => console.log('----\n' + r));

console.log('=== TabbarView ===');
findNear('TabbarView').forEach(r => console.log('----\n' + r));
