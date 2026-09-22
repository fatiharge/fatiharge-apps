import 'package:flutter_test/flutter_test.dart';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/run_summary.dart';
import 'package:kiyma/domain/tempo.dart';

void main() {
  RunSummary run({
    int musteri = 7,
    int yanik = 0,
    int kizgin = 0,
    int kritik = 0,
    int seri = 0,
    int hedef = 6,
    bool hedefTamam = false,
    TempoBand zirve = TempoBand.normal,
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
    expect(run().rozetler, [DayBadge.kusursuz]);
  });

  test('half a good day earns the half it managed', () {
    expect(run(yanik: 1).rozetler, [DayBadge.sabirli]);
    expect(run(kizgin: 1).rozetler, [DayBadge.temiz]);
    expect(run(yanik: 1, kizgin: 1).rozetler, isEmpty);
  });

  test('a run that served nobody earns nothing for it', () {
    // Otherwise closing the app on the first frame is a perfect day.
    expect(run(musteri: 0).rozetler, isEmpty);
  });

  test('the earned ones need the thing they are named after', () {
    expect(run(seri: Balance.rozetSeri).rozetler, contains(DayBadge.seri));
    expect(
      run(seri: Balance.rozetSeri - 1).rozetler,
      isNot(contains(DayBadge.seri)),
    );
    expect(
      run(kritik: Balance.rozetKritik).rozetler,
      contains(DayBadge.kurtarici),
    );
    expect(run(hedefTamam: true).rozetler, contains(DayBadge.hedef));
    expect(
      run(zirve: TempoBand.ates).rozetler,
      contains(DayBadge.ates),
    );
    // Half again what the day asked for, against the default goal of six.
    expect(run(musteri: 9).rozetler, contains(DayBadge.dolu));
    expect(run().rozetler, isNot(contains(DayBadge.dolu)));
  });

  test('the three about mistakes never turn up together', () {
    const mistakes = {DayBadge.kusursuz, DayBadge.temiz, DayBadge.sabirli};
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
