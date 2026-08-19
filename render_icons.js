const fs = require('fs');
const path = require('path');
const { Client } = require('ssh2');

const baseDir = __dirname;
const appDir = path.join(baseDir, 'TGPanelApp');
const appIconDir = path.join(appDir, 'Assets.xcassets', 'AppIcon.appiconset');

const svgContent = fs.readFileSync(path.join(appDir, 'AppIcon.svg'), 'utf8');

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

const conn = new Client();
conn.on('ready', () => {
  conn.sftp((err, sftp) => {
    if (err) process.exit(1);
    
    // Write SVG to remote /tmp/AppIcon.svg
    const writeStream = sftp.createWriteStream('/tmp/AppIcon.svg');
    writeStream.write(svgContent);
    writeStream.end();
    
    writeStream.on('close', () => {
      // Convert to all PNG sizes
      const cmds = sizes.map(s => `rsvg-convert -w ${s.size} -h ${s.size} /tmp/AppIcon.svg -o /tmp/${s.name}`).join(' && ');
      conn.exec(cmds, (err2, stream) => {
        stream.on('close', () => {
          // Download all PNGs back
          let count = 0;
          sizes.forEach(s => {
            sftp.fastGet(`/tmp/${s.name}`, path.join(appIconDir, s.name), (err3) => {
              count++;
              if (count === sizes.length) {
                console.log('🎉 All high-definition iOS AppIcon PNGs downloaded successfully!');
                conn.end();
                process.exit(0);
              }
            });
          });
        });
      });
    });
  });
}).on('error', err => process.exit(1)).connect({
  host: '207.174.6.36',
  port: 22,
  username: 'root',
  password: 'y8CFtkLHs3RWHN8l7Dzd'
});
