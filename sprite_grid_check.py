"""
sprites_sprite.png의 실제 크기를 읽고
격자선을 그려서 스프라이트 셀 경계를 시각으로 확인합니다.
결과: sprite_grid_debug.png
"""
import struct, sys

IMG_IN  = r"C:\Users\91618\WriteMon\assets\images\monsters_sprite.png"
IMG_OUT = r"C:\Users\91618\WriteMon\sprite_grid_debug.png"

# ── PNG 크기 읽기 (표준 라이브러리만 사용) ─────────────────────
def read_png_size(path):
    with open(path, 'rb') as f:
        if f.read(8) != b'\x89PNG\r\n\x1a\n':
            raise ValueError("PNG가 아님")
        f.read(4)           # IHDR 길이
        assert f.read(4) == b'IHDR'
        w = struct.unpack('>I', f.read(4))[0]
        h = struct.unpack('>I', f.read(4))[0]
    return w, h

try:
    W, H = read_png_size(IMG_IN)
except FileNotFoundError:
    print(f"파일을 찾을 수 없습니다: {IMG_IN}")
    print("monsters_sprite.png 를 assets/images/ 에 먼저 복사하세요.")
    input("Enter 종료")
    sys.exit(1)

print(f"이미지 크기: {W} x {H}")

# ── 현재 가정값으로 셀 계산 ────────────────────────────────────
COLS       = 2
ROWS_LEFT  = 8
ROWS_RIGHT = 9
LABEL_W    = 40      # ← 실제 레이블 너비가 다르면 여기를 수정
STAGES     = 6

col_w       = W / COLS
row_h_l     = H / ROWS_LEFT
row_h_r     = H / ROWS_RIGHT
cell_w      = (col_w - LABEL_W) / STAGES

print(f"열 너비       : {col_w:.1f}")
print(f"행 높이(왼쪽) : {row_h_l:.1f}")
print(f"행 높이(오른쪽): {row_h_r:.1f}")
print(f"레이블 너비   : {LABEL_W}")
print(f"셀 너비(1단계): {cell_w:.1f}")

# ── PIL 없이 PNG에 격자선 그리기 ──────────────────────────────
# raw RGBA 픽셀을 읽어서 선을 그리고 다시 PNG로 저장
import zlib

