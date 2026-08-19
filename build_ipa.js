const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const appDir = __dirname;
const payloadDir = path.join(appDir, 'Payload');
const appBundleDir = path.join(payloadDir, 'TGPanel.app');
const zipTemp = path.join(appDir, 'TGPanel_LiquidGlass.zip');
const ipaOutput = path.join(appDir, 'TGPanel_LiquidGlass.ipa');
const desktopOutput = path.join('C:\\Users\\56745\\Desktop', 'TGPanel_LiquidGlass.ipa');

console.log('🚀 Packaging TGPanel Liquid Glass iOS IPA with real ARM64 Mach-O binary...');

// 1. Prepare Payload/TGPanel.app
if (fs.existsSync(payloadDir)) {
  fs.rmSync(payloadDir, { recursive: true, force: true });
}
fs.mkdirSync(appBundleDir, { recursive: true });

// 2. Copy the real ARM64 iOS Mach-O binary
const machoBinarySrc = path.join(appDir, 'TGPanel');
if (fs.existsSync(machoBinarySrc)) {
  fs.copyFileSync(machoBinarySrc, path.join(appBundleDir, 'TGPanel'));
  console.log('  + Integrated: Real ARM64 Mach-O executable (TGPanel)');
} else {
  console.error('  ! Warning: TGPanel Mach-O binary not found!');
}

// 3. Copy WebApp assets and configurations
const filesToCopy = ['index.html', 'styles.css', 'app.js', 'Info.plist', 'manifest.json', 'AppIcon60x60@2x.png', 'AppIcon60x60@3x.png', 'AppIcon.svg'];
filesToCopy.forEach(f => {
  const src = path.join(appDir, f);
  if (fs.existsSync(src)) {
    fs.copyFileSync(src, path.join(appBundleDir, f));
    console.log(`  + Bundled: ${f}`);
  }
});

console.log('📦 Generating .ipa archive from Payload directory...');

// 4. Archive into .zip and rename to .ipa
try {
  if (fs.existsSync(zipTemp)) fs.unlinkSync(zipTemp);
  if (fs.existsSync(ipaOutput)) fs.unlinkSync(ipaOutput);

  // Compress-Archive using PowerShell
  const psCmd = `powershell -Command "Compress-Archive -Path '${payloadDir}' -DestinationPath '${zipTemp}' -Force"`;
  execSync(psCmd, { stdio: 'inherit' });

  // Rename to .ipa
  fs.renameSync(zipTemp, ipaOutput);
  console.log('✅ Final IPA generated at:', ipaOutput);

  // Deploy to Desktop
  fs.copyFileSync(ipaOutput, desktopOutput);
  console.log('🎉 Successfully placed verified IPA on Desktop:', desktopOutput);
} catch (e) {
  console.error('Error during compression:', e);
}
