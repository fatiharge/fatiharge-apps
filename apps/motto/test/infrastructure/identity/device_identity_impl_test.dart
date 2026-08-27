import 'package:android_id/android_id.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/infrastructure/identity/device_identity_impl.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockAndroidId extends Mock implements AndroidId {}

void main() {
  late _MockStorage storage;
  late DeviceIdentityImpl identity;
  final written = <String, String>{};

  setUp(() {
    storage = _MockStorage();
    identity = DeviceIdentityImpl(storage, _MockAndroidId());
    written.clear();
    registerFallbackValue(const IOSOptions());

    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
        iOptions: any(named: 'iOptions'),
      ),
    ).thenAnswer((invocation) async {
      written[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
  });

  group('DeviceIdentityImpl', () {
    test('what leaves the phone is a SHA-256, not the identifier', () async {
      when(
        () => storage.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')),
      ).thenAnswer((_) async => 'a-known-identifier');

      final hash = await identity.hash();

      expect(hash, hasLength(64));
      expect(hash, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(hash, isNot(contains('a-known-identifier')));
    });

    test('the same device hashes to the same thing every time', () async {
      when(
        () => storage.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')),
      ).thenAnswer((_) async => 'stable');

      expect(await identity.hash(), await identity.hash());
    });

    test('a device with no identifier gets one, and keeps it', () async {
      when(
        () => storage.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')),
      ).thenAnswer((_) async => null);

      await identity.hash();

      // Stored rather than regenerated per launch: a new identifier every time
      // would hand out the free uses again on every start.
      expect(written, isNotEmpty);
    });

    test('the platform is one the API knows', () {
      expect(identity.platform, anyOf('ios', 'android'));
    });
  });
}
