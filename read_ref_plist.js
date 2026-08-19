const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const refPath = 'D:\\下载\\TG\\APP降级_2.5.4_秋名山.ipa';
const inspectDir = path.join('C:\\Users\\56745\\.gemini\\antigravity\\scratch\\tgpanel-ios-app', 'RefInspect');

const script = `
  Add-Type -AssemblyName System.IO.Compression.FileSystem;
  $zip = [System.IO.Compression.ZipFile]::OpenRead('${refPath}');
  $entry = $zip.GetEntry('Payload/APP.app/Info.plist');
  if ($entry) {
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, '${path.join(inspectDir, 'Info.plist')}', $true);
    Write-Output 'Info.plist extracted!';
  }
  $zip.Dispose();
`;

execSync(`powershell -Command "${script.replace(/\n/g, ' ')}"`, { stdio: 'inherit' });

console.log('Reading Info.plist...');
try {
  const content = execSync(`powershell -Command "Get-Content '${path.join(inspectDir, 'Info.plist')}'"`).toString();
  console.log(content.slice(0, 800));
} catch (e) {
  console.error(e);
}
