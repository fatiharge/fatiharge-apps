import 'dart:convert';

import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motto/features/content/application/content_repository.dart';
import 'package:motto/features/content/application/content_store.dart';
import 'package:motto/features/daily/domain/content_pack.dart';

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

  test('a phone that has never been online has no content', () async {
    when(store.readCached).thenAnswer((_) async => null);

    // Nothing ships inside the app, so this state is reachable and the flow
    // has to stop rather than open on an empty screen.
    expect(await repository.current(), isNull);
  });

  test('what was downloaded is what gets shown', () async {
    when(store.readCached).thenAnswer((_) async => {'version': 'downloaded'});

    expect((await repository.current())!['version'], 'downloaded');
  });

  test('the held version is what gets sent back', () async {
    when(() => store.version).thenReturn('abc123');
    when(
      () => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')),
    ).thenAnswer((_) async => null);

    await repository.refresh();

    verify(() => content.contentBundle(ifNoneMatch: '"abc123"')).called(1);
    verifyNever(() => store.save(any(), any()));
  });

  test('a newer package is kept and used from then on', () async {
    when(() => store.version).thenReturn('old');
    when(store.readCached).thenAnswer((_) async => {'version': 'new'});
    when(
      () => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')),
    ).thenAnswer((_) async => _bundle('new'));

    await repository.refresh();

    verify(() => store.save(any(), 'new')).called(1);
    expect((await repository.current())!['version'], 'new');
  });

  test(
    'a refresh that fails with a package on the phone is not a failure',
    () async {
      when(() => store.version).thenReturn('old');
      when(store.readCached).thenAnswer((_) async => {'version': 'old'});
      when(
        () => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')),
      ).thenThrow(Exception('offline'));

      await expectLater(repository.refresh(), completes);
    },
  );

  test(
    'a refresh that fails with nothing on the phone stops the flow',
    () async {
      when(() => store.version).thenReturn(null);
      when(store.readCached).thenAnswer((_) async => null);
      when(
        () => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')),
      ).thenThrow(Exception('offline'));

      await expectLater(repository.refresh(), throwsA(isA<Exception>()));
    },
  );

  test('a device with nothing yet asks without a version', () async {
    when(() => store.version).thenReturn(null);
    when(store.readCached).thenAnswer((_) async => {'version': 'first'});
    when(
      () => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')),
    ).thenAnswer((_) async => _bundle('first'));

    await repository.refresh();

    final sent = verify(
      () => content.contentBundle(
        ifNoneMatch: captureAny(named: 'ifNoneMatch'),
      ),
    ).captured.single;
    expect(sent, isNull);
  });

  // The bug this exists for: the generated client's toJson() leaves nested
  // lists as model objects and lets jsonEncode convert them, so the map it
  // returns parses only after a trip through the file. Keeping it in memory
  // made the day's content fail on the launch that fetched it and work on
  // every launch after — so the store here round-trips exactly like the real
  // one, and the assertion is that what comes back can actually be read.
  test('what a refresh leaves behind is parseable, not just a map', () async {
    String? saved;
    when(() => store.version).thenReturn(null);
    when(() => store.save(any(), any())).thenAnswer((invocation) async {
      saved = jsonEncode(invocation.positionalArguments.first);
    });
    when(store.readCached).thenAnswer(
      (_) async =>
          saved == null ? null : jsonDecode(saved!) as Map<String, dynamic>,
    );
    when(
      () => content.contentBundle(ifNoneMatch: any(named: 'ifNoneMatch')),
    ).thenAnswer((_) async => _full());

    await repository.refresh();

    final pack = ContentPack.fromJson((await repository.current())!);
    expect(pack.version, 'first');
    expect(pack.skeletons, hasLength(1));
    expect(pack.fragments, hasLength(1));
    expect(pack.connectors, ['Sende bunun karşılığı şu.']);
    expect(pack.mottos, hasLength(1));
  });
}

api.ContentBundle _full() => api.ContentBundle(
  version: 'first',
  archetypes: [],
  mottos: [
    api.MottoContent(
      id: 'qb1',
      archetypeId: 'quiet_builder',
      motto: 'Acele etmeyen ama durmayan.',
      detail: 'Bedeli, ilerlediğini kimsenin fark etmemesi.',
      reminder: 'Bugün de bir adım.',
    ),
  ],
  skeletons: [
    api.DailySkeleton(
      day: 1,
      title: 'Bir dakika',
      body: 'Bugün başlayan şey küçük olmak zorunda.',
      action: 'Bir dakikanı alacak tek bir şey seç.',
    ),
  ],
  fragments: [
    api.Fragment(
      archetypeId: 'quiet_builder',
      index: 1,
      text: 'Sen zaten küçük başlıyorsun.',
    ),
  ],
  connectors: [api.Connector(id: 'c1', text: 'Sende bunun karşılığı şu.')],
);
