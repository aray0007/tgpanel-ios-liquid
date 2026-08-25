from pathlib import Path
import struct
import zlib

OUT = Path(__file__).resolve().parents[1] / "Assets.xcassets" / "AppIcon.appiconset"
OUT.mkdir(parents=True, exist_ok=True)


def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


def write_png(path, size):
    background = bytes((5, 9, 11, 255))
    bars = (
        (round(size * 0.285), round(size * 0.355), round(size * 0.39), round(size * 0.68), bytes((47, 135, 124, 255))),
        (round(size * 0.405), round(size * 0.475), round(size * 0.25), round(size * 0.72), bytes((75, 218, 199, 255))),
        (round(size * 0.525), round(size * 0.595), round(size * 0.33), round(size * 0.68), bytes((58, 170, 157, 255))),
    )
    rows = bytearray()
    for y in range(size):
        row = bytearray(background * size)
        for left, right, top, bottom, color in bars:
            if top <= y <= bottom:
                for x in range(left, right + 1):
                    start = x * 4
                    row[start:start + 4] = color
        rows.append(0)
        rows.extend(row)
    raw = b"\x89PNG\r\n\x1a\n"
    raw += chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
    raw += chunk(b"IDAT", zlib.compress(bytes(rows), 6))
    raw += chunk(b"IEND", b"")
    path.write_bytes(raw)


for filename, size in {
    "AppIcon-60@2x.png": 120,
    "AppIcon-60@3x.png": 180,
    "AppIcon-76.png": 76,
    "AppIcon-76@2x.png": 152,
    "AppIcon-83.5@2x.png": 167,
    "AppIcon-1024.png": 1024,
}.items():
    write_png(OUT / filename, size)
