"""
sprites_coordinates.dart 보정용
실제 이미지에서 각 스프라이트 셀의 x, y, w, h를 계산합니다.
"""
import struct, zlib, sys, os

IMG = r"C:\Users\91618\WriteMon\assets\images\monsters_sprite.png"

def read_png_size(path):
    with open(path, 'rb') as f:
        sig = f.read(8)
        if sig != b'\x89PNG\r\n\x1a\n':
            print("PNG 파일이 아닙니다.")
            return None, None
        f.read(4)  # chunk length
        chunk_type = f.read(4)
        if chunk_type != b'IHDR':
            print("IHDR 없음")
            return None, None
        w = struct.unpack('>I', f.read(4))[0]
        h = struct.unpack('>I', f.read(4))[0]
    return w, h

w, h = read_png_size(IMG)
if w is None:
    print("이미지를 읽을 수 없습니다:", IMG)
    sys.exit(1)

print(f"=== 이미지 실제 크기: {w} x {h} ===\n")

# 현재 설정값
col_count = 2
rows_left = 8
rows_right = 9

col_w = w / col_count
row_h_left  = h / rows_left
row_h_right = h / rows_right

print(f"열 너비: {col_w:.1f}px")
print(f"왼쪽 열 행 높이: {row_h_left:.1f}px  ({rows_left}행)")
print(f"오른쪽 열 행 높이: {row_h_right:.1f}px  ({rows_right}행)")
print()

# --- 레이블 너비 추정 (육안으로 확인 필요) ---
# 기본값: 이미지 너비의 약 12%
label_w = col_w * 0.12
stages = 6
sprite_w = (col_w - label_w) / stages
print(f"추정 레이블 너비: {label_w:.1f}px")
print(f"추정 스프라이트 셀 너비: {sprite_w:.1f}px")
print()

print("=== 각 셀 좌표 예시 (불/flameling, stage 0~5) ===")
for s in range(stages):
    x = 0 * col_w + label_w + s * sprite_w
    y = 0 * row_h_left
    print(f"  stage {s}: x={x:.1f}, y={y:.1f}, w={sprite_w:.1f}, h={row_h_left:.1f}")

out = r"C:\Users\91618\WriteMon\sprite_info.txt"
with open(out, 'w', encoding='utf-8') as f:
    f.write(f"이미지 크기: {w} x {h}\n")
    f.write(f"왼쪽 행 높이: {row_h_left:.2f}\n")
    f.write(f"오른쪽 행 높이: {row_h_right:.2f}\n")
    f.write(f"열 너비: {col_w:.2f}\n")
    f.write(f"추정 레이블 너비: {label_w:.2f}\n")
    f.write(f"추정 셀 너비: {sprite_w:.2f}\n")

print(f"\n결과 저장: {out}")
