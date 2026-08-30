import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/features/chain/domain/chain.dart';
import 'package:motto/infrastructure/api/outcome.dart';

/// Turns at the game, which the server counts.
///
/// Not on the phone: the device identifier survives a reinstall and
/// preferences do not, so turns kept here would be turns anybody can mint by
/// clearing the app's data — and what they would be minting is chances at the
/// week's deep report.
@lazySingleton
class TurnsRepository {
  TurnsRepository(this._turns);

  final api.PlayResourceApi _turns;

  @visibleForTesting
  DateTime Function() now = DateTime.now;

  Future<api.PlayCredits?> today() => _turns.gameTurns(today: isoDay(now()));

  /// Takes one.
  ///
  /// Spent before the game rather than when a score arrives: a turn taken at
  /// the end is a turn somebody keeps by closing the app on a bad round.
  ///
  /// The refusal comes back named — `no_turns_yet` when the day still has one
  /// to earn, `no_turns_today` when it does not. The app no longer works that
  /// out from flags; it was getting it wrong.
  Future<Outcome<api.PlayCredits?>> spend() =>
      asked('turns', () => _turns.spendGameTurn(today: isoDay(now())));
}
