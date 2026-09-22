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

## Launching

The window is cream from the moment the process starts — `colors.xml` holds
the brand ground and both launch backgrounds and both themes point at it — so
there is no flash of white or black before the first Flutter frame, which is
itself the cream brand screen. The icon is a skewer and a flame, generated
with the rest of the art and written into every Android density, both maskable
web sizes and all fifteen iOS slots.

## What survives

`infrastructure/progress_store.dart` writes the till, the day and the shop to
`SharedPreferences` on every change — `Progress` already announces them, and a
game that is killed mid-run should lose the run, never the shop. Restoring is
a bootstrap job of its own under the `skip` policy: a save that will not read
is not a reason to refuse to play, and an unreadable one is deleted rather
than guessed at, because it will not read on the next launch either. The
payload carries a version and an older shape is dropped.

Nothing survived a cold start before this, and the arithmetic says how much
that mattered: forty-seven rungs run to about three billion gold, and day one
takes twenty.

## The frame

No phone is 16:9 and the kitchen was measured in one 1024x576 space, so there
is always a margin. It used to be black — the loudest way software can say
nobody finished it.

The camera is no longer `withFixedResolution`, which clips to a 16:9 window
and leaves the rest to the background colour. It is a plain `CameraComponent`
at the same zoom, so not a pixel inside the design box moves, and the margin
is painted: `presentation/render/backdrop.dart` fills it with the scene
painting blurred small at startup, knocked down, vignetted, with a rule and an
outward shadow around the box so it reads as a lit stage in a dark room.

The box is fitted to the **safe** rectangle, not the screen: the notch, the
camera cutout and the gesture bar are measured out of it, with a 20-unit floor
per side for rounded corners, and it is centred in what is left — so a cutout
on one side does not push the counter under it. `CounterComponent.render`
clips to the box, because unclipping the camera made customers visible while
they were still walking in from off-stage.

The system bars are hidden in `MainActivity.kt` rather than from Dart:
`setEnabledSystemUIMode(immersiveSticky)` stopped hiding anything at
targetSdk 36. Dart now says `edgeToEdge`, which is what actually happens.

`test/golden/frame_golden_test.dart` renders the counter on a wide screen
with a cutout and on a squarer one, which is what stops a letterbox shipping
past a green suite again.

## One coordinate space

Every position in the game — the painted layers, all 31 regions, the recipe
offsets — was measured in one **1024×576** space. `KiymaGame` sets one camera
zoom from the safe rectangle and nothing below it ever asks how big the phone
is.

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

The five jobs are `display`, `dependencies`, `kayit`, `scene`, `art`, in that
order; `dependencies`, `scene` and `art` are under the `restart` policy. There
is no reduced game to fall back to, and a scene file that will not parse is not
something a retry fixes. They are separate jobs rather than one so a failure
names the step.

`art` does more than load. All five together take about 60 ms and the brand
screen is held for three seconds, so the window is free, and two things that
would otherwise land on the first frame of a day are done in it: the hint
glows are blurred once (`render/halo.dart`), and every image is drawn once
offscreen to force its texture upload. Decoding happens when the file is
read; the upload does not, and without this it arrives all at once — 61
images, about 50 MB decoded, including two backgrounds over 2000 px wide — on
the frame the counter first appears.

The splash bar shows the **lower** of the two things the screen is waiting on
— how far the jobs have got, and how much of the three-second brand hold has
passed. Everything loads in under 100 ms, so taking the higher of the two
filled the bar in the first few frames and then left it sitting at 100 % for
most of the time it was on screen. Five jobs is also five steps, and one of
them (`art`, 61 images) is most of the work; the bar is honest about the wait
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
                                              ├─ Upgrade ─ Shop ─ List  ↓ time up
                                              └─ Notebook    Summary ─ new run / menu
