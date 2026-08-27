import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Where the device token lives between launches.
///
/// The Keychain rather than preferences: the token is what proves a request is
/// this device, and it is short-lived only in the sense that it expires — until
/// then it is the credential.
@lazySingleton
class TokenStore {
  TokenStore(this._storage);

  static const _key = 'device_token';
  /// Not synchronizable — its default — so the token does not travel to
  /// another device on the same Apple ID.
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  final FlutterSecureStorage _storage;

  String? _cached;

  /// Read once, then from memory: every request asks for this, and the
  /// Keychain is not free.
  String? get current => _cached;

  Future<String?> load() async =>
      _cached ??= await _storage.read(key: _key, iOptions: _iosOptions);

  Future<void> save(String token) async {
    _cached = token;
    await _storage.write(key: _key, value: token, iOptions: _iosOptions);
  }

  Future<void> clear() async {
    _cached = null;
    await _storage.delete(key: _key, iOptions: _iosOptions);
  }
}
