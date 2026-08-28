import 'package:flutter/widgets.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/features/mascot/application/mascot_store.dart';

/// Keeps the mascot off the screen it wraps.
///
/// The mascot floats over everything and settles bottom right, which is where
/// the answer buttons are. On a screen whose whole job is one action, a cat
/// sitting on that action is worse than no cat.
class MascotFreeZone extends StatefulWidget {
  const MascotFreeZone({required this.child, super.key});

  final Widget child;

  @override
  State<MascotFreeZone> createState() => _MascotFreeZoneState();
}

class _MascotFreeZoneState extends State<MascotFreeZone> {
  MascotStore? _store;

  @override
  void initState() {
    super.initState();
    // The container may not exist yet on the first frame; the mascot is not
    // there either in that case.
    _store = getIt.isRegistered<MascotStore>() ? getIt<MascotStore>() : null;
    _store?.suppress();
  }

  @override
  void dispose() {
    _store?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