```

Nine routes, one game. The shop is two of them: the room, where a rung is
bought by touching the object it would change, and a list for the fourteen
rungs that have no object to point at. The notebook is where a rule the usta
explained once can be read again. `KiymaCubit` is `@injectable` — **one per
screen**, because a run ends when its page goes away and a closed cubit is no
use to the next screen. What outlives a screen is `Progress`, the
`@lazySingleton` they all read. Progress therefore publishes its own changes
to plain callbacks:
buying in the shop, which is pushed over a still-mounted menu, otherwise left
the menu's money chip showing the balance from before the purchase.

A run is a **clock**: `60s + day * 6s`, with customers arriving as seats
free until it stops. What it pays feeds **XP**, and XP is what turns the day
over — the two are the same number underneath and are never shown together,
so progress reads as levelling rather than as a bank balance. The counter
shows the till, in the coin bag, and never the level: under the bag is a
hairline of how far the day has come toward its target, which is the same
reading without the number.

Ingredients go on **before or after the meat**, on both lines. Requiring the
meat first made the grill a lock on everything else: with nothing to do but
wait for a skewer, six seconds of cooking were six seconds of standing still.
What has to come first still does — bread starts a wrap, bread starts a plate
— and meat is still what makes either one servable.

Each line carries **four** ingredients, not five. A fifth is more than an
order card shows well and more than a player scans mid-rush; parsley came off
the wrap and aubergine off the plate, and the two wells they left are empty
steel.

**The counter has almost no HUD.** Nearly everything it says is said by an
object in the room: the time by the clock on the wall, the day by the calendar
hung beside it, the tempo by a segmented gauge on the wall over the grill it
measures, and the money by a bag of coins under the clock. What is left is the
pause key. A floating plate is the single loudest thing on a screen that is
otherwise a painted kitchen, and it read as an app drawn on top of a game. The
cost is that the numbers take a fraction longer to find; what is bought is that
the scene is the whole screen.

The run has a **tempo**, 0 to 100, opening at 50. Serving people pushes it
up, burning meat and losing customers pull it down, and it drains while
somebody is waiting — faster the longer since anybody was served. It swings
the takings by more than half either way (×0.4 at nothing, ×1.6 at full)
and, above the halfway mark only, a wider cooked window and slower patience.

That asymmetry is the whole design. A meter that makes meat burn faster *and*
is pushed down by burnt meat is a spiral: one bad stretch compounds into a run
that cannot be recovered, only sat out. The punishment for a cold counter is
that it pays half. It is also the reputation system of the design doc's
section 9 done properly — that one was persistent, invisible and worth a 13 %
swing.

Its stage is a **glyph on a badge**, not a word — read faster and needing no
translation — and at the top of the meter a band of light sweeps the plate. A
push the meter has no room left to take is **paid out as gold** instead, so a
strong run does not go quiet at the ceiling.

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

**The clock and the calendar are furniture, not HUD.** The countdown drains
round the bezel of a round clock hung on the tiled wall, and the day number
sits on a calendar nailed up beside the grill. Both are `dekor` regions —
they scale and lean with the scene, and nothing can be dropped on them. The
calendar's case is art with its day number drawn over it; the clock is
circles, an arc and twelve ticks, all code. The one control that is not a
kitchen object is the pause key, and it is in the bottom right corner past the
end of the counter, where no drag ever goes. The gauge has the top left, the
clock and the coin bag the top right.

**Three** customers at most, and each one **walks in from the right** before
they order and back out the same way when they are done — until they are
standing at the counter there is no card, no patience and nothing that can be
handed to them, and the seat frees the moment they turn to go. Everyone walks
at their own speed, somewhere between the quickest and 40 % of it, so a queue
does not move as one body. Their order sits to the right of their head and
their patience runs up a bar on the left, so neither has to be found inside
the other. A fourth place did not fit that layout on the same stretch of
counter.

A customer's whole visit is **one nine-value state**: walking, five degrees
of waiting from calm to angry, and three ways of leaving — served in full, in
part, or not at all. It drives the pose and the flush together, because the
two say the same thing at different distances — the body reads across the
screen, the colour reads up close. The figure itself is geometry, not a
picture: `render/figure.dart` deforms flattened point lists every frame,
because a finished drawing cannot be squashed or leaned and that is the whole
language here. Fourteen of them, each with its own head and garment, coloured
per customer off a seed, so three people at the counter are three people.

Customers pay in **gold, onto the ledge they stood at**, in one of three
random piles, and it only reaches the till when the player touches it. After
ten seconds the counter sweeps it up on its own and keeps 70 % — what a touch
buys is the tip, not the sale, and the tag goes red for the last three
seconds. The counter also points at a step being skipped: the thing that unblocks it
breathes inside an orange halo of **its own silhouette**, not of its region
box — a region is a hit target, and a lit rectangle around a tray of parsley
reads as an overlay where a halo reads as the object asking. The silhouettes
are blurred **once, during the art bootstrap job** (`render/halo.dart`) and the
frame only blits one: doing the mask blur live cost three blurred draws per
lit hint per frame, up to six hints at once, and every one of them is on at
the moment the player has stalled. Three seconds
with an empty grill and the mince tray asks, four with an empty wrap station
and the bread does, five with a burnt skewer on the grill and the bin does,
and reaching for a rolled wrap with no paper on it makes the paper answer for
two and a half. A gold pile flashes the same way for its last three seconds.
None of it changes a rule. The pause button stops everything — asked for, so not the free breather that
walking out would have been. In a debug build, holding the menu's language
button for three seconds grants 1000 gold; XP is untouched, so the level stays
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

**A touch is classified in `domain/gesture.dart`**, not in the Flame callback.
That callback needs a live game loop and a real pointer, so nothing could test
it, and two bugs lived there: a finger held still past 350 ms fell through to
the drop path — which killed the pause button and answered a tap on a tray
with "Olmaz" — and Flame's default `onDragCancel` body *is* `onDragEnd`, so
the notification shade coming down mid-touch ran the whole classification on
wherever the finger was. `classifyTouch` is arithmetic over a start, an end
and the furthest the finger ever got; net displacement alone would read a
drag out and back as a tap.

**The usta teaches on the counter, not on a card.** A lesson
(`domain/tutor.dart`) is a list of steps, and a step is a milestone the run
announces plus the region to point at until it happens — so the run waits for
the thing to be done rather than for a sentence to be read, which a card
between days cannot do. Four are written (the first wrap, the two instruments
on the wall, what a walkout costs, the plate line) and two are generated: the
drinks lesson from whichever jug the player actually owns, and one line per
purchase out of the sentence the shop already prints. The teacher watches for
milestones rather than reading the run, or every lesson would be coupled to
every rule. The bubble goes to whichever corner covers least of what matters
— a tutorial that covers what it is pointing at is worse than none — and
every lesson can be walked out of once.

**No two days are the same day.** `domain/trade_shape.dart` gives every day
after the first a fixed run of rushes and lulls instead of a flat arrival rate
— a metronome leaves the counter either always ahead of it or always behind,
and the lull is the part that matters because it is where a player catches up.
From day four `domain/day_rule.dart` names one of seven things that is
different: an inspection forgives nothing and pays half again, a cool grill
takes a slot and widens the window, a wraps-only day closes the plate line, a
race day trades two thirds of the patience for half again the pay. Every field
of a rule is neutral by default and `yok` is the identity, so the run
multiplies unconditionally and never learns a single rule's name. Both are
fixed per day rather than drawn, which is what lets the day card promise them.

**The bin is two corners of the screen**, not an object in the room. A
painted bin has to stand somewhere and the only free floor was in front of
the grill, which put it behind the grill in depth and half a counter from the
shelf. The corners open only while something binnable is in hand — a finished
wrap, a finished plate, a burnt skewer, and nothing else, because a handful of
onion goes back to its tray on its own — so they cost no space the rest of the
time, and they are measured against what is actually on screen rather than
against the design box.

## The order ticket

Paper, not a phone panel — cream with a torn bottom edge, a hard shadow and a
per-seat tilt so three of them read as three dockets rather than one sprite
repeated. It moved out of the drag path into the empty band above the heads,
where the hand never goes, and grew from 88x74 to 148x78.

Three fixed bands, always in the same place: a coloured header carrying the
product and what the whole order is still worth; a rail of **always four**
wells in enum order — wanted is a green plaque, forbidden is red and crossed,
and an unmentioned one is an empty outline carrying the bonus it would pay,
which is the one economy rule a player had no way of discovering; then two
fixed sockets, dessert always left and drink always right, printed empty when
there is none. A shuffled row of two or three icons cannot be scanned under
time pressure; four in a fixed order can.

It drops in and settles when its customer arrives, reddens and jitters below
30 % patience, and shakes with the wrong wells lit when an order is refused —
`Order.ihlal` names them, because "the game said no" and "you forgot the
pepper" are different sentences and only one teaches anything.

**Five kinds of customer on top of the ordinary one**, each carrying the day
it first becomes possible and its weight against the others
(`model/customer_kind.dart`). Hurried gives less time and pays more; fussy
names two things they will not have; generous tips if the bar is still high
when it lands; indecisive swaps one wanted ingredient for another once,
halfway through waiting; and from day seven, once the plate line is open, one
of them puts **two products on one ticket** — held back until then because
two wraps is the same job twice where a wrap and a plate is a different job.
They change how a visit *plays* rather than what the counter has to make,
which is why they need nothing but the ticket.

## Effects

`presentation/render/effects.dart` is the pool. There was nowhere to put an
effect before it: one `render` of a dozen fixed passes, no tween, no
particle, no seam to shake. An effect is age, life and a draw call — no
Flame, no widgets — so it tests without a canvas, and everything is spawned
by the renderer rather than by the rules, which stay engine-free and let the
headless simulator keep running at full speed.

The rules say *where* now, not just *what*: `Cue` carries a place, an amount
and an asset beside its `DayEvent`, so a reward bursts under the finger that
earned it instead of on the plate in the corner. The renderer drains the
queue each frame.

Two seams sit beside the pool. `_freeze` slows the world for a few frames on
a hit while the pulses keep breathing, which is what makes a serve land.
`_shake` knocks the room — inside a save/restore that the instrument sits
outside of, because a HUD that shakes with the scene reads as a broken screen
rather than as an impact.

The room itself is lit rather than blitted: a vignette pulling the eye in, an
ember pool that breathes and burns hotter the fuller the grill is, the whole
kitchen taking the colour of the tempo, and the last twenty seconds closing in
red.

## Where the rules live

`DayRun` is the whole game: the grill, the two prep stations, the shelves, the
customers, and every rule that moves them. It is plain Dart — no Flame, no
widgets — and it is what the tests drive. `CounterComponent` renders from it
and feeds gestures into it; `KiymaCubit` owns what survives a run.

The split is deliberate about update rates. Patience bars and cooking meters
change every frame and are drawn inside the canvas. The bloc only emits when
money, standing or the phase move — a few times a second at most.

## The day card

Its job is to say what is different about today. Five numbers move with the
day — the clock, how often people arrive, how long meat survives, how long
anybody waits, and what everything pays — and until this card listed them the
whole ramp was invisible: the game tightened five screws a day and never said
so. Each row carries the change since yesterday, green or red, and a dial that
has hit its floor stops showing one.

Above the dials: chips naming the shape of today's trade and, from day four,
today's rule. Under them: a sentence saying what that rule does, and how many
happy customers the day is asking for. Beside it: the cheapest thing the till
can already cover, named on its own button, because this is the only moment
the player can act on it — the shop is one tap away and the run has not
started. And one of six tips, turning over with the day rather than at random
so it is stable within a day.

**No currency symbol anywhere.** The game pays in gold, and `₺` was a leftover
from before that decision — it also came out as an empty box, because Rubik
has no lira glyph.

**The day asks for a number of happy customers**, printed on the card and
paid as a share of the day's own level step when it is met — a share rather
than a figure, so it keeps its worth forever without a second table to
maintain. It saturates instead of climbing: a fully bought counter tops out
near nine customers a minute whoever is holding the phone, because the grill
and the three places are the ceiling and not the hands, so a goal that kept
climbing would stop being a goal and start being a wall.

## The summary

It arrives in beats rather than all at once — banner, card, takings counting
up, stars, level bar, then the buttons — because the order the numbers land in
is the telling. A screen that appears complete has nothing to say about how
the run went.

**Stars** are three, and the criterion is the target table's own meaning: a
day cleared in one run is three. **Badges** are eight and the card shows
four — derived from the finished run rather than awarded during it, so
nothing has to be remembered mid-run and the summary is the only place that
knows they exist. The first three are exclusive on purpose: a flawless day
used to earn all three, which made two of them decoration on the one that
mattered. **The peak tempo** is reported as its band,
because a meter that only went down would be a poor thing to end on. **The
primary button breathes** and never settles; a button that blinks on and off
reads as an error.

That breathing is why `summary_golden_test.dart` cannot use `pumpAndSettle` —
it never returns — and pumps in fixed steps instead, the same trap the Flame
tests have.

## Measuring the economy

```bash
fvm flutter test test/economy_test.dart
```

`DayRun` has no engine in it, so a whole run plays out in a loop with no
canvas and no clock. `test/support/counter_bot.dart` is a scripted player —
one decision a tick and no planning past the neediest customer, but it works
every line there is — so what it takes is a floor, not a ceiling.
It prints a table on every pass, because that table is how `Balance` gets set:

```
day  plodding  skilled  step  runs
  1        20       23           18   0.90
 10      6447     7194         9720   1.51
