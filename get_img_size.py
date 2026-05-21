import struct
import glob
import os

out = open(r"C:\Users\91618\WriteMon\img_size.txt", "w", encoding="utf-8")

try:
    uploads_dir = r"C:\Users\91618\AppData\Roaming\Claude\local-agent-mode-sessions\3d7d6dbd-f02a-4e40-ae0b-77818710ded7\0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\agent\local_ditto_0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\uploads"

    all_files = os.listdir(uploads_dir)
    out.write(f"All files in uploads ({len(all_files)}):\n")
    for f in all_files:
        out.write(f"  {repr(f)}\n")

except Exception as e:
    out.write(f"Error: {e}\n")
    print(f"Error: {e}")

out.close()
print("Done - check img_size.txt")
