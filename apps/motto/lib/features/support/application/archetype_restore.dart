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

  /// Nothing to ask on any launch but the first one after a reinstall.
  Future<void> ensure() async {
    if (_last.id != null) return;

    final history = await _results.resultHistory();
    final results = history?.results ?? const <api.ResultSummary>[];
    if (results.isEmpty) return;

    // The server sorts by `claimedAt` descending, so the newest is first.
    // Someone who took the test twice is who they were told they are last.
    final latest = results.first;
    await _last.remember(latest.archetype.id, resultId: latest.id);
  }
}
