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

## Where the rules live

`DayRun` is the whole game: the grill, the two prep stations, the shelves, the
customers, and every rule that moves them. It is plain Dart — no Flame, no
widgets — and it is what the tests drive. `CounterComponent` renders from it
and feeds gestures into it; `KiymaCubit` owns what survives a day and the
between-days screens.

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

- **Nothing is saved.** Money, standing, the day number and the unlocks live
  in memory and are gone when the app closes. The design doc's rules about
  saving on every transaction and resuming a half-finished day (11.4, 11.5)
  are not implemented.
- **No shell.** No splash beyond the loading bar, no menu, no settings, no
  language switch in the UI, no ads and no IAP.
- **Placeholder art in two places.** The chef and the customers were never
  drawn — they are meant to be animated — so a customer is a silhouette with
  a real order card. The bin has no asset either and is drawn in code; drop a
  `cop_kovasi.png` into `assets/items` and `_renderTrash` becomes one call.
- **The numbers are the doc's opening suggestions.** Everything in
  `Balance` is marked `[ÖNERİ]` in the design doc and is waiting for
  playtest. The money target table was derived from the income formula, so
  changing the formula means recomputing the table.
