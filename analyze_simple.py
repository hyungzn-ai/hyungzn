import sys
import os

out = open(r"C:\Users\91618\WriteMon\sprite_result.txt", "w", encoding="utf-8")

def p(s=""):
    out.write(str(s) + "\n")
    print(s)

p("Python version: " + sys.version)
p("Working...")

try:
    from PIL import Image
    p("PIL available")

    img_path = r"C:\Users\91618\AppData\Roaming\Claude\local-agent-mode-sessions\3d7d6dbd-f02a-4e40-ae0b-77818710ded7\0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\agent\local_ditto_0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\uploads\e8d18a96-Monster___.png"
    img = Image.open(img_path).convert("RGBA")
    w, h = img.size
    p(f"Image: {w} x {h}")

    # Scan each row for content (without numpy - use getpixel)
    # Sample every 4 pixels for speed
    row_has_content = []
    for y in range(h):
        found = False
        for x in range(0, w, 4):
            r, g, b, a = img.getpixel((x, y))
            if not (r > 230 and g > 230 and b > 230):
                found = True
                break
        row_has_content.append(found)

    # Find row regions
    in_content = False
    regions = []
    sy = 0
    for y, has in enumerate(row_has_content):
        if has and not in_content:
            in_content = True
            sy = y
        elif not has and in_content:
            in_content = False
            regions.append((sy, y))
    if in_content:
        regions.append((sy, h))

    p(f"Monster rows: {len(regions)}")
    for i, (a, b) in enumerate(regions):
        p(f"  Row {i+1}: y={a}..{b} (h={b-a})")

    # For row 0, detect sprite columns in left half
    if regions:
        sy, ey = regions[0]
        col_activity = []
        half_w = w // 2
        for x in range(half_w):
            found = False
            for y in range(sy, ey, 2):
                r, g, b, a = img.getpixel((x, y))
                if not (r > 230 and g > 230 and b > 230):
                    found = True
                    break
            col_activity.append(found)

        in_sprite = False
        sprites = []
        sx = 0
        for x, has in enumerate(col_activity):
            if has and not in_sprite:
                in_sprite = True
                sx = x
            elif not has and in_sprite:
                in_sprite = False
                if x - sx > 10:
                    sprites.append((sx, x))

        p(f"\nRow 1 sprites (left half): {len(sprites)}")
        for i, (a, b) in enumerate(sprites):
            p(f"  Sprite {i+1}: x={a}..{b} (w={b-a})")

except ImportError as e:
    p(f"PIL not available: {e}")
    p("Trying basic image info...")

    # Just report file size
    img_path = r"C:\Users\91618\AppData\Roaming\Claude\local-agent-mode-sessions\3d7d6dbd-f02a-4e40-ae0b-77818710ded7\0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\agent\local_ditto_0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\uploads\e8d18a96-Monster___.png"
    size = os.path.getsize(img_path)
    p(f"File size: {size} bytes")

except Exception as e:
    p(f"Error: {e}")

out.close()
p("Done! Saved to sprite_result.txt")
