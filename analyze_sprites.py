from PIL import Image
import numpy as np
import sys

img_path = r"C:\Users\91618\AppData\Roaming\Claude\local-agent-mode-sessions\3d7d6dbd-f02a-4e40-ae0b-77818710ded7\0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\agent\local_ditto_0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\uploads\e8d18a96-Monster___.png"
out_path = r"C:\Users\91618\WriteMon\sprite_analysis.txt"

log = []
def p(s=""):
    log.append(str(s))
    print(s)

img = Image.open(img_path).convert("RGBA")
w, h = img.size
p(f"Image size: {w} x {h}")

arr = np.array(img)

# Find monster rows by scanning horizontal bands
# Use alpha channel or lightness to detect content
row_activity = []
for y in range(h):
    row = arr[y]
    # Count pixels that are not white/near-white
    non_white = np.sum(~((row[:,0] > 230) & (row[:,1] > 230) & (row[:,2] > 230)))
    row_activity.append(non_white)

# Find content regions (rows with monsters)
threshold = 5
in_content = False
row_regions = []
start_y = 0
for y, activity in enumerate(row_activity):
    if activity > threshold and not in_content:
        in_content = True
        start_y = y
    elif activity <= threshold and in_content:
        in_content = False
        row_regions.append((start_y, y))

if in_content:
    row_regions.append((start_y, h))

p(f"\nFound {len(row_regions)} monster rows:")
for i, (sy, ey) in enumerate(row_regions):
    p(f"  Row {i+1}: y={sy}..{ey} (h={ey-sy})")

# For each row, detect sprite columns (left half and right half)
p("\n--- Sprite detection per row ---")
all_sprite_info = []
for row_idx, (sy, ey) in enumerate(row_regions):
    row_arr = arr[sy:ey]
    row_height = ey - sy

    # Check each half separately
    for half in range(2):
        x_start = half * (w // 2)
        x_end = (half + 1) * (w // 2)
        half_arr = row_arr[:, x_start:x_end]
        half_w = x_end - x_start

        col_activity = []
        for x in range(half_w):
            col = half_arr[:, x]
            non_white = np.sum(~((col[:,0] > 230) & (col[:,1] > 230) & (col[:,2] > 230)))
            col_activity.append(non_white)

        in_sprite = False
        sprite_groups = []
        sx = 0
        for x, activity in enumerate(col_activity):
            if activity > 2 and not in_sprite:
                in_sprite = True
                sx = x
            elif activity <= 2 and in_sprite:
                in_sprite = False
                sprite_groups.append((sx + x_start, x + x_start))
        if in_sprite:
            sprite_groups.append((sx + x_start, x_end))

        # Filter out very small groups (arrows, labels)
        sprites = [(s, e) for s, e in sprite_groups if (e - s) > 15]

        if sprites:
            p(f"  Row {row_idx+1}, {'LEFT' if half==0 else 'RIGHT'} half: {len(sprites)} sprites -> {sprites}")
            all_sprite_info.append({
                'row': row_idx,
                'half': half,
                'y': (sy, ey),
                'sprites': sprites
            })

# Write to file
with open(out_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(log))

p(f"\nSaved to {out_path}")
