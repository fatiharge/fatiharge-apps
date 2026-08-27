import 'package:motto/features/mascot/application/mascot_controller.dart';
import 'package:rive/rive.dart';

/// The mascot, driven by the state machine inside `mascot.riv`.
///
/// Dart only sets inputs: which timeline plays, and how it blends into the
/// next, is the file's business. That is the whole reason this is Rive — the
/// alternative pushes a value per frame from here.
class RiveMascotController implements MascotController {
  RiveMascotController(this._machine)
    : _poke = _machine.requireInput<SMITrigger>('poke'),
      _annoyance = _machine.requireInput<SMINumber>('annoyance'),
      _drag = _machine.requireInput<SMIBool>('drag'),
      _dragX = _machine.requireInput<SMINumber>('dragX'),
      _dragY = _machine.requireInput<SMINumber>('dragY'),
      _flee = _machine.requireInput<SMITrigger>('flee'),
      _attention = _machine.requireInput<SMITrigger>('attention'),
      _offerGame = _machine.requireInput<SMITrigger>('offerGame'),
      _celebrate = _machine.requireInput<SMITrigger>('celebrate');

  final StateMachineController _machine;

  final SMITrigger _poke;
  final SMINumber _annoyance;
  final SMIBool _drag;
  final SMINumber _dragX;
  final SMINumber _dragY;
  final SMITrigger _flee;
  final SMITrigger _attention;
  final SMITrigger _offerGame;
  final SMITrigger _celebrate;

  @override
  void poke() => _poke.fire();

  @override
  double get annoyance => _annoyance.value;

  @override
  set annoyance(double value) => _annoyance.value = value.clamp(0, 100);

  @override
  void drag({required bool held, double x = 0, double y = 0}) {
    _drag.value = held;
    _dragX.value = x.clamp(-100, 100);
    _dragY.value = y.clamp(-100, 100);
  }

  @override
  void flee() => _flee.fire();

  @override
  void attention() => _attention.fire();

  @override
  void offerGame() => _offerGame.fire();

  @override
  void celebrate() => _celebrate.fire();

  /// Stops the machine while the mascot is off screen. A state machine that
  /// keeps running behind another route is a frame budget spent on nothing.
  void pause() => _machine.isActive = false;

  void resume() => _machine.isActive = true;
}

extension MascotInputs on StateMachineController {
  /// The inputs are part of the contract with whoever made the file; a missing
  /// one is a broken asset, not a runtime condition to handle. Rive's own
  /// `findSMI` answers null and would leave that to be discovered on the first
  /// tap.
  T requireInput<T extends SMIInput<dynamic>>(String name) {
    final input = findInput<dynamic>(name);
    if (input is! T) {
      throw StateError('mascot.riv has no $T named "$name"');
    }
    return input;
  }
}
