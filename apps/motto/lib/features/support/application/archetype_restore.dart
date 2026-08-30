import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:motto/features/support/application/last_archetype.dart';

/// Puts back the one thing a reinstall loses.
///
/// The device outlives the app — its identifier is in the Keychain on iOS and
/// is `ANDROID_ID` on Android — so the server still holds the results, the
/// chain and the entitlement. [LastArchetype] does not: it is in preferences,
/// and it is the value that decides which door opens at the end of the
/// bootstrap. Without this, somebody whose chain is running is asked to fill
/// the inventory again, and answering it a second time writes a second result
/// that can name a different archetype.
///
/// Only the id has to come back. Every word that hangs off it — the name, the
/// summary, the mottos, the fourteen fragments — is in the content package,
/// which was downloaded again anyway.
@lazySingleton
class ArchetypeRestore {
  ArchetypeRestore(this._results, this._last);

  final api.ResultResourceApi _results;
  final LastArchetype _last;

  /// Puts the phone and the server back in agreement, in whichever direction
  /// they have drifted.
  ///
  /// Filling was the case that brought this here — a reinstall wipes the
  /// preference while the server still holds the result. The other direction
  /// is rarer and worse: the phone claiming an archetype the server has no
  /// record of. Bugün draws that claim from the package and looks fine, while
  /// Görevler asks the server and comes back with nothing, so the app says
  /// "there is nothing for today" to somebody it just called a Gece Nöbetçisi.
  Future<void> ensure() async {
    final api.ResultHistory? history;
    try {
      history = await _results.resultHistory();
    } on Object {
      // Reconciling needs an answer, and there is none. Everything this app
      // does offline — the day's text, the chain, the three things — is
      // behind the bootstrap, so throwing here made a cached app that cannot
      // open at all. Leave the phone as it is and try again next launch.
      return;
    }

    final results = history?.results ?? const <api.ResultSummary>[];

    if (results.isEmpty) {
      // Only ever reached when the server answered. Nothing is forgotten
      // because a train went into a tunnel.
      await _last.forget();
      return;
    }

    if (_last.id != null) return;

    // The server sorts by `claimedAt` descending, so the newest is first.
    // Someone who took the test twice is who they were told they are last.
    final latest = results.first;
    await _last.remember(latest.archetype.id, resultId: latest.id);
  }
}
