"""
sprite_fix.py
monsters_sprite_trans.png 스프라이트 시트에서 개별 스프라이트를 추출합니다.

실행 후 sprite_preview.png 를 열어서 각 행이 어떤 몬스터인지 확인하세요.
"""
from PIL import Image
import os

SHEET  = r'C:\Users\91618\WriteMon\assets\images\monsters_sprite_trans.png'
OUTDIR = r'C:\Users\91618\WriteMon\assets\images\monsters_transparent'
PREVIEW = r'C:\Users\91618\WriteMon\sprite_preview.png'

# ── 스프라이트 시트 로드 ─────────────────────────────────────
img = Image.open(SHEET).convert('RGBA')
W, H = img.size
print(f"스프라이트 시트 크기: {W} x {H}")

# ── 그리드 설정 ──────────────────────────────────────────────
# 시트는 좌/우 2개 절반으로 구성, 각 절반에 8행 × 6열
HALF_W = W // 2
ROWS   = 8
COLS   = 6
CW = HALF_W / COLS   # 셀 너비 ≈ 95.5
CH = H      / ROWS   # 셀 높이 ≈ 160.25
print(f"셀 크기: {CW:.1f} x {CH:.1f}  |  절반 너비: {HALF_W}")

# ── 몬스터 타입 행 순서 (추정 — 아래에서 시각적으로 확인 필요) ──
LEFT_TYPES  = ['fire', 'water', 'lightning', 'metal', 'grass', 'dark', 'normal', 'wind']
RIGHT_TYPES = ['light', 'cloud', 'ice', 'earth', 'poison', 'chaos', 'rainbow', 'shadow']

# ── 헬퍼 함수 ────────────────────────────────────────────────
def get_cell(half_x: int, row: int, col: int) -> Image.Image:
    x1 = int(half_x + col * CW)
    y1 = int(row * CH)
    x2 = min(int(half_x + (col + 1) * CW), img.width)
    y2 = min(int((row  + 1) * CH),          img.height)
    return img.crop((x1, y1, x2, y2))

def crop_sprite(cell: Image.Image, pad: int = 6) -> Image.Image | None:
    _, _, _, alpha = cell.split()
    bbox = alpha.getbbox()
    if not bbox:
        return None
    l = max(0,           bbox[0] - pad)
    t = max(0,           bbox[1] - pad)
    r = min(cell.width,  bbox[2] + pad)
    b = min(cell.height, bbox[3] + pad)
    return cell.crop((l, t, r, b))

def to_square(sprite: Image.Image | None, out_size: int = 128) -> Image.Image:
    if sprite is None:
        return Image.new('RGBA', (out_size, out_size), (0, 0, 0, 0))
    sw, sh  = sprite.size
    sq      = max(sw, sh)
    canvas  = Image.new('RGBA', (sq, sq), (0, 0, 0, 0))
    canvas.paste(sprite, ((sq - sw) // 2, (sq - sh) // 2))
    return canvas.resize((out_size, out_size), Image.NEAREST)

# ── 1. 미리보기 이미지 생성 ───────────────────────────────────
THUMB = 80   # 미리보기 썸네일 크기
PREVIEW_W = (COLS * 2 + 1) * THUMB   # 좌+구분선+우
PREVIEW_H = ROWS * THUMB
preview = Image.new('RGBA', (PREVIEW_W, PREVIEW_H), (30, 30, 50, 255))

for row in range(ROWS):
    for col in range(COLS):
        for h_idx, half_x in enumerate([0, HALF_W]):
            cell   = get_cell(half_x, row, col)
            sprite = crop_sprite(cell)
            thumb  = to_square(sprite, THUMB)
            # 배경색 추가 (어두운 배경에서 투명 스프라이트 확인용)
            bg     = Image.new('RGBA', (THUMB, THUMB), (50, 50, 80, 255))
            bg.paste(thumb, (0, 0), thumb)
            px = (h_idx * (COLS + 1) + col) * THUMB
            py = row * THUMB
            preview.paste(bg, (px, py))

preview.save(PREVIEW)
print(f"\n미리보기 저장됨: {PREVIEW}")
print("Paint에서 열어서 각 행이 어떤 몬스터인지 확인하세요!")
print(f"  왼쪽 {COLS}열 = 왼쪽 절반, 오른쪽 {COLS}열 = 오른쪽 절반")

# ── 2. 각 행의 평균 색상 출력 (타입 구분 힌트) ───────────────
print("\n행별 대표 색상 (타입 구분 참고):")
for h_idx, (half_x, types) in enumerate([(0, LEFT_TYPES), (HALF_W, RIGHT_TYPES)]):
    print(f"\n  {'왼쪽' if h_idx == 0 else '오른쪽'} 절반:")
    for row, tname in enumerate(types):
        colors = []
        for col in range(COLS):
            cell   = get_cell(half_x, row, col)
            sprite = crop_sprite(cell, 0)
            if sprite:
                pixels  = list(sprite.getdata())
                visible = [(r, g, b) for r, g, b, a in pixels if a > 128]
                if visible:
                    n = len(visible)
                    avg = (sum(c[0] for c in visible)//n,
                           sum(c[1] for c in visible)//n,
                           sum(c[2] for c in visible)//n)
                    colors.append(f"#{avg[0]:02x}{avg[1]:02x}{avg[2]:02x}")
        print(f"    행{row} ({tname:12s}): {' '.join(colors) if colors else '[비어있음]'}")

# ── 3. 개별 스프라이트 추출 및 저장 ──────────────────────────
print("\n개별 스프라이트 추출 중...")
os.makedirs(OUTDIR, exist_ok=True)

all_types = (
    [(t, 0,      i) for i, t in enumerate(LEFT_TYPES)] +
    [(t, HALF_W, i) for i, t in enumerate(RIGHT_TYPES)]
)

saved = 0
for type_name, half_x, row_idx in all_types:
    for col in range(COLS):
        stage  = col + 1
        cell   = get_cell(half_x, row_idx, col)
        sprite = crop_sprite(cell)
        out    = to_square(sprite, 128)
        path   = os.path.join(OUTDIR, f'monster_{type_name}_stage{stage}.png')
        out.save(path, 'PNG')
        if sprite:
            saved += 1
            print(f"  OK: monster_{type_name}_stage{stage}.png")
        else:
            print(f"  빈칸: monster_{type_name}_stage{stage}.png (스프라이트 없음)")

print(f"\n완료! {saved}개 스프라이트 저장됨.")
print(f"출력 폴더: {OUTDIR}")
print("\n다음 단계: build_release.bat 를 실행해서 APK를 다시 빌드하세요.")
