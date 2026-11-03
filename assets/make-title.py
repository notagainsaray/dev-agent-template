"""Generates assets/title.svg: a 3D 8-bit title. Run: python3 assets/make-title.py"""
from pathlib import Path

LINES = ["DEV AGENT", "TEMPLATE"]
PX = 12          # size of one pixel
GAP = 1          # gap between pixels, for the 8-bit grid look
DEPTH = 7        # extrusion layers
STEP = 2         # offset per extrusion layer
LINE_GAP = 3     # empty pixel rows between lines
PAD = 8

FONT = {
    "A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    "D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
    "E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
    "G": ["01110", "10001", "10000", "10111", "10001", "10001", "01110"],
    "L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
    "M": ["10001", "11011", "11111", "10101", "10001", "10001", "10001"],
    "N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
    "P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
    "T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    "V": ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
    " ": ["000"] * 7,
}


def line_pixels(text):
    """(col, row) of every lit pixel in one line, plus its width in pixels."""
    pixels, col = [], 0
    for ch in text:
        glyph = FONT[ch]
        for r, row in enumerate(glyph):
            pixels += [(col + c, r) for c, bit in enumerate(row) if bit == "1"]
        col += len(glyph[0]) + 1
    return pixels, col - 1


def all_pixels():
    lines = [line_pixels(t) for t in LINES]
    width = max(w for _, w in lines)
    out = []
    for i, (pixels, w) in enumerate(lines):
        dx, dy = (width - w) // 2, i * (7 + LINE_GAP)
        out += [(c + dx, r + dy) for c, r in pixels]
    rows = len(LINES) * 7 + (len(LINES) - 1) * LINE_GAP
    return out, width, rows


def svg():
    pixels, cols, rows = all_pixels()
    extra = DEPTH * STEP
    w, h = cols * PX + extra + 2 * PAD, rows * PX + extra + 2 * PAD
    s = PX - GAP
    rects = "".join(f'<rect x="{c * PX}" y="{r * PX}" width="{s}" height="{s}"/>' for c, r in pixels)
    shine = "".join(f'<rect x="{c * PX}" y="{r * PX}" width="{s}" height="3"/>' for c, r in pixels)
    layers = []
    for k in range(DEPTH, 0, -1):  # back to front, darker further back
        t = k / DEPTH
        shade = (int(0x7B - 0x51 * t), int(0x2F - 0x25 * t), int(0xF7 - 0x99 * t))
        layers.append(f'<use href="#px" x="{k * STEP}" y="{k * STEP}" fill="#{"%02x%02x%02x" % shade}"/>')
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="img" aria-label="{" ".join(LINES)}" shape-rendering="crispEdges">
<defs>
<linearGradient id="face" x1="0" y1="0" x2="0" y2="{rows * PX}" gradientUnits="userSpaceOnUse">
<stop offset="0" stop-color="#ffe14d"/><stop offset="0.45" stop-color="#ff8a1f"/><stop offset="0.55" stop-color="#ff5fa2"/><stop offset="1" stop-color="#c13bff"/>
</linearGradient>
<g id="px">{rects}</g>
</defs>
<g transform="translate({PAD} {PAD})">
{"".join(layers)}
<use href="#px" fill="url(#face)"/>
<g fill="#ffffff" fill-opacity="0.35">{shine}</g>
</g>
</svg>
'''


if __name__ == "__main__":
    out = Path(__file__).with_name("title.svg")
    out.write_text(svg())
    print(f"wrote {out}")