```

Day one is one unhurried run, and the numbers **run away**: the day
multiplier compounds at 1.62 rather than adding 8 %, so a plodding player
takes 20 on day one, 87 on day three, 298 on day five and 6,447 on day ten,
while a good one takes 7,194. The last column is how many runs a day's step
is worth at the plodding rate. The old curve added 8 % a day with the level
targets fitted to cancel it out — a treadmill by construction, where day ten
paid 2.6× day one and nothing ever felt like progress. The bases came down to
1 and 2 to make room for it, so the first sale is worth 2 gold and watching
that become four figures is the progression.

The shop ladder compounds with the income: forty-seven rungs from fourteen
gold to eight hundred and thirty million, one or two a day across the thirty,
and each heavy day carries exactly one.

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

Thirteen goldens, 14 MB: the counter open and on day one, the frame on two
screen shapes, the customers, the usta standing and acting, a lesson, the
shop, the day card, the summary, a skewer and the refusals. Placement is
arithmetic on measured quads and a wrong sign is invisible to every rule
test, which is what they are worth their size for. They are excluded from
CI: the baseline is rendered by the host, and macOS does not match Linux.

## Not built yet

Stages 6 to 8 of the plan. Named so nobody has to rediscover them:

- **No settings screen beyond the language.**
- **No ads and no IAP.** The summary's x2 offer is drawn and dead.
- **A release build reports no crash anywhere.** All three apps implement
  `bootstrap_kit`'s `onCrash` with `developer.log`, which writes to the VM
  service and is compiled out in product mode. Framework errors still print;
  what vanishes is the zone-fatal path — a throw before `runApp`, and every
  `unawaited(context.router…)`. The one-line fix is
  `FlutterError.dumpErrorToConsole` on the fatal branch of `runGuarded`, which
  belongs in the kit so wallet and motto get it too, so it is a separate PR
  against `packages/` rather than app work.
- **No sound at all.** There is no audio package in `pubspec.yaml` and not one
  sound file in `assets/` — sixty-one images, one font and three JSON files is
  the whole of it. Every cue the game has — the flash, the freeze, the shake,
  the halo — is visual because that is all there is.
- **The numbers are measured, not played.** `test/economy_test.dart` plays
  whole runs with a scripted player and prints what they take; the target
  table and the shop ladder were set from that, and the test asserts the
  shape they have to keep. What it cannot tell us is how any of it *feels* —
  a bot has no hands.
