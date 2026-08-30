import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/features/chain/domain/chain.dart';

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

  /// Takes one. False when there was none to take.
  ///
  /// Spent before the game rather than when a score arrives: a turn taken at
  /// the end is a turn somebody keeps by closing the app on a bad round.
  Future<bool> spend() async {
    try {
      await _turns.spendGameTurn(today: isoDay(now()));
      return true;
    } on api.ApiException catch (refused) {
      if (refused.code == 409) return false;
      rethrow;
    }
  }
}
