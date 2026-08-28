import 'package:api_client_auth/api.dart' as auth;
import 'package:injectable/injectable.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:motto/infrastructure/session/token_store.dart';

/// Turns the device into something the API will answer.
///
/// Registration is idempotent on the server, so it is safe on every launch.
/// There is no refresh flow: with no account there is no session to keep
/// alive, so an expired token is answered by registering again.
///
/// That answer used to be a comment rather than code. A stored token was
/// trusted for ever, the token lasts an hour, and nothing ever noticed — so an
/// hour after first launch every request began failing and the app never
/// recovered short of clearing its data. It looked like the network, and it
/// was us.
@lazySingleton
class DeviceSession {
  DeviceSession(this._identity, this._devices, this._tokens);

  final DeviceIdentity _identity;
  final auth.DeviceResourceApi _devices;
  final TokenStore _tokens;

  /// Registered again a little before the token dies, so a request in flight
  /// at the boundary does not land on the far side of it.
  static const _margin = Duration(minutes: 5);

  /// Failure is not fatal: the first screen that needs the server is where
  /// the problem is shown.
  Future<void> ensure() async {
    if (await _tokens.load() == null || _expired) {
      await register();
    }
  }

  bool get _expired {
    final expiry = _tokens.expiresAt;
    // Unknown means a token stored before expiry was kept. Registering again
    // costs one request; being locked out costs the app.
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry.subtract(_margin));
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
      await _tokens.save(
        token,
        expiresAt: DateTime.now().add(
          Duration(seconds: response!.expiresInSeconds),
        ),
      );
    }
  }
}
