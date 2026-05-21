"""
Extract 90 monster sprites from a 15-type × 6-stage sprite sheet.
Left half: 8 rows (fire, water, lightning, metal, grass, dark, normal, wind)
Right half: 7 rows (light, cloud, storm, ice, earth, poison, chaos)
Each row has 6 columns (stage1..stage6)
"""

import sys
import os
import glob
import zipfile
from pathlib import Path

try:
    from PIL import Image
    print("Pillow already installed.")
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image
    print("Pillow installed successfully.")

import numpy as np

# ── find the sprite sheet ──────────────────────────────────────────────────
# Search multiple locations
SEARCH_PATHS = [
    r"C:\Users\91618\AppData\Roaming\Claude",
    r"C:\Users\91618\Downloads",
    r"C:\Users\91618\Desktop",
    r"C:\Users\91618\WriteMon",
    r"C:\Users\91618",
]

SPRITE_SHEET = None
TARGET_NAME = "Gemini_Generated_Image_h54lp8h54lp8h54l.png"

print(f"\nSearching for sprite sheet: {TARGET_NAME}")
for search_root in SEARCH_PATHS:
    if not os.path.exists(search_root):
        continue
    matches = glob.glob(os.path.join(search_root, "**", f"*{TARGET_NAME}*"), recursive=True)
    if matches:
        SPRITE_SHEET = matches[0]
        print(f"Found: {SPRITE_SHEET}")
        break

if SPRITE_SHEET is None:
    # Try any Gemini image
    for search_root in SEARCH_PATHS:
        if not os.path.exists(search_root):
            continue
        matches = glob.glob(os.path.join(search_root, "**", "*Gemini_Generated*"), recursive=True)
        if matches:
            SPRITE_SHEET = matches[0]
            print(f"Found (fallback): {SPRITE_SHEET}")
            break

if SPRITE_SHEET is None:
    print("ERROR: Could not find the sprite sheet PNG!")
    print("Please place the file in C:\\Users\\91618\\WriteMon\\ and re-run.")
    input("Press Enter to exit...")
    sys.exit(1)

OUT_DIR = r"C:\Users\91618\WriteMon\monster_sprites_90"
ZIP_PATH = r"C:\Users\91618\WriteMon\monster_sprites_90.zip"

os.makedirs(OUT_DIR, exist_ok=True)

# ── monster definitions ────────────────────────────────────────────────────
LEFT_TYPES  = ["fire", "water", "lightning", "metal", "grass", "dark", "normal", "wind"]
RIGHT_TYPES = ["light", "cloud", "storm", "ice", "earth", "poison", "chaos"]
STAGES = 6
CANVAS_SIZE = 256

# ── load image ─────────────────────────────────────────────────────────────
print(f"\nLoading image...")
img = Image.open(SPRITE_SHEET).convert("RGBA")
W, H = img.size
print(f"Image size: {W} x {H} px")

arr = np.array(img)
alpha = arr[:, :, 3]

# ── helper: find non-empty bands ───────────────────────────────────────────
def find_bands(projection, threshold=5):
    in_band = False
    bands = []
    start = 0
    for i, v in enumerate(projection):
        if not in_band and v > threshold:
            in_band = True
            start = i
        elif in_band and v <= threshold:
            in_band = False
            bands.append((start, i))
    if in_band:
        bands.append((start, len(projection)))
    return bands


def merge_close_bands(bands, min_gap=4):
    if not bands:
        return bands
    merged = [list(bands[0])]
    for s, e in bands[1:]:
        if s - merged[-1][1] < min_gap:
            merged[-1][1] = e
        else:
            merged.append([s, e])
    return [tuple(b) for b in merged]


