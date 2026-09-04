# Kıyma

A 2D cooking sim behind the counter of an Adana kebab shop. Landscape, mobile,
Flutter + Flame. `com.dafalabs.kiyma`.

The game design lives outside this repository, in the art project
(`~/kiyma_asset`): `docs/kebap-oyunu-tasarim.md` is the rulebook and
`app_plan/` is how it was to be built. This README covers only what a
developer needs to work on the code.

## One coordinate space

Every position in the game — the painted layers, all 35 regions, the recipe
offsets — was measured in one **1024×576** space. `KiymaGame` fits that space
to the screen with a single fixed-resolution viewport, so nothing below it
ever asks how big the phone is.

Regions are **quads, not rectangles**. The kitchen is painted with a wide lens
and the counter leans, so a bounding box catches taps meant for the area next
door and puts food beside the surface it should be resting on. `Quad` measures
width along the top edge, height along the left edge, and rotates by the top
edge's slope. Slots inside a region are interpolated from its four corners, so
a slot in a leaning area leans with it.

## Startup

`main` registers two things by hand — the router and the `BootstrapPort` —
and everything else comes out of the container, because
`configureDependencies` is itself the first bootstrap job: nothing registered
before it can depend on it. `StartupPage` is the initial route and the only
place that container is built.

The three jobs are `dependencies`, `scene`, `art`, in that order, all under
the `restart` policy. There is no reduced game to fall back to, and a scene
file that will not parse is not something a retry fixes. They are three jobs
rather than one so the splash bar moves and a failure names the step.

`StartupPage` is the brand screen from the design: cream ground, tiled dots,
the wordmark in its charcoal outline, and a skewer painted rather than loaded
— this is the screen the art is being loaded *behind*, so it cannot use any of
it. Its typeface, Rubik, is the one file in `assets/fonts`; it is a variable
font, so weights are chosen with `fontVariations` and not `fontWeight`.

`GameWorld` is the `@lazySingleton` the last two jobs fill; its getters throw
rather than return null, because no screen exists before bootstrap finishes.
When the jobs are done the port calls `replaceAll([GameRoute()])`. Nothing
watches a flag for that — what startup opens is the port's business, which is
the point of the boundary.

The between-days cards are not routes. They are drawn over the live canvas so
the counter stays visible behind them, which is why `AppRouter` has two
entries and not five; the shell screens of stage 7 are what it grows for.

## The screens

```
Startup ─ no language stored? ─ Language ─┐
        └─ otherwise ──────────────────────┴─ Menu ─ Play ─ Day ─ Open ─ Game
                                              └─ Upgrade ─ Shop         ↓ time up
                                                     Summary ─ new run / menu
```

Seven routes, one game. `KiymaCubit` is a `@lazySingleton` because it outlives
every screen; each page provides the same instance rather than making one.

A run is a **clock**: `180s + day * 5s`, with customers arriving as seats
free until it stops. What it pays feeds **XP**, and XP is what turns the day
over — the two are the same number underneath and are never shown together,
so progress reads as levelling rather than as a bank balance. The counter
itself shows only the till and the clock; the level belongs to the screens
either side of it.

Ingredients go on **before or after the meat**, on both lines. Requiring the
meat first made the grill a lock on everything else: with nothing to do but
wait for a skewer, six seconds of cooking were six seconds of standing still.
What has to come first still does — bread starts a wrap, bread starts a plate
— and meat is still what makes either one servable.

Each line carries **four** ingredients, not five. A fifth is more than an
order card shows well and more than a player scans mid-rush; parsley came off
the wrap and aubergine off the plate, and the two wells they left are empty
steel.

**A touch places what has one place to go** — meat on the grill, an
ingredient on the wrap, a component on the plate, a jug into the first empty
glass. Dragging is still the vocabulary and still the only way to say *who*
something is for, but requiring it where there is no choice is friction with
no decision behind it.

**The clock and the calendar are furniture, not HUD.** The countdown burns
on the glass of a digital clock hung on the tiled wall, and the day number
sits on a calendar nailed up beside the grill. Both are `dekor` regions —
they scale and lean with the scene, and nothing can be dropped on them. The
cases are art; only the digits are drawn in code. What is left of the HUD is
the pause button and the till, both moved to the top left because the right
wall is the clock's, and both sized for a phone at arm's length rather than
for the 1024-wide space they are measured in.

**Three** customers at most, and each one **walks in from the right** before
they order and **out to the left** when they are done — until they are
standing at the counter there is no card, no patience and nothing that can be
handed to them, and the seat frees the moment they turn to go. Everyone walks
at their own speed, somewhere between the quickest and 40 % of it, so a queue
does not move as one body. Their order sits to the right of their head and
their patience runs up a bar on the left, so neither has to be found inside
the other. A fourth place did not fit that layout on the same stretch of
counter.

A customer is drawn as **one colour**, from a nine-value state: walking,
five degrees of waiting from calm to angry, and three ways of leaving —
served in full, in part, or not at all. The characters were never drawn, so
until they are the state is the art; when a model arrives it hangs off the
same enum.

