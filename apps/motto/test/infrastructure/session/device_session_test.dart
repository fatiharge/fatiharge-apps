import 'package:api_client_auth/api.dart' as auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/infrastructure/identity/device_identity.dart';
import 'package:motto/infrastructure/session/device_session.dart';
import 'package:motto/infrastructure/session/token_store.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockDevices extends Mock implements auth.DeviceResourceApi {}

class _FakeIdentity implements DeviceIdentity {
  @override
  Future<String> hash() async => 'a' * 64;

  @override
  String get platform => 'ios';
}

void main() {
  late _MockStorage storage;
  late _MockDevices devices;
  late TokenStore tokens;
  late DeviceSession session;

  setUp(() {
    storage = _MockStorage();
    devices = _MockDevices();
    tokens = TokenStore(storage);
    session = DeviceSession(_FakeIdentity(), devices, tokens);

    registerFallbackValue(
      auth.RegisterDeviceRequest(deviceHash: 'x', platform: 'ios'),
    );
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
        iOptions: any(named: 'iOptions'),
      ),
    ).thenAnswer((_) async {});
  });

  group('DeviceSession', () {
    test('registers when there is no token yet', () async {
      when(
        () => storage.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')),
      ).thenAnswer((_) async => null);
      when(() => devices.registerDevice(any())).thenAnswer(
        (_) async => auth.DeviceTokenResponse(
          deviceId: 'd',
          token: 'issued',
          expiresInSeconds: 3600,
        ),
      );

      await session.ensure();

      expect(tokens.current, 'issued');
    });

    test('does not register when a token is already held', () async {
      when(
        () => storage.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')),
      ).thenAnswer((_) async => 'existing');

      await session.ensure();

      verifyNever(() => devices.registerDevice(any()));
    });

    test('an empty token is not stored as if it were one', () async {
      when(
        () => storage.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')),
      ).thenAnswer((_) async => null);
      when(() => devices.registerDevice(any())).thenAnswer((_) async => null);

      await session.ensure();

      expect(tokens.current, isNull);
    });
  });
}
