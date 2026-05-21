"""
스프라이트 시트 추출 스크립트 (수정판)
이미지: Gemini_Generated_Image_hfsckyhfsckyhfsc (1).png
구조: 8행 x 10열 (좌측 5열 + 우측 5열)
각 행: 구슬(stage1) + 진화 4단계(stage2~5)
"""
from PIL import Image
import numpy as np
import os, sys

# ── 이미지 로드 ──────────────────────────────────────────────────────
img_path = r"C:\Users\91618\WriteMon\assets\images\Gemini_Generated_Image_hfsckyhfsckyhfsc (1).png"

if not os.path.exists(img_path):
    print(f"ERROR: Image not found: {img_path}")
    sys.exit(1)

img = Image.open(img_path).convert("RGBA")
W, H = img.size
arr = np.array(img)
print(f"이미지 크기: {W} x {H}")

# ── 알파 채널로 실제 콘텐츠 범위 파악 ───────────────────────────────
alpha = arr[:, :, 3]

# 세로 방향: 비투명 픽셀이 있는 행 찾기
row_has_content = np.any(alpha > 10, axis=1)
content_rows = np.where(row_has_content)[0]
top_row = content_rows[0] if len(content_rows) > 0 else 0
bot_row = content_rows[-1] if len(content_rows) > 0 else H - 1
print(f"콘텐츠 세로 범위: {top_row} ~ {bot_row} (높이={bot_row-top_row+1})")

# 가로 방향: 비투명 픽셀이 있는 열 찾기
col_has_content = np.any(alpha > 10, axis=0)
content_cols = np.where(col_has_content)[0]
left_col = content_cols[0] if len(content_cols) > 0 else 0
right_col = content_cols[-1] if len(content_cols) > 0 else W - 1
print(f"콘텐츠 가로 범위: {left_col} ~ {right_col} (폭={right_col-left_col+1})")

# ── 그리드 설정 ──────────────────────────────────────────────────────
# 좌측 5열: 구슬(seed) + 진화1~4단계
# 우측 5열: 구슬(seed) + 진화1~4단계
ROWS = 8
COLS = 5          # ← 수정: 6→5 (각 절반 당 5열)

# 이미지 중앙 기준으로 좌/우 분할
HALF_W = W // 2

cell_w = HALF_W // COLS
cell_h = H // ROWS

print(f"그리드: {ROWS}행 x {COLS}열, 셀 크기={cell_w}x{cell_h}, 절반 폭={HALF_W}")

# ── 타입명 ───────────────────────────────────────────────────────────
left_types  = ['fire', 'water', 'lightning', 'metal', 'grass', 'dark', 'rainbow', 'normal']
right_types = ['light', 'cloud', 'ice', 'earth', 'poison', 'chaos', 'fairy', 'wind']

# ── 출력 폴더 ────────────────────────────────────────────────────────
out_dir = r"C:\Users\91618\WriteMon\assets\images\monsters_transparent"
os.makedirs(out_dir, exist_ok=True)

def extract_and_save(img_src, x0, y0, cw, ch, type_name, stage_num, out_dir, size=256):
    """셀을 잘라서 비투명 픽셀 bbox로 크롭 후 256x256 캔버스에 중앙 배치"""
    # 범위 clamp
    x0c = max(0, x0)
    y0c = max(0, y0)
    x1c = min(img_src.width, x0 + cw)
    y1c = min(img_src.height, y0 + ch)
    cell = img_src.crop((x0c, y0c, x1c, y1c))

    # 비투명 픽셀 bbox
    bbox = cell.getbbox()
    if bbox is None:
        print(f"  SKIP {type_name} stage{stage_num}: 완전 투명")
        return False

    # 여백 추가 (비율 기준, 최소 8px 최대 20px)
    pad = max(8, min(20, int(min(bbox[2]-bbox[0], bbox[3]-bbox[1]) * 0.08)))
    bx1 = max(0, bbox[0] - pad)
    by1 = max(0, bbox[1] - pad)
    bx2 = min(cell.width,  bbox[2] + pad)
    by2 = min(cell.height, bbox[3] + pad)
    cropped = cell.crop((bx1, by1, bx2, by2))

    # 256x256 투명 캔버스에 비율 유지하며 중앙 배치
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    cw2, ch2 = cropped.size
    if cw2 <= 0 or ch2 <= 0:
        return False
    scale = min(size / cw2, size / ch2)
    nw = max(1, int(cw2 * scale))
    nh = max(1, int(ch2 * scale))
    resized = cropped.resize((nw, nh), Image.LANCZOS)
    px = (size - nw) // 2
    py = (size - nh) // 2
    canvas.paste(resized, (px, py), resized)

    fname = f"monster_{type_name}_stage{stage_num}.png"
    fpath = os.path.join(out_dir, fname)
    canvas.save(fpath, "PNG")
    return True

# ── 추출 실행 ────────────────────────────────────────────────────────
count = 0
errors = []

print("\n[좌측 처리]")
for row_idx, type_name in enumerate(left_types):
    y0 = row_idx * cell_h
    for col_idx in range(COLS):
        x0 = col_idx * cell_w
        ok = extract_and_save(img, x0, y0, cell_w, cell_h,
                               type_name, col_idx + 1, out_dir)
        if ok:
            count += 1
            print(f"  OK  {type_name}_stage{col_idx+1}")
        else:
            errors.append(f"{type_name}_stage{col_idx+1}")

print("\n[우측 처리]")
for row_idx, type_name in enumerate(right_types):
    y0 = row_idx * cell_h
    for col_idx in range(COLS):
        x0 = HALF_W + col_idx * cell_w
        ok = extract_and_save(img, x0, y0, cell_w, cell_h,
                               type_name, col_idx + 1, out_dir)
        if ok:
            count += 1
            print(f"  OK  {type_name}_stage{col_idx+1}")
        else:
            errors.append(f"{type_name}_stage{col_idx+1}")

print(f"\n완료: {count}개 저장 → {out_dir}")
if errors:
    print(f"건너뜀 ({len(errors)}개): {', '.join(errors)}")
