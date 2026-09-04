#!/usr/bin/env python3
"""Turn the art repository into what the game ships.

Source lives outside this monorepo (`~/kiyma_asset`): 153 PNGs at generator
resolution plus a `regions.json` full of the measurements that placed them.
Neither is shippable. This makes three cuts:

  * one variant per asset family survives — the one `regions.json` points at,
    else `_1`;
  * every image is capped at MAX_EDGE, because nothing is drawn wider than
    ~300 logical px in a 1024x576 scene;
  * `regions.json` is rewritten as `scene.json` with only the fields the game
    reads. The edge fits and per-corner angles were how the quads were found;
    the game only needs the quads.

Run it again after regenerating art:

    python3 tool/prepare_assets.py [~/kiyma_asset]
"""

import json
import os
import re
import subprocess
import sys

SRC = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else "~/kiyma_asset")
DST = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets")

MAX_EDGE = 512
SCENE = (2048, 1152)  # 2x the 1024x576 reference space

# Section 11 of the asset catalogue: no region binds these.
# Only baklava ships: one dessert is the whole of that line.
UNUSED = {
    "kesme_tahtasi",
    "dereotu_tepsi",
    "dereotu_porsiyon",
    "sutlac",
    "kunefe",
    # Four per line, not five: see DROPPED_INGREDIENTS.
    "maydanoz_tepsi",
    "maydanoz_durum",
    "maydanoz_porsiyon",
    "patlican_tepsi",
    "patlican_porsiyon",
}

# Five ingredients a line is more than an order card can show and more than a
# player can scan mid-rush. One goes from each: parsley off the wrap and
# aubergine off the plate. Their trays, their strips and their order icons all
# come out with them, and the two wells they leave are empty steel.
DROPPED_INGREDIENTS = {"maydanoz", "patlican"}

# Design doc section 7 makes the bin mandatory and the art repository had no
# region for it. The floor in front of the grill is the only free ground in
# the scene and it is where burnt meat already is, so the drag is short.
COP_ALANI = {
    "name": "cop_alani",
    "category": "cop",
    "asset": "cop_kovasi_1.png",
    "asset_fit": "alt",
    "x": 0,
    "y": 470,
    "w": 104,
    "h": 106,
    "quad": [[0, 470], [92, 470], [104, 576], [0, 576]],
}

# Where a customer leaves what they paid: the wooden ledge they stand at,
# one pile under each of the four places. Derived from `tezgah_ust_kenari` and
# inset, so it wins the hit test against the ledge it sits on.
ALTIN_ALANI = {
    "name": "altin_alani",
    "category": "altin",
    "kapasite": 3,
    "asset_fit": "alt",
}

# The clock and the calendar belong to the room, not to a HUD panel: they
# hang on the tiled wall and the run is read off them. Regions rather than
# layers so the renderer can draw the digits into them; `dekor` so no gesture
# can land on one. The `_2` says which generated variant ships, the same way a
# region in `regions.json` does.
DEKOR = [
    {
        "name": "duvar_saati",
        "category": "dekor",
        "asset": "duvar_saati_2.png",
        "asset_fit": "orta",
        # Above the rightmost order card, which reaches y95.
        "x": 806, "y": 2, "w": 206, "h": 92,
    },
    {
        "name": "duvar_takvimi",
        "category": "dekor",
        "asset": "takvim_1.png",
        "asset_fit": "orta",
        "x": 20, "y": 152, "w": 92, "h": 128,
    },
]

# Variants for assets no region points at, so the pipeline does not fall back
# to `_1` on something that was picked by eye.
PICKED = {"altin_kese": 2}

KEEP = (
    "name", "x", "y", "w", "h", "quad", "category",
    "kapasite", "asset", "asset_fit", "slot_yon", "istif", "kompozisyon",
)

