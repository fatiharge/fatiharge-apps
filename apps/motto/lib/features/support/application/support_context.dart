import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:motto/features/support/application/last_archetype.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// What gets attached to every piece of feedback.
///
/// Collected rather than asked for: the answer to "which version are you on?"
/// is usually wrong, and asking it is one more reason not to send anything.
@lazySingleton
class SupportContext {
  SupportContext(this._identity, this._lastArchetype);

  final DeviceIdentity _identity;
  final LastArchetype _lastArchetype;

  Future<Map<String, String>> collect() async => {
    'appVersion': await _version(),
    'platform': _identity.platform,
    'osVersion': Platform.operatingSystemVersion,
    if (_lastArchetype.id case final String archetype)
      'archetypeId': archetype,
  };

  /// A version we could not read is worth less than the report it would
  /// otherwise sink. Nothing here is allowed to be the reason feedback fails
  /// to send.
  Future<String> _version() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } on Object {
      return 'unknown';
    }
  }
}
