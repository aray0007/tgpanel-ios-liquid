const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const baseDir = __dirname;
const appDir = path.join(baseDir, 'TGPanelApp');
const appIconDir = path.join(appDir, 'Assets.xcassets', 'AppIcon.appiconset');

if (!fs.existsSync(appIconDir)) fs.mkdirSync(appIconDir, { recursive: true });

function createLiquidGlassPNG(width, height) {
  // Generate RGBA buffer
  const buffer = Buffer.alloc(width * height * 4);
  const cx = width / 2;
  const cy = height / 2;
  const rMax = width * 0.46;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const idx = (y * width + x) * 4;
      const nx = x / width;
      const ny = y / height;

      // Base Obsidian Mesh
      let r = 8 + 12 * nx;
      let g = 12 + 18 * ny;
      let b = 24 + 40 * (1 - ny);

      // Liquid Orb 1 (Cyan Neon at top-left)
      const d1 = Math.hypot(x - width * 0.3, y - height * 0.3) / width;
      if (d1 < 0.6) {
        const factor = Math.cos(d1 * Math.PI / 0.6);
        r += 0 * factor;
        g += 210 * factor;
        b += 255 * factor;
      }

      // Liquid Orb 2 (Purple / Magenta at center-right)
      const d2 = Math.hypot(x - width * 0.75, y - height * 0.45) / width;
      if (d2 < 0.65) {
        const factor = Math.cos(d2 * Math.PI / 0.65);
        r += 121 * factor;
        g += 40 * factor;
        b += 202 * factor;
      }

      // Liquid Orb 3 (Hot Pink at bottom)
      const d3 = Math.hypot(x - width * 0.5, y - height * 0.8) / width;
      if (d3 < 0.6) {
        const factor = Math.cos(d3 * Math.PI / 0.6);
        r += 255 * factor;
        g += 0 * factor;
        b += 128 * factor;
      }

      // Glass Center Hologram (Telegram Crystal Plane Shape)
      // Check if within plane polygon
      const px = (x - cx) / (width * 0.4);
      const py = (y - cy) / (height * 0.4);
      
      // Simple glass wing glow
      if (px > -0.6 && px < 0.6 && py > -0.5 && py < 0.5) {
        const wingDist = Math.abs(px * 0.8 - py);
        if (wingDist < 0.25) {
          r = Math.min(255, r * 1.5 + 100);
          g = Math.min(255, g * 1.6 + 120);
          b = Math.min(255, b * 1.8 + 150);
        }
      }

      // Glass Specular Sheen (Top-left diagonal highlight)
      const diag = (nx + ny);
      if (diag > 0.3 && diag < 0.65) {
        const sheen = Math.sin((diag - 0.3) / 0.35 * Math.PI) * 45;
        r = Math.min(255, r + sheen);
        g = Math.min(255, g + sheen);
        b = Math.min(255, b + sheen * 1.2);
      }

      buffer[idx] = Math.min(255, Math.floor(r));
      buffer[idx + 1] = Math.min(255, Math.floor(g));
      buffer[idx + 2] = Math.min(255, Math.floor(b));
      buffer[idx + 3] = 255;
    }
  }

  // Encode uncompressed RGBA to standard PNG format
  return encodePNG(width, height, buffer);
}

function encodePNG(width, height, rgbaBuffer) {
  // PNG signature
  const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

  // IHDR chunk
  const ihdrData = Buffer.alloc(13);
  ihdrData.writeUInt32BE(width, 0);
  ihdrData.writeUInt32BE(height, 4);
  ihdrData[8] = 8; // bit depth
  ihdrData[9] = 6; // color type: RGBA
  ihdrData[10] = 0; // compression
  ihdrData[11] = 0; // filter
  ihdrData[12] = 0; // interlace
  const ihdrChunk = createChunk('IHDR', ihdrData);

  // Raw Scanlines (Filter type 0 + RGBA)
  const scanlines = Buffer.alloc(height * (1 + width * 4));
  for (let y = 0; y < height; y++) {
    const rowOffset = y * (1 + width * 4);
    scanlines[rowOffset] = 0; // None filter
    rgbaBuffer.copy(scanlines, rowOffset + 1, y * width * 4, (y + 1) * width * 4);
  }

  // Deflate IDAT
  const compressedData = zlib.deflateSync(scanlines, { level: 9 });
  const idatChunk = createChunk('IDAT', compressedData);

  // IEND chunk
  const iendChunk = createChunk('IEND', Buffer.alloc(0));

  return Buffer.concat([signature, ihdrChunk, idatChunk, iendChunk]);
}

function createChunk(type, data) {
  const len = data.length;
  const chunk = Buffer.alloc(8 + len + 4);
  chunk.writeUInt32BE(len, 0);
  chunk.write(type, 4);
  data.copy(chunk, 8);

  const crcTable = getCRCTable();
  let crc = 0xffffffff;
  for (let i = 4; i < 8 + len; i++) {
    crc = (crc >>> 8) ^ crcTable[(crc ^ chunk[i]) & 0xff];
  }
  crc = (crc ^ 0xffffffff) >>> 0;
  chunk.writeUInt32BE(crc, 8 + len);
  return chunk;
}

let crcTableCache = null;
function getCRCTable() {
  if (crcTableCache) return crcTableCache;
  const cTable = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) {
      c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
    }
    cTable[n] = c >>> 0;
  }
  crcTableCache = cTable;
  return cTable;
}

// Generate all standard iOS AppIcon sizes
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

sizes.forEach(s => {
  const png = createLiquidGlassPNG(s.size, s.size);
  fs.writeFileSync(path.join(appIconDir, s.name), png);
  console.log(`  + Created Liquid Crystal PNG: ${s.name} (${s.size}x${s.size})`);
});

console.log('🎉 100% complete pure iOS AppIcon suite generated!');