# The two waiting shelves are adjacent and neither is deep enough on its own
# to hold a wrap at the size the prep area draws it. Merged, with the items
# leaning on each other, four fit at full size.
MERGED_SHELF = {
    "name": "bekleme_alani",
    "category": "hazirlik",
    "kapasite": 3,
    "istif": 0.45,
    "asset_fit": "alt",
}

# Merged into `bekleme_alani`, or belonging to a dessert that no longer
# ships.
DROPPED = {
    "tabak_birakma",
    "durum_bekleme",
    "tatli_sutlac",
    "tatli_kunefe",
    "malzeme_maydanoz",
    "malzeme_patlican",
    # Rebuilt as three, spread over the same frontage.
    "musteri_slot_1",
    "musteri_slot_2",
    "musteri_slot_3",
    "musteri_slot_4",
}

FAMILY = re.compile(r"^(?P<family>.+?)_(?P<variant>\d+)\.png$")


def family_of(path):
    if not path:
        return None
    match = FAMILY.match(os.path.basename(path))
    return match.groupdict() if match else None


def run(*args):
    subprocess.run(args, check=True)


def strip_variant(path):
    """`assets/lavas_tek_1.png` -> `lavas_tek`, matching the shipped names."""
    parts = family_of(path)
    return parts["family"] if parts else None


def slim_layer(layer):
    return {
        "name": layer["name"],
        "src": strip_variant(layer["src"]) or os.path.basename(layer["src"]),
        "x": layer["x"], "y": layer["y"], "w": layer["w"], "h": layer["h"],
        "z": layer["z"],
    }


def slim_composition(comp):
    def slim(entry):
        return {
            "ad": entry["ad"],
            "asset": entry["asset"],
            "genislik": entry["genislik"],
            "ofset_x": entry["ofset_x"],
            "ofset_y": entry["ofset_y"],
        }

    out = {
        "taban": [slim(e) for e in comp.get("taban", [])],
        "malzemeler": [
            slim(e)
            for e in comp.get("malzemeler", [])
            if e["ad"] not in DROPPED_INGREDIENTS
        ],
    }
    if comp.get("son"):
        out["son"] = slim(comp["son"])
    return out


def merged_shelf(regions):
    """One area spanning the plate shelf and the wrap shelf."""
    plate = next(r for r in regions if r["name"] == "tabak_birakma")["quad"]
    wrap = next(r for r in regions if r["name"] == "durum_bekleme")["quad"]
    quad = [plate[0], wrap[1], wrap[2], plate[3]]
    xs = [p[0] for p in quad]
    ys = [p[1] for p in quad]
    return {
        **MERGED_SHELF,
        "x": round(min(xs)),
        "y": round(min(ys)),
        "w": round(max(xs) - min(xs)),
        "h": round(max(ys) - min(ys)),
        "quad": quad,
    }


def gold_area(regions):
    ledge = next(r for r in regions if r["name"] == "tezgah_ust_kenari")["quad"]

    def at(u, v):
        top = [ledge[0][i] + (ledge[1][i] - ledge[0][i]) * u for i in (0, 1)]
        bottom = [ledge[3][i] + (ledge[2][i] - ledge[3][i]) * u for i in (0, 1)]
        return [round(top[i] + (bottom[i] - top[i]) * v, 1) for i in (0, 1)]

    quad = [at(0.04, 0.3), at(0.99, 0.3), at(0.99, 1), at(0.04, 1)]
    xs = [p[0] for p in quad]
    ys = [p[1] for p in quad]
    return {
        **ALTIN_ALANI,
        "x": round(min(xs)),
        "y": round(min(ys)),
        "w": round(max(xs) - min(xs)),
        "h": round(max(ys) - min(ys)),
        "quad": quad,
    }


