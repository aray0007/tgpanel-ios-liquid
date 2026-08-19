const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const refPath = 'D:\\下载\\TG\\APP降级_2.5.4_秋名山.ipa';
const inspectDir = path.join('C:\\Users\\56745\\.gemini\\antigravity\\scratch\\tgpanel-ios-app', 'RefInspect');

const script = `
  Add-Type -AssemblyName System.IO.Compression.FileSystem;
  $zip = [System.IO.Compression.ZipFile]::OpenRead('${refPath}');
  foreach ($entry in $zip.Entries) {
    $targetPath = Join-Path '${inspectDir.replace(/\\/g, '\\\\')}' $entry.FullName;
    $targetDir = Split-Path $targetPath -Parent;
    if (-not (Test-Path $targetDir)) { [System.IO.Directory]::CreateDirectory($targetDir) | Out-Null }
    if (-not $entry.FullName.EndsWith('/')) {
      [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $targetPath, $true);
    }
  }
  $zip.Dispose();
  Write-Output 'Unpacked all files!';
`;

try {
  execSync(`powershell -Command "${script.replace(/\n/g, ' ')}"`, { stdio: 'inherit' });
} catch (e) {
  console.error('Error extracting:', e);
}

// List all files in RefInspect
const getFiles = (dir) => {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    const full = path.join(dir, file);
    const stat = fs.statSync(full);
    if (stat && stat.isDirectory()) {
      results = results.concat(getFiles(full));
    } else {
      results.push({ path: full, size: stat.size });
    }
  });
  return results;
};

const allFiles = getFiles(inspectDir);
console.log(`Total unpacked files: ${allFiles.length}`);
allFiles.forEach(f => {
  if (!f.path.includes('Localizable') && !f.path.endsWith('.strings')) {
    console.log(`  ${f.path.replace(inspectDir, '')} (${f.size} bytes)`);
  }
});
