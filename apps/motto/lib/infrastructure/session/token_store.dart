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
  static const _expiryKey = 'device_token_expires_at';

  /// Not synchronizable — its default — so the token does not travel to
  /// another device on the same Apple ID.
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  final FlutterSecureStorage _storage;

  String? _cached;
  DateTime? _expiresAt;

  /// A flag rather than a null check on the values: a device with no token, or
  /// a token with no recorded expiry, is a legitimate state, and `??=` would
  /// send it back to the Keychain on every request.
  bool _read = false;

  /// Read once, then from memory: every request asks for this, and the
  /// Keychain is not free.
  String? get current => _cached;

  Future<String?> load() async {
    if (_read) return _cached;

    _cached = await _storage.read(key: _key, iOptions: _iosOptions);
    _expiresAt = DateTime.tryParse(
      await _storage.read(key: _expiryKey, iOptions: _iosOptions) ?? '',
    );
    _read = true;
    return _cached;
  }

  /// When the token stops working, if that was ever recorded. Null for a token
  /// stored before this was kept — treated as already expired, because
  /// registering again is cheap and being locked out is not.
  DateTime? get expiresAt => _expiresAt;

  Future<void> save(String token, {DateTime? expiresAt}) async {
    _cached = token;
    _expiresAt = expiresAt;
    _read = true;
    await _storage.write(key: _key, value: token, iOptions: _iosOptions);
    await _storage.write(
      key: _expiryKey,
      value: expiresAt?.toIso8601String(),
      iOptions: _iosOptions,
    );
  }

  Future<void> clear() async {
    _cached = null;
    _expiresAt = null;
    _read = true;
    await _storage.delete(key: _key, iOptions: _iosOptions);
    await _storage.delete(key: _expiryKey, iOptions: _iosOptions);
  }
}
