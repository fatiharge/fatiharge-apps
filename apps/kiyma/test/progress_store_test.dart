import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/infrastructure/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What survives a cold start. Nothing did before this: the shop's whole
/// catalogue runs to about nine thousand gold and day one takes twenty-four,
/// so a grind that only lasted one process lifetime was not a grind at all.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProgressStore> open([Map<String, Object> seed = const {}]) async {
    SharedPreferences.setMockInitialValues(seed);
    return ProgressStore(await SharedPreferences.getInstance());
  }

  test('a fresh device starts where the game starts', () async {
    final store = await open();
    final progress = Progress();
    store.restore(progress);

    expect(progress.para, 0);
    expect(progress.gun, 1);
    expect(progress.unlocks.has('malzeme_biber'), isFalse);
  });

  test('what was earned and bought comes back', () async {
    final store = await open();
    final saved = Progress()
      ..kazan(900)
      ..gun = 4;
    saved.unlocks
      ..open('malzeme_biber')
      ..open('mangal_3');
    await store.save(saved);

    final loaded = Progress();
    store.restore(loaded);

    expect(loaded.para, 900);
    expect(loaded.xp, 900);
    expect(loaded.gun, 4);
    expect(loaded.unlocks.has('malzeme_biber'), isTrue);
    expect(loaded.unlocks.has('mangal_3'), isTrue);
    expect(loaded.unlocks.has('mangal_4'), isFalse);
  });

  test('a save it cannot read is thrown away, not guessed at', () async {
    final store = await open({'progress': 'not json at all'});
    final progress = Progress();
    store.restore(progress);

    expect(progress.para, 0, reason: 'a fresh start beats a wrong reading');

    // And it does not try again on the next launch.
    final second = await open();
    expect(() => second.restore(Progress()), returnsNormally);
  });

  test('a save from an older shape is left alone', () async {
    final store = await open({
      'progress': '{"v":0,"para":500,"xp":500,"gun":9,"acik":[]}',
    });
    final progress = Progress();
    store.restore(progress);
    expect(progress.gun, 1);
  });

  test('clearing it puts the device back to a first launch', () async {
    final store = await open();
    await store.save(Progress()..kazan(400));
    await store.clear();

    final progress = Progress();
    store.restore(progress);
    expect(progress.para, 0);
  });
}
