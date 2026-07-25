#!/usr/bin/env python3
"""Draws the Dabali brand mark and writes the icon/splash source images.

Run from the project root:

    python3 tools/generate_branding.py

Everything is drawn from the constants below, so adjusting a colour or a
proportion is a one-line change followed by a re-run. Outputs land in
assets/branding/ and feed flutter_launcher_icons and flutter_native_splash.
"""

from pathlib import Path

from PIL import Image, ImageDraw

# Brand colours, kept in step with lib/core/theme/app_colors.dart.
YELLOW = (255, 194, 68, 255)  # primaryContainer #FFC244
CHARCOAL = (25, 28, 29, 255)  # onSurface #191C1D
DEEP_GOLD = (124, 88, 0, 255)  # primary #7C5800

SIZE = 1024
# Draw large and downsample: Pillow has no antialiasing on shape outlines.
SUPERSAMPLE = 4

# Android adaptive icons crop heavily; keep the mark inside the safe zone.
FOREGROUND_SCALE = 0.60

OUTPUT_DIR = Path("assets/branding")


def draw_mark(draw: ImageDraw.ImageDraw, scale: float) -> None:
    """Draws the scooter and its speed lines on a 1024-unit grid."""

    def px(value: float) -> float:
        return value * scale

    def line(start, end, width, colour):
        draw.line(
            [(px(start[0]), px(start[1])), (px(end[0]), px(end[1]))],
            fill=colour,
            width=int(px(width)),
            joint="curve",
        )
        # Pillow has no round caps, so cap the ends with circles by hand.
        for point in (start, end):
            radius = width / 2
            draw.ellipse(
                [
                    px(point[0] - radius),
                    px(point[1] - radius),
                    px(point[0] + radius),
                    px(point[1] + radius),
                ],
                fill=colour,
            )

    def ring(center, outer_radius, thickness, colour):
        draw.ellipse(
            [
                px(center[0] - outer_radius),
                px(center[1] - outer_radius),
                px(center[0] + outer_radius),
                px(center[1] + outer_radius),
            ],
            outline=colour,
            width=int(px(thickness)),
        )

    # Speed lines trailing behind, in the deeper gold so the scooter stays first.
    line((150, 545), (285, 545), 30, DEEP_GOLD)
    line((115, 650), (235, 650), 30, DEEP_GOLD)
    line((165, 755), (275, 755), 30, DEEP_GOLD)

    rear_wheel = (355, 690)
    front_wheel = (765, 690)
    wheel_radius = 100

    # Deck and column stop at the tyres rather than at the hubs, so nothing
    # crosses the inside of a wheel and muddies the shape at small sizes.
    line(
        (rear_wheel[0] + wheel_radius, 690),
        (front_wheel[0] - wheel_radius, 690),
        46,
        CHARCOAL,
    )
    # Steering column rising from the top of the front wheel.
    line((front_wheel[0], 690 - wheel_radius), (800, 345), 46, CHARCOAL)
    # Handlebar across the top of the column.
    line((690, 330), (865, 330), 42, CHARCOAL)

    ring(rear_wheel, wheel_radius, 46, CHARCOAL)
    ring(front_wheel, wheel_radius, 46, CHARCOAL)


def render(with_background: bool, mark_scale: float) -> Image.Image:
    """Composes the mark on a square canvas, optically centred.

    The mark is cropped to its own ink before being placed, so the result is
    centred on what is actually drawn rather than on the drawing grid.
    """
    working = SIZE * SUPERSAMPLE
    image = Image.new("RGBA", (working, working), (0, 0, 0, 0))

    if with_background:
        radius = int(working * 0.22)  # iOS/Android superellipse-ish corner
        ImageDraw.Draw(image).rounded_rectangle(
            [0, 0, working - 1, working - 1], radius, fill=YELLOW
        )

    layer = Image.new("RGBA", (working, working), (0, 0, 0, 0))
    draw_mark(ImageDraw.Draw(layer), SUPERSAMPLE)
    layer = layer.crop(layer.getbbox())

    # Fit the longest side to the requested share of the canvas.
    target = working * mark_scale
    ratio = target / max(layer.width, layer.height)
    layer = layer.resize(
        (max(1, round(layer.width * ratio)), max(1, round(layer.height * ratio))),
        Image.LANCZOS,
    )

    image.alpha_composite(
        layer,
        ((working - layer.width) // 2, (working - layer.height) // 2),
    )

    return image.resize((SIZE, SIZE), Image.LANCZOS)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    outputs = {
        # Full-bleed icon for iOS and pre-adaptive Android.
        "icon.png": render(with_background=True, mark_scale=0.80),
        # Adaptive-icon layers: flat colour behind, mark inside the safe zone.
        "icon_foreground.png": render(with_background=False, mark_scale=FOREGROUND_SCALE),
        # Native splash: the mark alone, the background comes from the config.
        "splash.png": render(with_background=False, mark_scale=0.70),
    }

    for name, image in outputs.items():
        path = OUTPUT_DIR / name
        image.save(path)
        print(f"wrote {path} ({image.width}x{image.height})")


if __name__ == "__main__":
    main()
