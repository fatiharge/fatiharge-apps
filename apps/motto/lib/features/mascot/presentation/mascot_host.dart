import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/mascot/application/mascot_controller.dart';
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
    super.key,
  });

  final Widget child;
  final VoidCallback? onGameOffered;

  /// Passed through so a test can exercise the drag without a renderer.
  final Future<RiveFile> Function(String) loadFile;

  /// The controller, for a screen that wants it to react — a finished task,
  /// a claimed motto.
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
  static const _size = 96.0;

  /// Where it sits when nobody has moved it: bottom right, above the bar.
  static const _home = Offset(-24, -140);

  MascotController? _controller;
  Offset? _position;
  Rect _bounds = Rect.zero;
  late final AnimationController _settle;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(_followSettle);
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _followSettle() {
    setState(() => _position = Offset.lerp(_from, _to, _settle.value));
  }

  Future<void> goTo(
    MascotSpot spot, {
    Duration over = const Duration(milliseconds: 700),
  }) {
    if (_bounds.isEmpty) return Future.value();

    final alignment = spot.at;
    _from = _resolved(_bounds);
    _to = Offset(
      _bounds.left + (alignment.x + 1) / 2 * _bounds.width,
      _bounds.top + (alignment.y + 1) / 2 * _bounds.height,
    );
    _settle
      ..duration = over
      ..value = 0;
    return _settle.forward();
  }

  /// The area the mascot may occupy, inset so it never sits under a notch or
  /// half off the bottom.
  Rect _boundsIn(BoxConstraints box, EdgeInsets safe) => Rect.fromLTRB(
    safe.left + 8,
    safe.top + 8,
    box.maxWidth - safe.right - _size - 8,
    box.maxHeight - safe.bottom - _size - 8,
  );

  Offset _resolved(Rect bounds) {
    final at = _position;
    if (at != null) return at;
    // Negative home coordinates are read from the far edge, so the resting
    // corner survives a rotation without being recomputed anywhere.
    return Offset(
      _home.dx < 0 ? bounds.right + _home.dx + 24 : _home.dx,
      _home.dy < 0 ? bounds.bottom + _home.dy + 140 : _home.dy,
    );
  }

  void _dragTo(Offset delta, Rect bounds) {
    final at = _resolved(bounds) + delta;
    setState(() {
      _position = Offset(
        at.dx.clamp(bounds.left, bounds.right),
        at.dy.clamp(bounds.top, bounds.bottom),
      );
    });
  }

  /// Settles against the nearer side rather than staying wherever it was let
  /// go. Left in the middle it covers what someone is reading; against an edge
  /// it is still reachable and out of the way.
  void _release(Rect bounds) {
    _controller?.drag(held: false);
    final at = _resolved(bounds);
    final left = (at.dx - bounds.left).abs();
    final right = (bounds.right - at.dx).abs();

    _from = at;
    _to = Offset(left < right ? bounds.left : bounds.right, at.dy);
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
          _bounds = _boundsIn(box, safe);
          final bounds = _bounds;
          final at = _resolved(bounds);

          // The host wraps every route, including the one that builds the
          // container — so on the first frame there is nothing to ask. No
          // mascot on the splash is the right answer anyway, and the builder
          // runs again when bootstrap replaces the route.
          final store = getIt.isRegistered<MascotStore>()
              ? getIt<MascotStore>()
              : null;
          if (store == null) return widget.child;

          // A `Positioned` has to be a direct child of the `Stack`, so the
          // switch is read around the whole thing rather than around the
          // mascot.
          return ValueListenableBuilder<bool>(
            valueListenable: store.onScreen,
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
                      onPanStart: (_) {
                        _settle.stop();
                        _controller?.drag(held: true);
                      },
                      onPanUpdate: (details) => _dragTo(details.delta, bounds),
                      onPanEnd: (_) => _release(bounds),
                      onPanCancel: () => _release(bounds),
                      child: Mascot(
                        size: _size,
                        followsFinger: false,
                        loadFile: widget.loadFile,
                        onGameOffered: widget.onGameOffered,
                        onReady: (mascot) =>
                            setState(() => _controller = mascot),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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
