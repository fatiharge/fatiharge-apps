import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/content/application/content_repository.dart';
import 'package:motto/features/content/application/content_store.dart';

class _MockContent extends Mock implements api.ContentResourceApi {}

class _MockStore extends Mock implements ContentStore {}

api.ContentBundle _bundle(String version) => api.ContentBundle(
  version: version,
  archetypes: [],
  mottos: [],
  skeletons: [],
  fragments: [],
  connectors: [],
);

void main() {
  late _MockContent content;
  late _MockStore store;
  late ContentRepository repository;

  setUp(() {
    content = _MockContent();
    store = _MockStore();
    when(() => store.save(any(), any())).thenAnswer((_) async {});
    repository = ContentRepository(content, store);
  });

  test('what was downloaded wins over what shipped', () async {
    when(store.readCached).thenAnswer((_) async => {'version': 'downloaded'});
    when(store.readBundled).thenAnswer((_) async => {'version': 'shipped'});

    expect((await repository.current())['version'], 'downloaded');
    verifyNever(store.readBundled);
  });

  test('a first launch with no network still has content', () async {
    when(store.readCached).thenAnswer((_) async => null);
    when(store.readBundled).thenAnswer((_) async => {'version': 'shipped'});

    // An empty first day is the last day someone opens this.
    expect((await repository.current())['version'], 'shipped');
  });

  test('the held version is what gets sent back', () async {
    when(() => store.version).thenReturn('abc123');
    when(() => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')))
        .thenAnswer((_) async => null);

    await repository.refresh();

    verify(() => content.contentBundle(ifNoneMatch: '"abc123"')).called(1);
  });

  test('nothing new means nothing written', () async {
    when(() => store.version).thenReturn('abc123');
    when(() => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')))
        .thenAnswer((_) async => null);

    await repository.refresh();

    // A 304 comes back as null, which is exactly the answer wanted.
    verifyNever(() => store.save(any(), any()));
  });

  test('a newer package is kept and used from then on', () async {
    when(() => store.version).thenReturn('old');
    when(store.readCached).thenAnswer((_) async => {'version': 'old'});
    when(() => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')))
        .thenAnswer((_) async => _bundle('new'));

    await repository.refresh();

    verify(() => store.save(any(), 'new')).called(1);
    expect((await repository.current())['version'], 'new');
  });

  test('a refresh that fails is not a failure anyone sees', () async {
    when(() => store.version).thenReturn(null);
    when(() => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')))
        .thenThrow(Exception('offline'));
    when(store.readCached).thenAnswer((_) async => {'version': 'old'});

    await repository.refresh();

    expect((await repository.current())['version'], 'old');
  });

  test('a device with nothing yet asks without a version', () async {
    when(() => store.version).thenReturn(null);
    when(() => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')))
        .thenAnswer((_) async => _bundle('first'));

    await repository.refresh();

    final sent = verify(
      () => content.contentBundle(
        ifNoneMatch: captureAny(named: 'ifNoneMatch'),
      ),
    ).captured.single;
    expect(sent, isNull);
  });
}
