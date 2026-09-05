# Kıyma

A 2D cooking sim behind the counter of an Adana kebab shop. Landscape, mobile,
Flutter + Flame. `com.dafalabs.kiyma`.

The game design lives outside this repository, in the art project
(`~/kiyma_asset`): `docs/kebap-oyunu-tasarim.md` is the rulebook and
`app_plan/` is how it was to be built. This README covers only what a
developer needs to work on the code.

## The layers

```
domain/         the rules, and the value types they move: the run, the
                counter's geometry, the balance numbers, the scene model.
                Pure Dart. No Flutter, no Flame, no IO.
application/    the cubit: state and flow for a screen.
presentation/   the pages, the Flame game and everything that draws.
infrastructure/ what bootstrap loads and what outlives a screen: the scene
                and asset readers, the world they fill, the language flag.
route/ config/  the composition root, reachable from anywhere.
```

`test/layers_test.dart` enforces it. Nothing in a tree says which side of a
line a file is on — you have to open it and read its imports — and the whole
test strategy rests on `DayRun` being engine-free. The only thing that used to
stop somebody importing Flame into it was remembering.

The app is **one feature**, so there is no `features/` directory: `Progress`
and `Unlocks` are shared by the menu, the day card, the shop, the run and the
summary, so any split would either be a single level carrying no information
or several features that all depend on each other. The other two apps in the
repo are feature-first because they have several features; this one has the
counter.

`infrastructure` may see `presentation` in exactly one place, and `world.dart`
says why: it holds what bootstrap pre-renders, and a blurred silhouette is a
drawing.

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

The four jobs are `display`, `dependencies`, `scene`, `art`, in that order;
the last three are under the `restart` policy. There is no reduced game to
fall back to, and a scene file that will not parse is not something a retry
fixes. They are separate jobs rather than one so a failure names the step.

`art` does more than load. All four together take about 60 ms and the brand
screen is held for three seconds, so the window is free, and two things that
would otherwise land on the first frame of a day are done in it: the hint
glows are blurred once (`game/halo.dart`), and every image is drawn once
offscreen to force its texture upload. Decoding happens when the file is
read; the upload does not, and without this it arrives all at once — 54
images, 38 MB, including a 2048x1152 background — on the frame the counter
first appears.

The splash bar shows the **lower** of the two things the screen is waiting on
— how far the jobs have got, and how much of the three-second brand hold has
passed. Everything loads in under 100 ms, so taking the higher of the two
filled the bar in the first few frames and then left it sitting at 100 % for
most of the time it was on screen. Four jobs is also four steps, and one of
them (`art`, 54 images) is most of the work; the bar is honest about the wait
rather than pretending to be a byte counter.

The hold is **1.8 s**, not the three it started at. Startup is about 60 ms,
so the rest is brand, paid on every launch: long enough to read the wordmark
and see half a breath of it, short enough not to be a toll, and still three to
six times the headroom the art job needs on a slow phone.

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

Seven routes, one game. `KiymaCubit` is `@injectable` — **one per screen**,
because a run ends when its page goes away and a closed cubit is no use to the
next screen. What outlives a screen is `Progress`, the `@lazySingleton` they
all read. Progress therefore publishes its own changes to plain callbacks:
buying in the shop, which is pushed over a still-mounted menu, otherwise left
the menu's money chip showing the balance from before the purchase.

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

The run has a **tempo**, 0 to 100, opening at 50. Serving people pushes it
up, burning meat and losing customers pull it down, and it drains while
somebody is waiting — faster the longer since anybody was served. It is worth
half the takings either way (×0.5 at nothing, ×1.5 at full) and, above the
halfway mark only, a wider cooked window and slower patience.

That asymmetry is the whole design. A meter that makes meat burn faster *and*
is pushed down by burnt meat is a spiral: one bad stretch compounds into a run
that cannot be recovered, only sat out. The punishment for a cold counter is
that it pays half. It is also the reputation system of the design doc's
section 9 done properly — that one was persistent, invisible and worth a 13 %
swing.

