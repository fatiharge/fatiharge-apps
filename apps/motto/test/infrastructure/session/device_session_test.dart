import 'package:api_client_auth/api.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:motto/infrastructure/session/device_session.dart';
import 'package:motto/infrastructure/session/token_store.dart';

class _MockDevices extends Mock implements auth.DeviceResourceApi {}

class _MockIdentity extends Mock implements DeviceIdentity {}

class _MockTokens extends Mock implements TokenStore {}

void main() {
  late _MockDevices devices;
  late _MockTokens tokens;
  late DeviceSession session;

  setUpAll(
    () => registerFallbackValue(
      auth.RegisterDeviceRequest(deviceHash: 'x', platform: 'android'),
    ),
  );

  setUp(() {
    devices = _MockDevices();
    tokens = _MockTokens();
    final identity = _MockIdentity();
    when(identity.hash).thenAnswer((_) async => 'abc');
    when(() => identity.platform).thenReturn('android');
    when(() => devices.registerDevice(any())).thenAnswer(
      (_) async => auth.DeviceTokenResponse(
        deviceId: 'd',
        token: 'fresh',
        expiresInSeconds: 3600,
      ),
    );
    when(
      () => tokens.save(any(), expiresAt: any(named: 'expiresAt')),
    ).thenAnswer((_) async {});
    session = DeviceSession(identity, devices, tokens);
  });

  test('with no token it registers', () async {
    when(tokens.load).thenAnswer((_) async => null);
    when(() => tokens.expiresAt).thenReturn(null);

    await session.ensure();

    verify(() => devices.registerDevice(any())).called(1);
  });

  // The bug this exists for: the token lasts an hour and a stored one was
  // trusted for ever, so an hour in, every request failed and the app never
  // came back.
  test('an expired token is replaced rather than kept', () async {
    when(tokens.load).thenAnswer((_) async => 'stale');
    when(
      () => tokens.expiresAt,
    ).thenReturn(DateTime.now().subtract(const Duration(minutes: 1)));

    await session.ensure();

    verify(() => devices.registerDevice(any())).called(1);
  });

  test('a token about to expire is replaced before it does', () async {
    when(tokens.load).thenAnswer((_) async => 'nearly');
    when(
      () => tokens.expiresAt,
    ).thenReturn(DateTime.now().add(const Duration(minutes: 2)));

    await session.ensure();

    verify(() => devices.registerDevice(any())).called(1);
  });

  test('a token with time on it is left alone', () async {
    when(tokens.load).thenAnswer((_) async => 'good');
    when(
      () => tokens.expiresAt,
    ).thenReturn(DateTime.now().add(const Duration(minutes: 50)));

    await session.ensure();

    verifyNever(() => devices.registerDevice(any()));
  });

  test('a token stored before expiry was kept counts as expired', () async {
    when(tokens.load).thenAnswer((_) async => 'from-an-older-build');
    when(() => tokens.expiresAt).thenReturn(null);

    await session.ensure();

    verify(() => devices.registerDevice(any())).called(1);
  });

  test('a registration that answers without a token is a failure', () async {
    when(
      () => devices.registerDevice(any()),
    ).thenAnswer((_) async => null);

    // The retry after a 401 asks for this and then sends the request again.
    // Keeping the dead token quietly turned one 401 into two, which reads as
    // the server being down rather than the session being over.
    await expectLater(session.register(), throwsA(isA<StateError>()));
    verifyNever(() => tokens.save(any(), expiresAt: any(named: 'expiresAt')));
  });
}
