const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const refPath = 'D:\\下载\\TG\\APP降级_2.5.4_秋名山.ipa';

console.log('Inspecting:', refPath);

if (!fs.existsSync(refPath)) {
  console.log('File does not exist at:', refPath);
  process.exit(1);
}

const stats = fs.statSync(refPath);
console.log(`File exists! Size: ${(stats.size / 1024 / 1024).toFixed(2)} MB (${stats.size} bytes)`);

// Unzip / list entries using AdmZip or child_process powershell Expand-Archive to a temp inspection folder
const inspectDir = path.join('C:\\Users\\56745\\.gemini\\antigravity\\scratch\\tgpanel-ios-app', 'RefInspect');
if (!fs.existsSync(inspectDir)) fs.mkdirSync(inspectDir, { recursive: true });

const { execSync } = require('child_process');

try {
  // Let's list files inside using PowerShell
  const script = `
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    $zip = [System.IO.Compression.ZipFile]::OpenRead('${refPath}');
    $zip.Entries | Select-Object FullName, Length | Export-Csv -Path '${path.join(inspectDir, 'entries.csv')}' -NoTypeInformation;
    $zip.Dispose();
  `;
  execSync(`powershell -Command "${script.replace(/\n/g, ' ')}"`, { stdio: 'inherit' });
  
  console.log('CSV of entries generated!');
  const csvContent = fs.readFileSync(path.join(inspectDir, 'entries.csv'), 'utf8');
  const lines = csvContent.split('\n').filter(Boolean);
  console.log(`Total files inside IPA: ${lines.length - 1}`);
  console.log('Top 40 files:');
  lines.slice(0, 45).forEach(l => console.log('  ' + l));
} catch (e) {
  console.error('Error listing zip:', e);
}