def customer_slots(regions):
    """Three places where four used to stand.

    A fourth customer needed a fourth order card in the same frontage, and
    each card now has a patience meter beside it. The two measured extremes
    stay put and the middle one is interpolated, so the counter stays even.
    """
    first = next(r for r in regions if r["name"] == "musteri_slot_1")["quad"]
    last = next(r for r in regions if r["name"] == "musteri_slot_4")["quad"]
    out = []
    for i in range(3):
        t = i / 2
        quad = [
            [round(a[k] + (b[k] - a[k]) * t, 1) for k in (0, 1)]
            for a, b in zip(first, last)
        ]
        xs = [p[0] for p in quad]
        ys = [p[1] for p in quad]
        out.append({
            "name": f"musteri_slot_{i + 1}",
            "category": "musteri",
            "x": round(min(xs)),
            "y": round(min(ys)),
            "w": round(max(xs) - min(xs)),
            "h": round(max(ys) - min(ys)),
            "quad": quad,
        })
    return out


def slim_region(region):
    out = {k: region[k] for k in KEEP if k in region}
    if "asset" in out:
        out["asset"] = strip_variant(out["asset"]) or out["asset"]
    if "kompozisyon" in out:
        out["kompozisyon"] = slim_composition(out["kompozisyon"])
    return out


def main():
    os.makedirs(f"{DST}/items", exist_ok=True)
    os.makedirs(f"{DST}/scene", exist_ok=True)
    os.makedirs(f"{DST}/data", exist_ok=True)

    regions = json.load(open(f"{SRC}/regions.json"))

    picked = {}
    def note(path):
        parts = family_of(path)
        if parts:
            picked[parts["family"]] = int(parts["variant"])

    for layer in regions["layers"]:
        note(layer.get("src"))
    for region in regions["regions"] + DEKOR + [COP_ALANI]:
        note(region.get("asset"))
        comp = region.get("kompozisyon") or {}
        for entry in comp.get("taban", []) + comp.get("malzemeler", []):
            note(entry.get("yol"))
        note((comp.get("son") or {}).get("yol"))

    picked.update(PICKED)

    families = {}
    for name in sorted(os.listdir(f"{SRC}/assets")):
        parts = family_of(name)
        if parts:
            families.setdefault(parts["family"], []).append(int(parts["variant"]))

    shipped = []
    for family, variants in sorted(families.items()):
        if family in UNUSED:
            continue
        variant = picked.get(family, 1)
        if variant not in variants:
            variant = min(variants)
        run(
            "magick", f"{SRC}/assets/{family}_{variant}.png",
            "-resize", f"{MAX_EDGE}x{MAX_EDGE}>",
            "-strip", "-define", "png:compression-level=9",
            f"{DST}/items/{family}.png",
        )
        shipped.append(family)

    # `assets/items` is generated, so it is also pruned: dropping an asset
    # from the game has to take the file with it, or it keeps shipping.
    for name in os.listdir(f"{DST}/items"):
        if name.endswith(".png") and name[:-4] not in shipped:
            os.remove(f"{DST}/items/{name}")

    run("magick", f"{SRC}/back_scene.jpg",
        "-resize", f"{SCENE[0]}x{SCENE[1]}!", "-strip", f"{DST}/scene/back_scene.jpg")
    run("magick", f"{SRC}/base_table.png",
        "-resize", "1548x706>", "-strip", f"{DST}/scene/base_table.png")

    scene = {
        "coordinate_space": regions["coordinate_space"],
        "layers": [slim_layer(layer) for layer in regions["layers"]],
        "regions": [
            slim_region(r)
            for r in regions["regions"]
            if r["name"] not in DROPPED
        ]
        + customer_slots(regions["regions"])
        + [
            merged_shelf(regions["regions"]),
            gold_area(regions["regions"]),
            slim_region(COP_ALANI),
        ]
        + [slim_region(d) for d in DEKOR],
    }
    with open(f"{DST}/data/scene.json", "w") as out:
        json.dump(scene, out, ensure_ascii=False, indent=2)
        out.write("\n")

    print(f"{len(shipped)} asset families, {len(scene['regions'])} regions")


main()
