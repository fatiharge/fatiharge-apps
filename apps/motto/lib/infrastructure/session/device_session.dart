import 'package:api_client_auth/api.dart' as auth;
import 'package:injectable/injectable.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:motto/infrastructure/session/token_store.dart';

/// Turns the device into something the API will answer.
///
/// Registration is idempotent, so it is safe on every launch. There is no
/// refresh flow — with no account there is no session to keep alive — so an
/// expired token is answered by registering again. The token lasts an hour,
/// and nothing used to notice it had gone.
@lazySingleton
class DeviceSession {
  DeviceSession(this._identity, this._devices, this._tokens);

  final DeviceIdentity _identity;
  final auth.DeviceResourceApi _devices;
  final TokenStore _tokens;

  /// Renewed before the token dies, so a request in flight at the boundary
  /// does not land on the far side of it.
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
    // Unknown means it was stored before expiry was kept. One extra request
    // is cheaper than being locked out.
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
    if (token == null || token.isEmpty) {
      // Said rather than shrugged off. The retry after a 401 asks for this and
      // then sends the request again; a registration that quietly kept the old
      // token turned one 401 into two and looked like the server was down.
      throw StateError('the register call answered without a token');
    }

    await _tokens.save(
      token,
      expiresAt: DateTime.now().add(
        Duration(seconds: response!.expiresInSeconds),
      ),
    );
  }
}