Two details it took a simulator to find. Gains shrink as the meter fills, or a
counter at full supply parks at 100 for the whole run and the meter is a
constant. And nothing drains while nobody is waiting: without that, day one —
where arrivals are deliberately slow — cooled the player to half takings for a
gap the game chose rather than one they caused.

Mis-moves are counted, not charged: the first two in a row are free, and it
costs more each time after that. A leaning counter under a moving finger
produces drops that are not mistakes, and the red flash already answers those;
three in a row is not a slipping finger.

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
they order and back out the same way when they are done — until they are
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
reads as an overlay where a halo reads as the object asking. The silhouettes
are blurred **once, during the art bootstrap job** (`game/halo.dart`) and the
frame only blits one: doing the mask blur live cost three blurred draws per
lit hint per frame, up to six hints at once, and every one of them is on at
the moment the player has stalled. Three seconds
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

**A touch is classified in `game/gesture.dart`**, not in the Flame callback.
That callback needs a live game loop and a real pointer, so nothing could test
it, and two bugs lived there: a finger held still past 350 ms fell through to
the drop path — which killed the pause button and answered a tap on a tray
with "Olmaz" — and Flame's default `onDragCancel` body *is* `onDragEnd`, so
the notification shade coming down mid-touch ran the whole classification on
wherever the finger was. `classifyTouch` is arithmetic over a start, an end
and the furthest the finger ever got; net displacement alone would read a
drag out and back as a tap.

## Where the rules live

`DayRun` is the whole game: the grill, the two prep stations, the shelves, the
customers, and every rule that moves them. It is plain Dart — no Flame, no
widgets — and it is what the tests drive. `CounterComponent` renders from it
and feeds gestures into it; `KiymaCubit` owns what survives a run.

The split is deliberate about update rates. Patience bars and cooking meters
change every frame and are drawn inside the canvas. The bloc only emits when
money, standing or the phase move — a few times a second at most.

## Measuring the economy

```bash
fvm flutter test test/economy_test.dart
```

`DayRun` has no engine in it, so a whole run plays out in a loop with no
canvas and no clock. `test/support/counter_bot.dart` is a scripted player —
one thing at a time, wraps only — so what it takes is a floor, not a ceiling.
It prints a table on every pass, because that table is how `Balance` gets set:

```
day  plodding  skilled  step
  1       363      346   350
 10       940     2427  1450
```

Day one is one unhurried run. By day ten a good player is worth two and a half
times a plodding one, and that widening is the difficulty curve. It also found
the two bugs above in the tempo meter, and that the old target table was out
by a factor of twelve — a single day-one run cleared the first three days.

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

## The summary

The end-of-run screen follows a Stitch design (`stitch_k_yma_kebab_game_ui`
in the art project) adapted from tablet to a phone held sideways: the card is
capped at 900x306 and centred rather than stretched, because on a wide short
screen the two columns pull apart until the numbers stop reading as one
result. `test/golden/summary_golden_test.dart` renders it at 880x400, which
is the check that it still fits.

One line of the design has no mechanic behind it — a "+25 % tip and fast
service bonus" — so rather than print a number the game does not compute, it
shows the customers who left happy, which it now counts. The ad button is
still not wired to anything; the shape of the screen depends on it being
there.

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
- **A release build reports no crash anywhere.** All three apps implement
  `bootstrap_kit`'s `onCrash` with `developer.log`, which writes to the VM
  service and is compiled out in product mode. Framework errors still print;
  what vanishes is the zone-fatal path — a throw before `runApp`, and every
  `unawaited(context.router…)`. The one-line fix is
  `FlutterError.dumpErrorToConsole` on the fatal branch of `runGuarded`, which
  belongs in the kit so wallet and motto get it too, so it is a separate PR
  against `packages/` rather than app work.
- **The chef and the customers were never drawn.** They are meant to be
  animated, so for now a customer is a coloured silhouette — see the nine
  states above — and the chef is not drawn at all.
- **The numbers are measured, not played.** `test/economy_test.dart` plays
  whole runs with a scripted player and prints what they take; the target
  table and the shop ladder were set from that, and the test asserts the
  shape they have to keep. What it cannot tell us is how any of it *feels* —
  a bot has no hands.
