"""앱 아이콘 생성: 잔디 바탕 + 반쪽 구장 라인 + 육각형 포지션 원 (python3 tool/make_icon.py)."""
from PIL import Image, ImageDraw

RES = 'android/app/src/main/res'
SIZES = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
GREEN, DARK = (27, 138, 60), (22, 115, 50)
COLORS = [(214, 69, 69), (47, 111, 214)]


def draw(size, round_mask=False):
    s = 1024
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = s * 0.22
    d.rounded_rectangle([0, 0, s, s], radius=r, fill=GREEN)
    for i in range(0, 6, 2):
        d.rectangle([0, s * i / 6, s, s * (i + 1) / 6], fill=DARK)
    # 다시 둥근 모서리로 자르기
    mask = Image.new('L', (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, s, s], radius=r, fill=255)
    if round_mask:
        mask = Image.new('L', (s, s), 0)
        ImageDraw.Draw(mask).ellipse([0, 0, s, s], fill=255)
    img.putalpha(mask)
    d = ImageDraw.Draw(img)
    w = int(s * 0.03)
    white = (255, 255, 255, 235)
    m = s * 0.16
    d.rectangle([m, m, s - m, s - m], outline=white, width=w)
    d.arc([s / 2 - s * 0.13, m - s * 0.13, s / 2 + s * 0.13, m + s * 0.13], 0, 180, fill=white, width=w)
    d.arc([s / 2 - s * 0.22, s - m - s * 0.2, s / 2 + s * 0.22, s - m + s * 0.2], 180, 360, fill=white, width=w)
    # 육각형 포지션 원 (피보·아라·픽소·GK)
    pts = [(0.5, 0.28), (0.3, 0.42), (0.7, 0.42), (0.3, 0.6), (0.7, 0.6), (0.5, 0.74)]
    cr = s * 0.075
    for i, (x, y) in enumerate(pts):
        cx, cy = x * s, y * s
        color = COLORS[0] if i in (0, 1, 3) else COLORS[1]
        d.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=(255, 255, 255), outline=color, width=int(s * 0.025))
    return img.resize((size, size), Image.LANCZOS)


for name, px in SIZES.items():
    draw(px).save(f'{RES}/mipmap-{name}/ic_launcher.png')
draw(512).save('docs/icon.png')
print('ok')
