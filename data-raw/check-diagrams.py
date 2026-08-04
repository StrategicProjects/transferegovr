#!/usr/bin/env python3
"""Checks the hand-written SVG diagrams for connector defects.

    python3 data-raw/check-diagrams.py

Two kinds of defect got past visual review before this existed:

  * an arrow whose endpoint landed in the gap *between* two boxes rather than
    on either of them, so the flow silently bypassed a whole stage;
  * arrows that were correctly attached but read as detached, because the
    shaft was 12px carrying a 6px arrowhead.

So this reports, per diagram, any connector that starts nowhere and the
shortest shaft leading into an arrowhead. Endpoints are also compared against
the target box's centre, which is what catches an arrow landing off-centre on
a box that is narrower than the one above it.

The only expected "loose" paths are the arrowhead marker definitions inside
<defs>; they are filtered out by shape.
"""

import re
import sys

DIAGRAMS = [
    "man/figures/architecture.svg",
    "vignettes/articles/figures/trilha-do-dinheiro.svg",
]

MIN_SHAFT = 24      # px of line before an arrowhead
CENTRE_TOL = 6      # px an arrow may miss a box centre by
TOL = 3


def parse(path):
    text = open(path).read()

    rects = []
    for m in re.finditer(
        r'<rect x="([-\d.]+)" y="([-\d.]+)" width="([\d.]+)" height="([\d.]+)"',
        text,
    ):
        x, y, w, h = map(float, m.groups())
        if w > 900 and h > 800:      # the page border
            continue
        rects.append((x, y, x + w, y + h))

    connectors = []
    for m in re.finditer(r'<path d="(M[^"]+)"', text):
        d = m.group(1)
        if d.count("M") > 1 or "L" in d:     # the grid, and marker heads
            continue

        start = text.find(m.group(0))
        attrs = text[start:text.find(">", start)]
        open_g = text.rfind("<g", 0, start)
        group = text[open_g:text.find(">", open_g)] if 0 < start - open_g < 400 else ""

        points, x, y = [], None, None
        for cmd, a, b in re.findall(r"([MVH])\s*([-\d.]+)(?:\s+([-\d.]+))?", d):
            if cmd == "M":
                x, y = float(a), float(b)
            elif cmd == "V":
                y = float(a)
            else:
                x = float(a)
            points.append((x, y))

        connectors.append({
            "d": d,
            "points": points,
            "arrow": "marker" in attrs or "marker" in group,
        })

    return rects, connectors


def on_box(point, rects):
    x, y = point
    for x0, y0, x1, y1 in rects:
        if x0 - TOL <= x <= x1 + TOL and (abs(y - y0) <= TOL or abs(y - y1) <= TOL):
            return True
        if y0 - TOL <= y <= y1 + TOL and (abs(x - x0) <= TOL or abs(x - x1) <= TOL):
            return True
    return False


def on_connector(point, segments, own):
    x, y = point
    for a, b in segments:
        if (a, b) == own or (b, a) == own:
            continue
        if abs(a[0] - b[0]) < 2 and abs(x - a[0]) < 2 \
                and min(a[1], b[1]) - 2 <= y <= max(a[1], b[1]) + 2:
            return True
        if abs(a[1] - b[1]) < 2 and abs(y - a[1]) < 2 \
                and min(a[0], b[0]) - 2 <= x <= max(a[0], b[0]) + 2:
            return True
    return False


APPROACH = 12   # px an arrowhead may stop short of the box it points at


def target(point, rects):
    """What an arrowhead points at.

    Returns ("centre-offset", px) when it approaches a box from above or
    below, ("edge", 0) when it approaches one from the side, and None when it
    points at no box at all -- which is the defect that started this script:
    an arrow ending in the gap between two boxes matches nothing, and
    reporting that as "no target" is the whole point.
    """
    x, y = point
    for x0, y0, x1, y1 in rects:
        if x0 <= x <= x1 and (0 <= y0 - y <= APPROACH or 0 <= y - y1 <= APPROACH):
            return ("centre-offset", (x0 + x1) / 2 - x)
        if y0 <= y <= y1 and (0 <= x0 - x <= APPROACH or 0 <= x - x1 <= APPROACH):
            return ("edge", 0)
    return None


def main():
    problems = 0

    for path in DIAGRAMS:
        rects, connectors = parse(path)
        segments = [
            (c["points"][i], c["points"][i + 1])
            for c in connectors
            for i in range(len(c["points"]) - 1)
        ]

        print(f"== {path}  ({len(rects)} boxes, {len(connectors)} connectors)")

        shortest = None
        for c in connectors:
            points = c["points"]
            own = (points[0], points[1]) if len(points) > 1 else None

            if not (on_box(points[0], rects) or on_connector(points[0], segments, own)):
                print(f"   LOOSE      {c['d']}")
                problems += 1

            if not c["arrow"]:
                continue

            a, b = points[-2], points[-1]
            shaft = abs(b[1] - a[1]) or abs(b[0] - a[0])
            if shortest is None or shaft < shortest[0]:
                shortest = (shaft, c["d"])
            if shaft < MIN_SHAFT:
                print(f"   SHORT {shaft:>4.0f}px {c['d']}")
                problems += 1

            hit = target(b, rects)
            if hit is None:
                print(f"   POINTS AT NOTHING  {c['d']}  ends at {b}")
                problems += 1
            elif hit[0] == "centre-offset" and abs(hit[1]) > CENTRE_TOL:
                print(f"   OFF-CENTRE by {hit[1]:+.0f}px  {c['d']}")
                problems += 1

        if shortest:
            print(f"   shortest shaft: {shortest[0]:.0f}px  ({shortest[1]})")

    print("\nOK" if not problems else f"\n{problems} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
