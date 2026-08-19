const { execSync } = require('child_process');

try {
  const out = execSync('gh run view 32206306597 --log-failed').toString();
  const lines = out.split('\n');
  const errors = lines.filter(l => l.includes('error:'));
  console.log('Compile Errors found:');
  errors.forEach(e => console.log('  ', e));
} catch (e) {
  console.error(e);
}