def read_png_pixels(path):
    """PNG → (W, H, pixels:bytearray RGBA)"""
    with open(path, 'rb') as f:
        raw = f.read()
    assert raw[:8] == b'\x89PNG\r\n\x1a\n'
    pos = 8
    idat_chunks = []
    ihdr = None
    while pos < len(raw):
        length = struct.unpack('>I', raw[pos:pos+4])[0]
        ctype  = raw[pos+4:pos+8]
        data   = raw[pos+8:pos+8+length]
        pos   += 12 + length
        if ctype == b'IHDR':
            ihdr = data
        elif ctype == b'IDAT':
            idat_chunks.append(data)
        elif ctype == b'IEND':
            break
    w, h, bit_depth, color_type = struct.unpack('>IIBB', ihdr[:10])
    # 지원: 8-bit RGBA(6) 또는 RGB(2)
    compressed = b''.join(idat_chunks)
    raw_data   = zlib.decompress(compressed)
    bpp = 4 if color_type == 6 else 3
    stride = 1 + w * bpp  # filter byte + row bytes
    pixels = bytearray(w * h * 4)  # RGBA 출력
    idx = 0
    prev_row = bytearray(w * bpp)
    for y in range(h):
        f_byte = raw_data[y * stride]
        row_raw = bytearray(raw_data[y*stride+1:(y+1)*stride])
        # paeth / sub / up / average
        for x in range(w * bpp):
            a = row_raw[x - bpp] if x >= bpp else 0
            b = prev_row[x]
            c = prev_row[x - bpp] if x >= bpp else 0
            if f_byte == 0:   recon = row_raw[x]
            elif f_byte == 1: recon = (row_raw[x] + a) & 0xFF
            elif f_byte == 2: recon = (row_raw[x] + b) & 0xFF
            elif f_byte == 3: recon = (row_raw[x] + (a+b)//2) & 0xFF
            else:             # paeth
                pa = abs(b-c); pb = abs(a-c); pc = abs(a+b-2*c)
                pr = a if pa<=pb and pa<=pc else (b if pb<=pc else c)
                recon = (row_raw[x] + pr) & 0xFF
            row_raw[x] = recon
        prev_row = row_raw
        for x in range(w):
            r = row_raw[x*bpp]; g = row_raw[x*bpp+1]; b_ = row_raw[x*bpp+2]
            a_ = row_raw[x*bpp+3] if bpp==4 else 255
            pixels[idx:idx+4] = [r,g,b_,a_]
            idx += 4
    return w, h, pixels

def set_pixel(pixels, W, x, y, r, g, b_):
    if 0 <= x < W and 0 <= y < len(pixels)//(W*4):
        i = (y*W+x)*4
        pixels[i:i+3] = [r,g,b_]

def draw_vline(pixels, W, H, x, r, g, b_):
    xi = int(x)
    for y in range(H):
        set_pixel(pixels, W, xi, y, r, g, b_)

def draw_hline(pixels, W, H, y, r, g, b_):
    yi = int(y)
    for x in range(W):
        set_pixel(pixels, W, x, yi, r, g, b_)

def write_png(path, W, H, pixels):
    def chunk(ctype, data):
        c = ctype + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xFFFFFFFF)
    ihdr_data = struct.pack('>IIBBBBBB', W, H, 8, 6, 0, 0, 0)
    rows = []
    for y in range(H):
        row = b'\x00' + bytes(pixels[y*W*4:(y+1)*W*4])
        rows.append(row)
    compressed = zlib.compress(b''.join(rows), 9)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', ihdr_data))
        f.write(chunk(b'IDAT', compressed))
        f.write(chunk(b'IEND', b''))

print("\n픽셀 읽는 중 (시간이 걸릴 수 있어요)...")
W2, H2, pixels = read_png_pixels(IMG_IN)

# 수직선: 열 경계, 레이블 경계, 셀 경계
print("격자선 그리는 중...")
# 열 중간 경계 (빨강)
draw_vline(pixels, W2, H2, col_w, 255, 0, 0)
# 레이블 경계 (초록)
draw_vline(pixels, W2, H2, LABEL_W, 0, 255, 0)
draw_vline(pixels, W2, H2, col_w + LABEL_W, 0, 255, 0)
# 셀 경계 (파랑)
for s in range(1, STAGES):
    draw_vline(pixels, W2, H2, LABEL_W + s*cell_w, 0, 150, 255)
    draw_vline(pixels, W2, H2, col_w + LABEL_W + s*cell_w, 0, 150, 255)

# 수평선: 왼쪽(노랑), 오른쪽(흰색)
for row in range(1, ROWS_LEFT):
    draw_hline(pixels, W2, H2, row*row_h_l, 255, 255, 0)
for row in range(1, ROWS_RIGHT):
    draw_hline(pixels, W2, H2, row*row_h_r, 200, 200, 200)

write_png(IMG_OUT, W2, H2, pixels)
print(f"\n완료! 결과 이미지: {IMG_OUT}")
print("이미지를 열어서 격자선이 각 스프라이트에 맞게 그려져 있는지 확인하세요.")
print(f"\n=== dart 코드에 넣을 값 ===")
print(f"static const double imageWidth  = {W2};")
print(f"static const double imageHeight = {H2};")
print(f"static const int    totalRowsRight = {ROWS_RIGHT};")
print(f"static const double rowHeight = imageHeight / totalRowsRight; // {row_h_r:.1f}px")
print(f"static const double colWidth = imageWidth / 2; // {col_w:.1f}px")
print(f"static const double labelWidth = {LABEL_W};")
print(f"static const double cellWidth = (colWidth - labelWidth) / stagesCount; // {cell_w:.1f}px")
input("\nEnter 종료")
