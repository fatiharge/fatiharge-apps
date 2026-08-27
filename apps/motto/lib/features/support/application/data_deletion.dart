import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deletes what the server holds, and what the phone holds with it.
///
/// Both halves, because someone who asked for everything to go would
/// reasonably expect the streak on their own phone to go too — and the server
/// has never seen it.
@lazySingleton
class DataDeletion {
  DataDeletion(this._entitlements, this._preferences);

  /// Everything except the reminder hour, which is a preference rather than
  /// data about anyone.
  static const _localKeys = [
    'chain',
    'chain_unopened_in_a_row',
    'test_draft',
    'last_archetype',
  ];

  final api.EntitlementResourceApi _entitlements;
  final SharedPreferences _preferences;

  Future<void> deleteEverything() async {
    await _entitlements.deleteMyData();

    for (final key in _localKeys) {
      await _preferences.remove(key);
    }
  }
}
