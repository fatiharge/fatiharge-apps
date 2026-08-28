import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/infrastructure/session/token_store.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late TokenStore store;

  setUp(() {
    storage = _MockStorage();
    store = TokenStore(storage);
    registerFallbackValue(IOSOptions.defaultOptions);
  });

  group('TokenStore', () {
    test('reads the token from storage once and then from memory', () async {
      when(
        () => storage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
        ),
      ).thenAnswer((_) async => 'a.b.c');

      expect(await store.load(), 'a.b.c');
      expect(await store.load(), 'a.b.c');

      // Every request asks for this; the Keychain is not free. Two keys are
      // read — the token and when it dies — but only on the first call.
      verify(
        () => storage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
        ),
      ).called(2);
    });

    test('a saved token is readable without going back to storage', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
        ),
      ).thenAnswer((_) async {});

      await store.save('fresh');

      expect(store.current, 'fresh');
      verifyNever(
        () => storage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
        ),
      );
    });

    test('clearing forgets it in both places', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => storage.delete(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
        ),
      ).thenAnswer((_) async {});

      await store.save('fresh');
      await store.clear();

      expect(store.current, isNull);
      expect(store.expiresAt, isNull);
      // Both keys: a token left behind without its expiry would be trusted
      // for ever, which is the whole bug this pair exists to stop.
      verify(
        () => storage.delete(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
        ),
      ).called(2);
    });
  });
}
