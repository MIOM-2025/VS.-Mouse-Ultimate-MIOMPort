#!/usr/bin/env python3
"""Make flixel-animate's filter baking fail soft on Android."""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
patched = 0


def read(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write(path, src):
    with open(path, "w", encoding="utf-8") as f:
        f.write(src)


def patch(path, replacements):
    global patched
    src = read(path)
    original = src
    for old, new in replacements:
        if new in src:
            continue
        if old not in src:
            print("[patch_animate] pattern missing in %s" % path)
            continue
        src = src.replace(old, new, 1)
    if src != original:
        write(path, src)
        patched += 1
        print("[patch_animate] patched %s" % path)


FR = glob.glob(os.path.join(ROOT, ".haxelib", "flixel-animate", "*", "src", "animate", "internal", "FilterRenderer.hx"))
FM = glob.glob(os.path.join(ROOT, ".haxelib", "flixel-animate", "*", "src", "animate", "internal", "Frame.hx"))
print("[patch_animate] FilterRenderer:", FR)
print("[patch_animate] Frame:", FM)

for path in FR:
    patch(path, [
        (
            "\t\t\tvar gfx = cam.canvas.graphics;\n"
            "\t\t\tvar gfxBounds = gfx.__bounds;\n"
            "\t\t\tresultFilteredBounds = expandFilterBounds(FlxRect.get().copyFromFlash(gfxBounds), scaledFilters);\n"
            "\t\t\tresultFilteredBounds.copyToFlash(gfxBounds);\n",
            "\t\t\tvar gfx = cam.canvas.graphics;\n"
            "\t\t\tvar gfxBounds = gfx.__bounds;\n"
            "\t\t\tif (gfxBounds == null) {\n"
            "\t\t\t\tresultFilteredBounds = bounds.copyTo(FlxRect.get());\n"
            "\t\t\t} else {\n"
            "\t\t\t\tresultFilteredBounds = expandFilterBounds(FlxRect.get().copyFromFlash(gfxBounds), scaledFilters);\n"
            "\t\t\t\tresultFilteredBounds.copyToFlash(gfxBounds);\n"
            "\t\t\t}\n",
        ),
        (
            "\t\tvar frame = FlxGraphic.fromBitmapData(bitmap).imageFrame.frame;\n"
            "\t\tframe.parent.persist = true;\n",
            "\t\tif (bitmap == null) {\n"
            "\t\t\tscale.put();\n"
            "\t\t\treturn null;\n"
            "\t\t}\n"
            "\t\tvar frame = FlxGraphic.fromBitmapData(bitmap).imageFrame.frame;\n"
            "\t\tframe.parent.persist = true;\n",
        ),
    ])

FRAME_PATTERN = re.compile(
    r"(?P<indent>[ \t]*)var bakedFrame:Null<AtlasInstance> = FilterRenderer\.bakeFrame\(this, frameIndex \+ this\.index, layer\);\s*\n"
    r"\s*if \(bakedFrame == null\)\s*\n"
    r"\s*return;"
)


def frame_replace(m):
    ind = m.group("indent")
    return (
        ind + "var bakedFrame:Null<AtlasInstance> = null;\n"
        + ind + "try {\n"
        + ind + "\tbakedFrame = FilterRenderer.bakeFrame(this, frameIndex + this.index, layer);\n"
        + ind + "} catch (e:Dynamic) {\n"
        + ind + "\t_dirty = false;\n"
        + ind + "\treturn;\n"
        + ind + "}\n"
        + ind + "if (bakedFrame == null) {\n"
        + ind + "\t_dirty = false;\n"
        + ind + "\treturn;\n"
        + ind + "}"
    )


for path in FM:
    src = read(path)
    if "catch (e:Dynamic)" in src and "bakedFrame = FilterRenderer.bakeFrame" in src:
        print("[patch_animate] already patched %s" % path)
        continue
    src2, n = FRAME_PATTERN.subn(frame_replace, src, count=1)
    if n == 0:
        print("[patch_animate] pattern missing in %s" % path)
        continue
    write(path, src2)
    patched += 1
    print("[patch_animate] patched %s" % path)

if patched == 0:
    print("[patch_animate] nothing to patch (already patched or library missing)")
sys.exit(0)

