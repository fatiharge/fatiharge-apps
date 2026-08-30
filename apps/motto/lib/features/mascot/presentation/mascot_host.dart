import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:motto/config/app_ready.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/mascot/application/mascot_attention.dart';
import 'package:motto/features/mascot/application/mascot_controller.dart';
import 'package:motto/features/mascot/application/mascot_placement.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';
import 'package:motto/features/mascot/presentation/mascot.dart';
import 'package:rive/rive.dart';

/// Holds the one mascot the app has, above every screen.
///
/// One instance rather than one per page: a state machine per tab is a state
/// machine per tab to keep running, and a mascot that resets when you switch
/// screens is a mascot nobody believes in.
class MascotHost extends StatefulWidget {
  const MascotHost({
    required this.child,
    this.onGameOffered,
    this.loadFile = RiveFile.asset,
    this.controller,
    this.clock,
    super.key,
  });

  final Widget child;
  final VoidCallback? onGameOffered;

  /// Passed through so a test can exercise the drag without a renderer.
  final Future<RiveFile> Function(String) loadFile;

  /// Stands in for the one rive hands over. Without it a test has no
  /// controller at all — the file cannot load here — and the tap path is the
  /// only way to the game, which is how the game came to be unreachable with
  /// every rule around it passing.
  @visibleForTesting
  final MascotController? controller;

  /// The idle clock, so a test can be bored without waiting.
  @visibleForTesting
  final DateTime Function()? clock;

  /// The controller, for a screen that wants it to react — a finished task,
  /// a claimed motto.
  /// How much room a bottom action needs below the mascot. The resting spot
  /// has to leave at least this much, or the mascot lands on the button.
  @visibleForTesting
  static const bottomActionRoom = 120.0;

  static MascotController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MascotScope>()?.controller;

  /// Walks the mascot somewhere by itself. Onboarding uses it to introduce the
  /// app: a mascot that only ever moves when dragged is a decoration.
  static MascotMovement? movementOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MascotScope>()?.movement;

  @override
  State<MascotHost> createState() => _MascotHostState();
}

/// Where the mascot can be sent, in fractions of the area it may occupy.
enum MascotSpot {
  home(Alignment.bottomRight),
  centre(Alignment.center),
  topLeft(Alignment.topLeft),
  topRight(Alignment.topRight),
  bottomLeft(Alignment.bottomLeft);

  const MascotSpot(this.at);

  final Alignment at;
}

/// Moves the mascot on its own, and answers when it has arrived.
typedef MascotMovement =
    Future<void> Function(MascotSpot spot, {Duration over});

