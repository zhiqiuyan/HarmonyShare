#!/usr/bin/env python3
"""生成「鸿蒙分享」应用内图标资源（复现脚本）。

设计对齐 HarmonyOS 分层图标规范与桌面图标：
  - 品牌蓝 #0A59F7（官方「系统高亮色」）
  - 白色三点分享符号 + 双弧线（一源两目标 / 多设备互联）
  - 应用内 logo 为透明底 + 蓝圆盘，便于首页旋转动效不露方角
  - 系统图标 (.ico / web) 为不透明方形蓝底

官方出处见 app/lib/util/ui/harmony_tokens.dart。
运行：python3 scripts/generate_app_icons.py   （在本仓库根目录）
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
IMG = ROOT / "app/assets/img"
BLUE = (10, 89, 247, 255)
S = 1024
SS = 4
W = S * SS


def sc(v):
    return round(v * SS)


def bezier(p0, p1, p2, steps=60):
    pts = []
    for i in range(steps + 1):
        t = i / steps
        pts.append((
            (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0],
            (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1],
        ))
    return pts


def foreground():
    """白色分享符号（透明底），与桌面分层图标 foreground.png 同一构图。"""
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    white = (255, 255, 255, 255)
    soft = (255, 255, 255, 150)

    cx, cy, rr = sc(512), sc(512), sc(352)
    for a0, a1 in [(-62, 62), (118, 242)]:
        pts = []
        for deg in range(a0, a1 + 1):
            rad = math.radians(deg)
            pts.append((cx + rr * math.cos(rad), cy + rr * math.sin(rad)))
        d.line(pts, fill=soft, width=sc(16), joint="curve")

    top = (sc(512), sc(330))
    bl = (sc(322), sc(624))
    br = (sc(702), sc(624))
    r_top, r_low = sc(58), sc(50)
    lw = sc(30)

    d.line(bezier(top, (sc(360), sc(420)), bl), fill=white, width=lw, joint="curve")
    d.line(bezier(top, (sc(664), sc(420)), br), fill=white, width=lw, joint="curve")
    for p in (top, bl, br):
        d.ellipse([p[0] - lw // 2, p[1] - lw // 2,
                   p[0] + lw // 2, p[1] + lw // 2], fill=white)
    for p, r in ((top, r_top), (bl, r_low), (br, r_low)):
        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=white)

    return img.resize((S, S), Image.LANCZOS)


def square_icon(fg):
    """不透明方形蓝底，用于 .ico / web 图标。"""
    base = Image.new("RGBA", (S, S), BLUE)
    base.alpha_composite(fg)
    return base.convert("RGB")


def round_logo(fg):
    """透明底 + 蓝圆盘，用于应用内展示（旋转动效不露方角）。"""
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pad = sc(24)
    d.ellipse([pad, pad, W - pad, W - pad], fill=BLUE)
    img = img.resize((S, S), Image.LANCZOS)
    img.alpha_composite(fg)
    return img


def recolour(fg, rgb):
    """把白色符号着色为单色剪影（托盘图标用）。"""
    out = fg.copy().convert("RGBA")
    px = out.load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            a = px[x, y][3]
            px[x, y] = (*rgb, a) if a > 0 else (0, 0, 0, 0)
    return out


def main():
    fg = foreground()
    IMG.mkdir(parents=True, exist_ok=True)
    fg.save(IMG / ".." / "_fg_tmp.png")  # 中间产物，稍后清理

    logo = round_logo(fg)
    square = square_icon(fg)

    # 应用内 logo（透明底圆盘）
    for size in (1024, 512, 256, 128, 32):
        name = "logo-1024.png" if size == 1024 else "logo-512.png" if size == 512 else f"logo-{size}.png"
        logo.resize((size, size), Image.LANCZOS).save(IMG / name)
    # 兼容 gen.py 的命名：logo-1024.png 亦作为源图
    logo.save(IMG / "logo-1024.png")

    # 托盘单色版
    recolour(fg.resize((32, 32), Image.LANCZOS), (0, 0, 0)).save(IMG / "logo-32-black.png")
    recolour(fg.resize((32, 32), Image.LANCZOS), (255, 255, 255)).save(IMG / "logo-32-white.png")

    ico_src = square
    ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    ico = ico_src.resize((256, 256), Image.LANCZOS)
    ico.save(IMG / "logo.ico", sizes=ico_sizes)

    packaging = ROOT / "app/assets/packaging/logo.ico"
    packaging.parent.mkdir(parents=True, exist_ok=True)
    ico.save(packaging, sizes=ico_sizes)

    win_ico = ROOT / "app/windows/runner/resources/app_icon.ico"
    win_ico.parent.mkdir(parents=True, exist_ok=True)
    ico.save(win_ico, sizes=ico_sizes)

    web = ROOT / "app/web/icons"
    web.mkdir(parents=True, exist_ok=True)
    for size, name, scale in (
        (192, "Icon-192.png", 1.0),
        (512, "Icon-512.png", 1.0),
        (192, "Icon-maskable-192.png", 0.82),
        (512, "Icon-maskable-512.png", 0.82),
    ):
        if scale == 1.0:
            square.resize((size, size), Image.LANCZOS).save(web / name)
        else:
            inner = square.resize((round(size * scale), round(size * scale)), Image.LANCZOS)
            canvas = Image.new("RGB", (size, size), BLUE[:3])
            canvas.paste(inner, ((size - inner.width) // 2, (size - inner.height) // 2))
            canvas.save(web / name)

    (IMG / ".." / "_fg_tmp.png").unlink(missing_ok=True)
    print("应用内图标已生成：", sorted(p.name for p in IMG.glob("logo-*")))


if __name__ == "__main__":
    main()