def detect_grid(region_alpha, n_rows, n_cols, label):
    rH, rW = region_alpha.shape

    # --- rows ---
    row_proj = region_alpha.max(axis=1)
    row_bands = merge_close_bands(find_bands(row_proj, threshold=10))
    if len(row_bands) == n_rows:
        row_slices = row_bands
        print(f"  [{label}] Row auto-detect OK: {n_rows} rows")
    else:
        print(f"  [{label}] Row bands={len(row_bands)} (expected {n_rows}), using equal split")
        step = rH / n_rows
        row_slices = [(int(i * step), int((i + 1) * step)) for i in range(n_rows)]

    # --- cols ---
    col_proj = region_alpha.max(axis=0)
    col_bands = merge_close_bands(find_bands(col_proj, threshold=10))
    if len(col_bands) == n_cols:
        col_slices = col_bands
        print(f"  [{label}] Col auto-detect OK: {n_cols} cols")
    else:
        print(f"  [{label}] Col bands={len(col_bands)} (expected {n_cols}), using equal split")
        step = rW / n_cols
        col_slices = [(int(i * step), int((i + 1) * step)) for i in range(n_cols)]

    return row_slices, col_slices


half_w = W // 2
left_alpha  = alpha[:, :half_w]
right_alpha = alpha[:, half_w:]

print("\n── Detecting left half grid ──")
left_row_slices,  left_col_slices  = detect_grid(left_alpha,  len(LEFT_TYPES),  STAGES, "LEFT")
print("\n── Detecting right half grid ──")
right_row_slices, right_col_slices = detect_grid(right_alpha, len(RIGHT_TYPES), STAGES, "RIGHT")


# ── extract & save ─────────────────────────────────────────────────────────
def center_on_canvas(sprite_img, size=CANVAS_SIZE):
    bbox = sprite_img.getbbox()
    if bbox is None:
        return Image.new("RGBA", (size, size), (0, 0, 0, 0))
    cropped = sprite_img.crop(bbox)
    cw, ch = cropped.size
    if cw > size or ch > size:
        scale = min(size / cw, size / ch) * 0.9
        new_w, new_h = max(1, int(cw * scale)), max(1, int(ch * scale))
        cropped = cropped.resize((new_w, new_h), Image.LANCZOS)
        cw, ch = new_w, new_h
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    x = (size - cw) // 2
    y = (size - ch) // 2
    canvas.paste(cropped, (x, y), cropped)
    return canvas


def extract_region(full_img, x_offset, row_slices, col_slices, type_names):
    extracted = []
    for row_i, (r0, r1) in enumerate(row_slices):
        monster_type = type_names[row_i]
        for col_i, (c0, c1) in enumerate(col_slices):
            stage = col_i + 1
            x0 = x_offset + c0
            x1 = x_offset + c1
            sprite = full_img.crop((x0, r0, x1, r1))
            sprite = center_on_canvas(sprite)
            fname = f"monster_{monster_type}_stage{stage}.png"
            fpath = os.path.join(OUT_DIR, fname)
            sprite.save(fpath, "PNG")
            extracted.append((fname, fpath))
    return extracted


print("\n── Extracting sprites ──")
all_files = []
all_files += extract_region(img, 0,      left_row_slices,  left_col_slices,  LEFT_TYPES)
all_files += extract_region(img, half_w, right_row_slices, right_col_slices, RIGHT_TYPES)

print(f"\nTotal sprites extracted: {len(all_files)}")

# ── create ZIP ─────────────────────────────────────────────────────────────
print(f"\nCreating ZIP: {ZIP_PATH}")
with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as zf:
    for fname, fpath in all_files:
        zf.write(fpath, arcname=fname)
print(f"ZIP created with {len(all_files)} files.")

# ── verification ───────────────────────────────────────────────────────────
print("\n── Verification ──")
saved = sorted(os.listdir(OUT_DIR))
print(f"Files in output dir: {len(saved)}")
print("\nSample filenames:")
for f in saved[:10]:
    sz = os.path.getsize(os.path.join(OUT_DIR, f))
    print(f"  {f}  ({sz} bytes)")
if len(saved) > 10:
    print(f"  ... and {len(saved)-10} more")

empty_count = 0
for fname, fpath in all_files:
    test = Image.open(fpath).convert("RGBA")
    if test.getbbox() is None:
        empty_count += 1
        print(f"  WARNING: {fname} appears empty!")

if empty_count == 0:
    print("\nAll sprites have visible content OK")
else:
    print(f"\nWARNING: {empty_count} sprites appear empty!")

print("\nDone! All 90 sprites saved to:")
print(f"  {OUT_DIR}")
print(f"  {ZIP_PATH}")
input("\nPress Enter to close...")
