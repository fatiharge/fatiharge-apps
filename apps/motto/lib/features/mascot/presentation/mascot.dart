import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motto/features/mascot/application/mascot_controller.dart';
import 'package:motto/features/mascot/application/rive_mascot_controller.dart';
import 'package:rive/rive.dart';

/// Draws the mascot and hands out its controller.
///
/// Nothing else: the gestures, where it sits and when it gets bored all
/// belong to the host, which is above the router and can see the whole
/// screen. Kept in its own [RepaintBoundary] because it animates constantly.
class Mascot extends StatefulWidget {
  const Mascot({
    this.size = 140,
    this.onReady,
    this.loadFile = RiveFile.asset,
    super.key,
  });

  static const asset = 'assets/mascot/mascot.riv';
  static const machine = 'Mascot';

  final double size;

  /// Hands the controller out so a screen can celebrate a finished task.
  final void Function(MascotController)? onReady;

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

  Timer? _decay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _decay?.cancel();
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
    widget.onReady?.call(mascot);
    _startTimers();
  }

  void _startTimers() {
    _decay?.cancel();
    _decay = Timer.periodic(const Duration(seconds: 1), (_) => _calmDown());
  }

  void _calmDown() {
    final mascot = _mascot;
    if (mascot == null || mascot.annoyance == 0) return;
    mascot.annoyance = MascotRules.decayed(
      mascot.annoyance,
      const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artboard = _artboard;
    if (artboard == null) return SizedBox.square(dimension: widget.size);

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: Rive(artboard: artboard),
      ),
    );
  }
}
