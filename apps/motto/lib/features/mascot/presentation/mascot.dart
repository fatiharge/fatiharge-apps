import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:motto/features/mascot/application/mascot_attention.dart';
import 'package:motto/features/mascot/application/mascot_controller.dart';
import 'package:motto/features/mascot/application/rive_mascot_controller.dart';
import 'package:rive/rive.dart';

/// The mascot, and everything it does on its own.
///
/// Kept in its own [RepaintBoundary] and given its own ticker: it animates
/// constantly, and without the boundary every frame of it would repaint the
/// screen behind it.
class Mascot extends StatefulWidget {
  const Mascot({
    this.size = 140,
    this.onGameOffered,
    this.onReady,
    this.followsFinger = true,
    this.loadFile = RiveFile.asset,
    super.key,
  });

  static const asset = 'assets/mascot/mascot.riv';
  static const machine = 'Mascot';

  final double size;

  /// Called when someone accepts the question-mark bubble.
  final VoidCallback? onGameOffered;

  /// Hands the controller out so a screen can celebrate a finished task.
  final void Function(MascotController)? onReady;

  /// Whether a pull moves it. False when something above it does the moving —
  /// the host drags it across the whole screen, and two things fighting over
  /// one gesture is a mascot that jitters.
  final bool followsFinger;

  /// A seam, because rive's renderer needs a native library that a unit test
  /// does not have — and "the file would not load" is exactly the case worth
  /// proving does not break a screen.
  final Future<RiveFile> Function(String) loadFile;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  RiveMascotController? _mascot;
  Artboard? _artboard;

  Timer? _idle;
  Timer? _decay;
  final _attention = MascotAttention();

  /// How far the finger has pulled it from where it sits. The file has a
  /// "held" pose but no idea where the hand is; moving it is the app's job.
  Offset _pulled = Offset.zero;
  late final AnimationController _spring;
  Offset _releasedFrom = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Built here rather than lazily: a controller first touched in dispose()
    // asks for a ticker from a widget that is already deactivated.
    _spring = AnimationController.unbounded(vsync: this)
      ..addListener(_followSpring);
    unawaited(_load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idle?.cancel();
    _decay?.cancel();
    _spring.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A state machine running while the app is backgrounded is a frame budget
    // spent on a screen nobody is looking at.
    if (state == AppLifecycleState.resumed) {
      _mascot?.resume();
      _startTimers();
    } else {
      _mascot?.pause();
      _idle?.cancel();
      _decay?.cancel();
    }
  }

  Future<void> _load() async {
    final Artboard artboard;
    final RiveMascotController mascot;

    // Everything that can go wrong with the file is in here, including reading
    // its inputs: a mascot that cannot be drawn is a mascot that is not there,
    // and no screen depends on it enough to go down with it.
    try {
      final file = await widget.loadFile(Mascot.asset);
      // An instance, not the file's own artboard: the shared one is not
      // advanced by the widget, which draws the first frame and then nothing —
      // a mascot that is there and never moves.
      artboard = file.mainArtboard.instance();

      final machine = StateMachineController.fromArtboard(
        artboard,
        Mascot.machine,
      );
      if (machine == null) {
        throw StateError('mascot.riv has no "${Mascot.machine}" machine');
      }
      artboard.addController(machine);
      mascot = RiveMascotController(machine);
    } on Object catch (broken, trace) {
      // Reported rather than swallowed: silence here is a mascot that quietly
      // stops existing on some devices and nowhere else.
      FlutterError.reportError(
        FlutterErrorDetails(exception: broken, stack: trace, library: 'mascot'),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _artboard = artboard;
      _mascot = mascot;
    });
    // Wrapped, so that a drag driven from outside still counts as somebody
    // paying attention — otherwise the mascot asks for it while being held.
    widget.onReady?.call(_TouchAware(mascot, _touched));
    _startTimers();
  }

  void _startTimers() {
    _idle?.cancel();
    _decay?.cancel();

    _decay = Timer.periodic(const Duration(seconds: 1), (_) => _calmDown());

    // Hosted, the host runs the idle clock: it is the one that owns the tap,
    // and being bored only means something if a tap can answer it.
    if (!widget.followsFinger) return;
    _idle = Timer.periodic(const Duration(seconds: 5), (_) => _whenIdle());
  }

  void _whenIdle() {
    final mascot = _mascot;
    if (mascot == null) return;

    switch (_attention.nudge()) {
      case MascotNudge.offer:
        mascot.offerGame();
      case MascotNudge.attention:
        mascot.attention();
      case MascotNudge.none:
        break;
    }
  }

  void _calmDown() {
    final mascot = _mascot;
    if (mascot == null || mascot.annoyance == 0) return;
    mascot.annoyance = MascotRules.decayed(
      mascot.annoyance,
      const Duration(seconds: 1),
    );
  }

  void _followSpring() {
    setState(() => _pulled = _releasedFrom * _spring.value);
  }

  /// Let go and it snaps back, overshooting once. A linear return reads as a
  /// UI element sliding home; this reads as something with weight.
  void _release() {
    _mascot?.drag(held: false);
    _releasedFrom = _pulled;
    _spring.value = 1;
    unawaited(
      _spring.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 340, damping: 18),
          1,
          0,
          0,
        ),
      ),
    );
  }

  void _touched() => _attention.touched();

  void _onTap() {
    final mascot = _mascot;
    if (mascot == null) return;

    // An accepted offer opens the game; a poke on top of an offer is not one.
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

  @override
  Widget build(BuildContext context) {
    final artboard = _artboard;
    if (artboard == null) return SizedBox.square(dimension: widget.size);

    final drawn = RepaintBoundary(
      child: Transform.translate(
        offset: _pulled,
        child: SizedBox.square(
          dimension: widget.size,
          child: Rive(artboard: artboard),
        ),
      ),
    );

    if (!widget.followsFinger) {
      // No pan recogniser at all. The host has one, and the inner detector is
      // closer to the touch — declaring a pan here won the arena and the
      // host's drag never fired, which looked like a mascot that does not
      // move. Taps still work: a pan only claims the gesture once the finger
      // travels.
      // Hosted: the host owns every gesture. Two detectors, one inside the
      // other, put a tap and a drag in the same arena and the outer one won —
      // which is why poking the mascot did nothing at all.
      return drawn;
    }

    return GestureDetector(
      onTap: _onTap,
      onPanStart: (_) {
        _touched();
        _spring.stop();
        _mascot?.drag(held: true);
      },
      onPanUpdate: (details) {
        setState(() => _pulled = MascotRules.pulledTo(_pulled, details.delta));
        _mascot?.drag(held: true, x: _pulled.dx, y: _pulled.dy);
      },
      onPanEnd: (_) => _release(),
      onPanCancel: _release,
      child: drawn,
    );
  }
}

/// Everything anyone outside asks of the mascot, with the idle clock reset.
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
  void flee() => _inner.flee();

  @override
  void attention() => _inner.attention();

  @override
  void offerGame() => _inner.offerGame();

  @override
  void celebrate() {
    _touched();
    _inner.celebrate();
  }
}
