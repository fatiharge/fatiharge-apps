import 'package:api_client_auth/api.dart' as auth;
import 'package:injectable/injectable.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:motto/infrastructure/session/token_store.dart';

/// Turns the device into something the API will answer.
///
/// Registration is idempotent by design on the server, which is what makes it
/// safe to call on every launch: a device that already exists gets its identity
/// back and a fresh token. There is no refresh flow — with no account there is
/// no session to keep alive, so an expired token is answered by registering
/// again rather than by anything more elaborate.
@lazySingleton
class DeviceSession {
  DeviceSession(this._identity, this._devices, this._tokens);

  final DeviceIdentity _identity;
  final auth.DeviceResourceApi _devices;
  final TokenStore _tokens;

  /// Ensures there is a usable token, registering if there is not.
  ///
  /// Failure is deliberately not fatal: the app opens, and the first screen
  /// that needs the server is where the problem is shown. A splash that refuses
  /// to move because the network is slow is a worse first impression than a
  /// welcome screen that cannot start the test yet.
  Future<void> ensure() async {
    if (await _tokens.load() != null) {
      return;
    }
    await register();
  }

  Future<void> register() async {
    final response = await _devices.registerDevice(
      auth.RegisterDeviceRequest(
        deviceHash: await _identity.hash(),
        platform: _identity.platform,
      ),
    );

    final token = response?.token;
    if (token != null && token.isNotEmpty) {
      await _tokens.save(token);
    }
  }
}
