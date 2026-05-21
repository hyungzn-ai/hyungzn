"""
영작몬 몬스터 스프라이트 분할 스크립트
"""
import sys, os

LOG = r"C:\Users\91618\WriteMon\split_log.txt"

def log(msg):
    print(msg)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

log("=== 스프라이트 분할 시작 ===")
log(f"Python: {sys.version}")

try:
    from PIL import Image
    log("Pillow OK")
except ImportError as e:
    log(f"Pillow 없음: {e}")
    log("pip install Pillow --user 실행 필요")
    sys.exit(1)

INPUT_IMAGE = r"C:\Users\91618\WriteMon\KakaoTalk_20260429_213042191.jpg"
OUTPUT_DIR  = r"C:\Users\91618\WriteMon\assets\images"

if not os.path.exists(INPUT_IMAGE):
    log(f"이미지 없음: {INPUT_IMAGE}")
    sys.exit(1)

os.makedirs(OUTPUT_DIR, exist_ok=True)

LEFT_MONSTERS  = ["fire","water","lightning","metal","grass","dark","rainbow","neutral"]
RIGHT_MONSTERS = ["light","cloud","wind","ice","earth","poison","phantom"]

img = Image.open(INPUT_IMAGE).convert("RGBA")
W, H = img.size
log(f"이미지 크기: {W} x {H}")

half_w = W // 2
STAGES = 5
cell_w_l = half_w // STAGES
cell_h_l = H // len(LEFT_MONSTERS)
cell_w_r = (W - half_w) // STAGES
cell_h_r = H // len(RIGHT_MONSTERS)

log(f"왼쪽 셀: {cell_w_l}x{cell_h_l}, 오른쪽 셀: {cell_w_r}x{cell_h_r}")

count = 0
for row, m in enumerate(LEFT_MONSTERS):
    for stage in range(1, STAGES+1):
        x1 = (stage-1)*cell_w_l
        y1 = row*cell_h_l
        sprite = img.crop((x1, y1, x1+cell_w_l, y1+cell_h_l))
        fname = f"monster_{m}_stage{stage}.png"
        sprite.save(os.path.join(OUTPUT_DIR, fname))
        count += 1

for row, m in enumerate(RIGHT_MONSTERS):
    for stage in range(1, STAGES+1):
        x1 = half_w + (stage-1)*cell_w_r
        y1 = row*cell_h_r
        sprite = img.crop((x1, y1, x1+cell_w_r, y1+cell_h_r))
        fname = f"monster_{m}_stage{stage}.png"
        sprite.save(os.path.join(OUTPUT_DIR, fname))
        count += 1

log(f"완료! 총 {count}개 저장 -> {OUTPUT_DIR}")
