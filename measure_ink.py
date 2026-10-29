"""定位越界的行，并裁一张右侧放大图供肉眼确认。"""

import sys

import numpy as np
from PIL import Image

path = sys.argv[1]
crop_out = sys.argv[2]

im = Image.open(path)
gray = im.convert("L")
w, h = gray.size
a = np.array(gray)
ink = a < 128

exp_left = w * 3.17 / 21
exp_right = w * (21 - 3.17) / 21
print(f"image {w}x{h}  text area {exp_left:.0f}..{exp_right:.0f}")

bad = []
for y in range(h):
    row = np.where(ink[y])[0]
    if row.size and row.max() > exp_right:
        bad.append((y, int(row.max())))

groups = []
for y, mx in bad:
    if groups and y - groups[-1][1] <= 3:
        groups[-1][1] = y
        groups[-1][2] = max(groups[-1][2], mx)
    else:
        groups.append([y, y, mx])

print(f"越界行分组数: {len(groups)}")
for g in groups[:14]:
    print(f"  y {g[0]:>4}..{g[1]:<4}  max_x={g[2]}  (越界 {g[2]-exp_right:.0f}px)")

im.crop((690, 150, w, 760)).save(crop_out)
print(f"crop saved: {crop_out}")