class _MascotHostState extends State<MascotHost>
    with SingleTickerProviderStateMixin {
  /// Where it sits when nobody has moved it, measured in from the far edge.
  ///
  /// High enough to clear a button at the bottom of the screen: every screen
  /// here puts its one action there, and a cat on the action is worse than no
  /// cat.

  MascotController? _controller;
  Offset? _position;
  Rect _bounds = Rect.zero;
  late final AnimationController _settle;

  /// Owned here rather than inside the mascot, because the tap that answers
  /// the offer is caught here.
  late final _attention = MascotAttention(clock: widget.clock);
  Timer? _idle;

  /// True only between a pan starting and ending.
  ///
  /// `onPanCancel` fires for an ordinary tap as well — the drag recognizer
  /// losing the arena to the tap — and releasing on that told the mascot
  /// somebody was holding it. Which reset the idle clock microseconds before
  /// the tap it was meant to answer, so the offer was always gone by the time
  /// the tap arrived and the game could not be opened at all.
  bool _dragging = false;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(_followSettle);

    if (widget.controller case final given?) {
      _controller = _TouchAware(given, _attention.touched);
      _startIdleClock();
    }
  }

  @override
  void dispose() {
    _idle?.cancel();
    _settle.dispose();
    super.dispose();
  }

  void _startIdleClock() {
    _idle?.cancel();
    _idle = Timer.periodic(const Duration(seconds: 5), (_) {
      final mascot = _controller;
      if (mascot == null) return;
      // A mascot nobody can see is not being ignored. Without this the offer
      // arms itself behind whatever is covering it, and the first tap after it
      // comes back opens the game instead of poking.
      if (!getIt<MascotStore>().onScreen.value) {
        _attention.touched();
        return;
      }
      switch (_attention.nudge()) {
        case MascotNudge.offer:
          mascot.offerGame();
        case MascotNudge.attention:
          mascot.attention();
        case MascotNudge.none:
          break;
      }
    });
  }

  /// A tap on an offer opens the game; anything else is a poke.
  void _tapped() {
    final mascot = _controller;
    if (mascot == null) return;

    if (_attention.tapAccepts()) {
      widget.onGameOffered?.call();
      return;
    }
    mascot.annoyance = mascot.annoyance + MascotRules.perPoke;
    if (mascot.annoyance >= MascotRules.fleeAt) {
      mascot.flee();
      return;
    }
    mascot.poke();
  }

  void _followSettle() {
    setState(() => _position = Offset.lerp(_from, _to, _settle.value));
  }

  Future<void> goTo(
    MascotSpot spot, {
    Duration over = const Duration(milliseconds: 700),
  }) {
    if (_bounds.isEmpty) return Future.value();

    _from = _resolved(_bounds);
    _to = MascotPlacement.spotIn(spot.at, _bounds);
    _settle
      ..duration = over
      ..value = 0;
    return _settle.forward();
  }

  /// The area the mascot may occupy, inset so it never sits under a notch or
  /// half off the bottom.
  Offset _resolved(Rect bounds) => MascotPlacement.resolved(_position, bounds);

  void _dragTo(Offset delta, Rect bounds) => setState(() {
    _position = MascotPlacement.draggedTo(_resolved(bounds), delta, bounds);
  });

  /// Settles against the nearer side rather than staying wherever it was let
  /// go. Left in the middle it covers what someone is reading; against an edge
  /// it is still reachable and out of the way.
  void _release(Rect bounds) {
    _dragging = false;
    _controller?.drag(held: false);
    final at = _resolved(bounds);

    _from = at;
    _to = MascotPlacement.settledFrom(at, bounds);
    _settle
      ..duration = const Duration(milliseconds: 420)
      ..value = 0;
    unawaited(
      _settle.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 260, damping: 20),
          0,
          1,
          0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);

    return _MascotScope(
      controller: _controller,
      movement: goTo,
      child: LayoutBuilder(
        builder: (context, box) {
          _bounds = MascotPlacement.boundsIn(box.biggest, safe);
          final bounds = _bounds;
          final at = _resolved(bounds);

          // This builder runs once — `MaterialApp.builder` wraps the router,
          // not the page — so the container being empty on that one frame is
          // not something to shrug at: it is the mascot never appearing. The
          // notifier is what brings the build back.
          return ValueListenableBuilder<bool>(
            valueListenable: appReady,
            builder: (context, ready, _) =>
                !ready ? widget.child : _withMascot(context, bounds, at),
          );
        },
      ),
    );
  }

  Widget _withMascot(BuildContext context, Rect bounds, Offset at) {
    // A `Positioned` has to be a direct child of the `Stack`, so the switch is
    // read around the whole thing rather than around the mascot.
    return ValueListenableBuilder<bool>(
      valueListenable: getIt<MascotStore>().onScreen,
      builder: (context, visible, _) => Stack(
        children: [
          widget.child,
          // Off means gone: no widget, no state machine, no timers.
          // Opacity would keep paying for something somebody asked not
          // to have.
          if (visible)
            Positioned(
              left: at.dx,
              top: at.dy,
              child: GestureDetector(
                // Opaque so the whole box catches a drag: the mascot is
                // a round thing on a transparent square, and a pull that
                // only works on the ink mostly does not work.
                behavior: HitTestBehavior.opaque,
                onTap: _tapped,
                onPanStart: (_) {
                  _dragging = true;
                  _attention.touched();
                  _settle.stop();
                  _controller?.drag(held: true);
                },
                onPanUpdate: (details) => _dragTo(details.delta, bounds),
                onPanEnd: (_) => _release(bounds),
                // Only a drag that started has something to settle. A cancel
                // without one is the tap winning the arena, and it is on its
                // way to `onTap`.
                onPanCancel: () {
                  if (_dragging) _release(bounds);
                },
                child: Mascot(
                  size: MascotPlacement.size,
                  loadFile: widget.loadFile,
                  onReady: (mascot) {
                    // Wrapped so a celebration driven from a screen also
                    // counts as somebody paying attention — otherwise the
                    // mascot asks to play while it is being congratulated.
                    setState(
                      () =>
                          _controller = _TouchAware(mascot, _attention.touched),
                    );
                    _startIdleClock();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MascotScope extends InheritedWidget {
  const _MascotScope({
    required this.controller,
    required this.movement,
    required super.child,
  });

  final MascotController? controller;
  final MascotMovement movement;

  @override
  bool updateShouldNotify(_MascotScope old) => controller != old.controller;
}

/// The controller, with the idle clock reset on anything a person did.
class _TouchAware implements MascotController {
  _TouchAware(this._inner, this._touched);

  final MascotController _inner;
  final VoidCallback _touched;

  @override
  double get annoyance => _inner.annoyance;

  @override
  set annoyance(double value) => _inner.annoyance = value;

  @override
  void poke() {
    _touched();
    _inner.poke();
  }

  @override
  void drag({required bool held, double x = 0, double y = 0}) {
    _touched();
    _inner.drag(held: held, x: x, y: y);
  }

  @override
  void celebrate() {
    _touched();
    _inner.celebrate();
  }

  @override
  void flee() => _inner.flee();

  @override
  void attention() => _inner.attention();

  @override
  void offerGame() => _inner.offerGame();
}
