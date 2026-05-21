import os
import shutil
import struct

uploads_dir = r"C:\Users\91618\AppData\Roaming\Claude\local-agent-mode-sessions\3d7d6dbd-f02a-4e40-ae0b-77818710ded7\0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\agent\local_ditto_0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\uploads"
dst = r"C:\Users\91618\WriteMon\assets\images\monsters_sprite.png"

result_file = open(r"C:\Users\91618\WriteMon\sprite_copy_result.txt", "w", encoding="utf-8")

try:
    # List files with bytes to handle any encoding
    raw_entries = os.listdir(uploads_dir)
    result_file.write(f"Found {len(raw_entries)} files:\n")

    png_src = None
    for entry in raw_entries:
        result_file.write(f"  {entry!r}\n")
        if entry.lower().endswith('.png') or 'monster' in entry.lower() or 'Monster' in entry:
            full = os.path.join(uploads_dir, entry)
            png_src = full
            result_file.write(f"  --> SELECTED: {full}\n")

    if png_src:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(png_src, dst)
        # Read dimensions
        with open(dst, 'rb') as f:
            f.read(12)  # 8 sig + 4 length
            f.read(4)   # IHDR
            w = struct.unpack('>I', f.read(4))[0]
            h = struct.unpack('>I', f.read(4))[0]
        result_file.write(f"\nCopied OK! Size: {w} x {h}\n")
        print(f"Copied! Image: {w} x {h}")
    else:
        result_file.write("No PNG found!\n")
        print("No PNG found")

except Exception as e:
    result_file.write(f"Error: {e}\n")
    import traceback
    result_file.write(traceback.format_exc())
    print(f"Error: {e}")

result_file.close()
print("Done - check sprite_copy_result.txt")
