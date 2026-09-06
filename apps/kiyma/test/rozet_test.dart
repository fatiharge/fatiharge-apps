import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/run_summary.dart';
import 'package:kiyma/domain/tempo.dart';

void main() {
  RunSummary run({
    int musteri = 8,
    int yanik = 0,
    int kizgin = 0,
    int kritik = 0,
    int seri = 0,
    int hedef = 6,
    bool hedefTamam = false,
    TempoHali zirve = TempoHali.normal,
  }) => RunSummary(
    kazanc: 100,
    musteri: musteri,
    xpOnce: 0,
    gunOnce: 3,
    atlananGun: 0,
    zirveTempo: zirve,
    yanik: yanik,
    kizgin: kizgin,
    kritik: kritik,
    enUzunSeri: seri,
    hedef: hedef,
    hedefTamam: hedefTamam,
  );

  test('a flawless day earns the one badge that means flawless', () {
    // Not three: "nothing burnt" and "nobody angry" are what "perfect"
    // already says, and a chip that always comes with another is decoration.
    expect(run().rozetler, [Rozet.kusursuz]);
  });

  test('half a good day earns the half it managed', () {
    expect(run(yanik: 1).rozetler, [Rozet.sabirli]);
    expect(run(kizgin: 1).rozetler, [Rozet.temiz]);
    expect(run(yanik: 1, kizgin: 1).rozetler, isEmpty);
  });

  test('a run that served nobody earns nothing for it', () {
    // Otherwise closing the app on the first frame is a perfect day.
    expect(run(musteri: 0).rozetler, isEmpty);
  });

  test('the earned ones need the thing they are named after', () {
    expect(run(seri: Balance.rozetSeri).rozetler, contains(Rozet.seri));
    expect(
      run(seri: Balance.rozetSeri - 1).rozetler,
      isNot(contains(Rozet.seri)),
    );
    expect(
      run(kritik: Balance.rozetKritik).rozetler,
      contains(Rozet.kurtarici),
    );
    expect(run(hedefTamam: true).rozetler, contains(Rozet.hedef));
    expect(
      run(zirve: TempoHali.ates).rozetler,
      contains(Rozet.ates),
    );
    // Half again what the day asked for, against the default goal of six.
    expect(run(musteri: 9).rozetler, contains(Rozet.dolu));
    expect(run(musteri: 8).rozetler, isNot(contains(Rozet.dolu)));
  });

  test('the three about mistakes never turn up together', () {
    const mistakes = {Rozet.kusursuz, Rozet.temiz, Rozet.sabirli};
    for (final earned in [
      run().rozetler,
      run(kizgin: 1).rozetler,
      run(yanik: 1).rozetler,
      run(yanik: 1, kizgin: 1).rozetler,
    ]) {
      expect(earned.where(mistakes.contains).length, lessThanOrEqualTo(1));
    }
  });
}
