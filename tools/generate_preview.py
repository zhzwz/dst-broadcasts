#!/usr/bin/env python3
"""从 wilson.svg 生成创意工坊 preview.png（512x512）。"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SVG = ROOT / "wilson.svg"
DEFAULT_OUT = ROOT / "preview" / "preview.png"
SIZE = 512
ICON_SCALE = 0.72
BG_RGBA = (99, 73, 49, 128)  # rgba(99,73,49,0.5)


def render_svg(svg: Path, size: int) -> Image.Image:
    qlmanage = shutil.which("qlmanage")
    if not qlmanage:
        raise RuntimeError("需要 macOS qlmanage 来渲染 SVG")

    with tempfile.TemporaryDirectory() as tmp:
        tmp_dir = Path(tmp)
        src = tmp_dir / svg.name
        shutil.copy2(svg, src)
        subprocess.run(
            [qlmanage, "-t", "-s", str(size), "-o", str(tmp_dir), str(src)],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        rendered = tmp_dir / f"{svg.name}.png"
        if not rendered.exists():
            raise RuntimeError(f"qlmanage 未产出缩略图: {rendered}")
        return Image.open(rendered).convert("RGBA")


def silhouette_to_black(icon: Image.Image) -> Image.Image:
    """白底黑线 SVG → 透明底黑色剪影。"""
    pixels = icon.load()
    w, h = icon.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a < 10 or (r > 220 and g > 220 and b > 220):
                pixels[x, y] = (0, 0, 0, 0)
            else:
                lum = (r + g + b) / 3
                alpha = int(round((255 - lum) * (a / 255)))
                pixels[x, y] = (0, 0, 0, alpha)
    return icon


def compose(icon: Image.Image, size: int, scale: float) -> Image.Image:
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    overlay = Image.new("RGBA", (size, size), BG_RGBA)
    canvas = Image.alpha_composite(bg, overlay)

    bbox = icon.getbbox()
    if bbox:
        icon = icon.crop(bbox)

    target = int(size * scale)
    ratio = min(target / icon.width, target / icon.height)
    new_size = (
        max(1, int(icon.width * ratio)),
        max(1, int(icon.height * ratio)),
    )
    icon = icon.resize(new_size, Image.Resampling.LANCZOS)

    x = (size - icon.width) // 2
    y = (size - icon.height) // 2
    canvas.paste(icon, (x, y), icon)
    return canvas.convert("RGB")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--svg", type=Path, default=DEFAULT_SVG)
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--size", type=int, default=SIZE)
    parser.add_argument("--scale", type=float, default=ICON_SCALE)
    args = parser.parse_args()

    if not args.svg.is_file():
        raise SystemExit(f"找不到 SVG: {args.svg}")

    icon = render_svg(args.svg, args.size)
    icon = silhouette_to_black(icon)
    preview = compose(icon, args.size, args.scale)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    preview.save(args.output, "PNG")
    print(f"wrote {args.output} ({preview.size[0]}x{preview.size[1]})")


if __name__ == "__main__":
    main()