Customers pay in **gold, onto the ledge they stood at**, in one of three
random piles, and it only reaches the till when the player touches it. After
ten seconds the counter sweeps it up on its own and keeps 70 % — what a touch
buys is the tip, not the sale, and the tag goes red for the last three
seconds. The counter also points at a step being skipped: the thing that unblocks it
breathes inside an orange halo of **its own silhouette**, not of its region
box — a region is a hit target, and a lit rectangle around a tray of parsley
reads as an overlay where a halo reads as the object asking. Three seconds
with an empty grill and the mince tray asks, four with an empty wrap station
and the bread does, five with a burnt skewer on the grill and the bin does,
and reaching for a rolled wrap with no paper on it makes the paper answer for
two and a half. A gold pile flashes the same way for its last three seconds.
None of it changes a rule. The pause button stops everything — asked for, so not the free breather that
walking out would have been. In a debug build, holding the menu's language
button for three seconds grants ₺1000; XP is untouched, so the level stays
whatever was actually played.

**Locked is not dimmed, it is absent.** A tray, an area or a place at the
counter that money has not opened is not drawn and cannot be touched —
`Unlocks.shows` answers for both the renderer and the hit test, so the two
can never disagree. Day one was otherwise a wall of padlocks with a shop
behind it, and the upgrade screen already says what the locks are.

The grill is the one refusal said out loud: raw meat aimed at a full grill
flashes it red and reports `mangalDolu`. Everywhere else a drop that will not
take is visible on the counter; four small slots on a dark surface at the
edge of the scene are not, and a skewer that quietly fails to appear reads as
a lost input.

Wraps and plates share **one** shelf. Two half-depth ones drew everything at
half size; merged, the items lean on each other so four fit at the size the
prep area draws them. Nothing shrinks when it is picked up either — a carried
thing is sized from the region that draws it at home, not from a constant.

A finished wrap holds the prep area until it is carried off, which is the
whole of the pressure in the wrap line: one at a time, and each one a choice
between serving it now and shelving it. The grill is aimed at as an **area**
rather than a slot — whatever is under the finger if it fits, else the
nearest thing that does.

Nothing is carried between runs and nothing is lost by closing the app, which
is why the design doc's half-finished day (11.5) and its reputation system
(9) are both gone. What losing a customer costs is the seat they occupy for
the length of their patience bar.

Each grill slot carries a **dial**, not a bar: a segmented ring with a flame
while the meat cooks, a draining yellow ring with a tick while it is worth
taking, and a full red one with an exclamation once it is burnt. The ready
one breathes — of four badges the one that moves is the one there is
something to do about. Raw and
cooking fill one meter between them — they are the same wait from the
player's side, and a bar that emptied and started again read as a fault. Four
thin bars on a leaning grill were indistinguishable from each other and from
the coals.

The grill is aimed at as one area, not as four slots. Meat dropped anywhere
on it fills the slot under the finger or the nearest free one; a drag off it
takes whatever is under the finger, and failing that the most urgent skewer —
cooked before burnt, and of the cooked ones the one nearest to burning.
Hitting an exact slot on a leaning grill was the wrong thing to ask of a
player mid-rush.

Leaving the counter **ends** the run rather than suspending it. Off screen the
clocks stop, so a run you can step out of and back into is a pause button the
design does not have (10.4). Nothing is lost: money banks as it is earned.

## Where the rules live

`DayRun` is the whole game: the grill, the two prep stations, the shelves, the
customers, and every rule that moves them. It is plain Dart — no Flame, no
widgets — and it is what the tests drive. `CounterComponent` renders from it
and feeds gestures into it; `KiymaCubit` owns what survives a run.

The split is deliberate about update rates. Patience bars and cooking meters
change every frame and are drawn inside the canvas. The bloc only emits when
money, standing or the phase move — a few times a second at most.

## The art pipeline

`assets/items` and `assets/data/scene.json` are **generated**, not hand-kept.
`tool/prepare_assets.py` reads the art project, ships one variant per asset
family capped at 512 px, and rewrites `regions.json` down to the fields the
game reads. Re-run it after regenerating art:

```bash
python3 tool/prepare_assets.py [~/kiyma_asset]
```

The renderer skips an image it cannot find, so a missing one looks like an
empty grill rather than an error. `test/assets_test.dart` is what turns that
into a failing test — add any new name the code asks for by hand to its list.

## Running it in a browser

`web/` is here so the counter can be opened without a phone:

```bash
fvm flutter build web --release
python3 -m http.server 8765 --directory build/web
```

Landscape and touch, so a browser window is a compromise, not the target.

## Verifying

```bash
fvm flutter analyze
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden               # add --update-goldens to rewrite
```

The golden is one frame of a fully open counter. Placement is arithmetic on
measured quads and a wrong sign is invisible to every rule test, so it is
worth the 900 KB. It is excluded from CI with the rest of the goldens: the
baseline is rendered by the host, and macOS does not match Linux.

## Not built yet

Stages 6 to 8 of the plan. Named so nobody has to rediscover them:

- **Nothing is saved except the language.** Money, the day number and the
  unlocks live in memory and are gone when the app closes, so the menu's
  money chip reads zero on every launch. easy_localization persists the
  chosen locale on its own, which is also what tells the app it is a first
  run.
- **No settings screen, no ads, no IAP.** The menu reaches the language
  screen directly, which is the whole of the settings that exists.
- **Placeholder art in two places.** The chef and the customers were never
  drawn — they are meant to be animated — so a customer is a silhouette with
  a real order card. The bin has no asset either and is drawn in code; drop a
  `cop_kovasi.png` into `assets/items` and `_renderTrash` becomes one call.
- **The numbers are the doc's opening suggestions.** Everything in
  `Balance` is marked `[ÖNERİ]` in the design doc and is waiting for
  playtest. The money target table was derived from the income formula, so
  changing the formula means recomputing the table.
