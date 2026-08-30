import 'package:flutter_test/flutter_test.dart';
import 'package:motto/infrastructure/effects/effect.dart';
import 'package:motto/infrastructure/effects/effect_catalogue.dart';
import 'package:motto/infrastructure/effects/effect_host.dart';
import 'package:motto/infrastructure/effects/effects.dart';

class _Host implements EffectHost {
  final done = <String>[];
  int? answer = 0;
  Future<void> Function()? onCall;

  @override
  Future<void> snack(String message) async => done.add('snack:$message');

  @override
  Future<int?> sheet(ShowSheet asked) async {
    done.add('sheet:${asked.title}');
    return answer;
  }

  @override
  Future<void> goTo(String route) async => done.add('go:$route');

  @override
  Future<void> call(String name) async {
    done.add('call:$name');
    await onCall?.call();
  }

  @override
  Future<void> run(String name) async => done.add('run:$name');
}

Effects _engine(
  Map<String, List<Effect>> defined,
  _Host host, {
  EffectPermits permits = const EffectPermits(
    routes: {'/dogum-tarihi'},
    calls: {'refresh'},
    methods: {'logout'},
  ),
}) => Effects(WrittenCatalogue(defined), host, permits);

void main() {
  late _Host host;

  setUp(() => host = _Host());

  group('what a refusal leads to', () {
    test('a code nobody defined is not answered at all', () async {
      final engine = _engine(const {}, host);

      // Different from "there is nothing to do": the screen has to say it does
      // not know rather than invent something.
      expect(await engine.forCode('birth_date_required'), isFalse);
      expect(host.done, isEmpty);
    });

    test('the sheet is answered before the app moves', () async {
      final engine = _engine({
        'birth_date_required': const [
          ShowSheet(
            title: 'Doğum tarihin gerekiyor',
            body: 'Bir kere sorup bir daha sormayacağım.',
            bottom: true,
            choices: [
              EffectChoice(label: 'Gir', then: [GoTo('/dogum-tarihi')]),
              EffectChoice(label: 'Şimdi değil', then: []),
            ],
          ),
        ],
      }, host);

      expect(await engine.forCode('birth_date_required'), isTrue);
      expect(host.done, [
        'sheet:Doğum tarihin gerekiyor',
        'go:/dogum-tarihi',
      ]);
    });

    test('closing the sheet chooses nothing', () async {
      host.answer = null;
      final engine = _engine({
        'x': const [
          ShowSheet(
            title: 'Bir şey',
            body: '…',
            bottom: false,
            choices: [
              EffectChoice(label: 'Git', then: [GoTo('/dogum-tarihi')]),
            ],
          ),
          ShowSnack('sonra'),
        ],
      }, host);

      await engine.forCode('x');

      // Somebody who closed it did not choose, and the rest of the list was
      // the consequence of choosing.
      expect(host.done, ['sheet:Bir şey']);
    });

    test('a definition asking for what this app has not is unusable', () async {
      final engine = _engine({
        'x': const [GoTo('/başka-uygulamanın-ekranı')],
      }, host);

      // Not half-run: running the part we understand strands somebody between
      // two steps.
      expect(await engine.forCode('x'), isFalse);
      expect(host.done, isEmpty);
    });

    test('an effect that causes its own refusal stops', () async {
      late Effects engine;
      engine = _engine({
        'x': const [CallNamed('refresh')],
      }, host);
      // The call fails the same way, and its failure arrives here again.
      host.onCall = () async => engine.forCode('x');

      await engine.forCode('x');

      // Twice, not for ever.
      expect(host.done.where((step) => step == 'call:refresh').length, 2);
    });

    test('a snack needs nothing to be allowed', () async {
      final engine = _engine(
        {
          'x': const [ShowSnack('oldu')],
        },
        host,
        permits: const EffectPermits.none(),
      );

      expect(await engine.forCode('x'), isTrue);
      expect(host.done, ['snack:oldu']);
    });
  });

  group('reading a definition', () {
    test('an unknown kind makes the whole thing unusable', () {
      expect(Effect.fromJson({'kind': 'launch_missiles'}), isNull);
      expect(
        Effect.fromJson({
          'kind': 'sheet',
          'title': 'a',
          'body': 'b',
          'choices': [
            {
              'label': 'go',
              'then': [
                {'kind': 'launch_missiles'},
              ],
            },
          ],
        }),
        isNull,
      );
    });

    test('a sheet with its choices reads whole', () {
      final effect = Effect.fromJson({
        'kind': 'bottom_sheet',
        'title': 'a',
        'body': 'b',
        'choices': [
          {
            'label': 'go',
            'then': [
              {'kind': 'navigate', 'to': '/x'},
            ],
          },
        ],
      });

      expect(effect, isA<ShowSheet>());
      final sheet = effect! as ShowSheet;
      expect(sheet.bottom, isTrue);
      expect(sheet.choices.single.then.single, isA<GoTo>());
    });
  });
}
