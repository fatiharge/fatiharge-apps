import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: DeviceIdentity)
class DeviceIdentityImpl implements DeviceIdentity {
  DeviceIdentityImpl(this._storage, this._androidId);

  static const _key = 'device_id';

  final FlutterSecureStorage _storage;
  final AndroidId _androidId;

  String? _cached;

  @override
  String get platform => Platform.isIOS ? 'ios' : 'android';

  @override
  Future<String> hash() async {
    final identifier = _cached ??= await _identifier();
    return sha256.convert(utf8.encode(identifier)).toString();
  }

  /// Android: `Settings.Secure.ANDROID_ID` outlives the app, secure storage
  /// does not. iOS: only the Keychain survives, which is the only place the
  /// "reinstall for free uses" hole is closed.
  Future<String> _identifier() async {
    if (Platform.isAndroid) {
      final androidId = await _androidId.getId();
      if (androidId != null && androidId.isNotEmpty) {
        return androidId;
      }
      // Rare but real. A stored id beats a new one per launch.
    }

    final stored = await _storage.read(key: _key, iOptions: _iosOptions);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    final fresh = const Uuid().v4();
    await _storage.write(key: _key, value: fresh, iOptions: _iosOptions);
    return fresh;
  }

  /// `first_unlock` because a notification can wake the app before the phone
  /// has been unlocked since boot. Synchronizable stays off: with it on, a
  /// second device on the same Apple ID would share one set of free uses.
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
}
