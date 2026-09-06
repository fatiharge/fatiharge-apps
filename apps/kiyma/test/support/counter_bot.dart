import 'dart:math' as math;
import 'dart:ui';
import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/day_run.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/order.dart';
import 'package:kiyma/domain/model/products.dart';
import 'package:kiyma/domain/progress.dart';
import 'package:kiyma/domain/scene.dart';
import 'package:kiyma/domain/unlocks.dart';

/// A scripted player, so the economy can be measured instead of guessed.
///
/// [DayRun] is pure Dart with no engine in it, which is what makes this
/// possible: a whole day plays out in a loop with no canvas and no clock.
/// The bot is not good — it does one thing at a time and only ever builds
/// wraps — so what it earns is a **floor**, not a ceiling. Numbers derived
/// from it should be read as "even a plodding player clears this".
class CounterBot {
  CounterBot(this.run, {this.skill = 1});

  final DayRun run;

  /// `0..1`. How much of each decision the bot gets right; the rest of the
  /// time it dawdles, which costs it tempo exactly as it would a person.
  final double skill;

  static const _step = 0.1;

  /// Plays a whole run and answers what it took.
  static ({int kazanc, int musteri, double tempo}) play(
    SceneData scene,
    Progress progress, {
    double skill = 1,
    int seed = 1,
  }) {
    final run = DayRun(
      scene: scene,
      progress: progress,
      onEvent: (_) {},
      onChanged: () {},
      random: math.Random(seed),
    );
    final bot = CounterBot(run, skill: skill);
    var tempoSum = 0.0;
    var ticks = 0;
    while (!run.bitti) {
      bot.act();
      run.tick(_step);
      tempoSum += run.tempo.deger;
      ticks++;
    }
    return (
      kazanc: run.kazanc,
      musteri: run.memnunMusteri,
      tempo: ticks == 0 ? 0 : tempoSum / ticks,
    );
  }

  double _idle = 0;

  /// One decision per tick, in the order a person would think of them.
  void act() {
    // Dawdling: a bot that never hesitates measures a player who does not
    // exist, and tempo is exactly the thing that punishes hesitation.
    if (skill < 1) {
      _idle -= _step;
      if (_idle > 0) return;
      _idle = (1 - skill) * 1.2;
    }

    if (_collect()) return;
    if (_bin()) return;
    if (_serve()) return;
    if (_wrap()) return;
    _grill();
  }

  bool _collect() {
    for (var i = 0; i < run.altin.length; i++) {
      if (run.altin[i] == null) continue;
      run.tap(run.scene['altin_alani'].slots[i].center);
      return true;
    }
    return false;
  }

  bool _bin() {
    for (var i = 0; i < run.mangal.length; i++) {
      if (!run.mangal[i].yanmis) continue;
      _drag(
        run.scene['mangal_alani'].slots[i].center,
        run.scene['cop_alani'].quad.center,
      );
      return true;
    }
    return false;
  }

  /// Hands the finished wrap to the first customer whose order it satisfies.
  bool _serve() {
    final station = run.durumIstasyonu;
    if (station == null || !station.hazir) return false;
    final urun = DurumUrun(station);
    for (var i = 0; i < run.musteriler.length; i++) {
      final customer = run.musteriler[i];
      if (customer == null || !customer.yerinde) continue;
      if (customer.anaUrunVerildi) continue;
      if (!customer.order.anaUrunKabul(urun)) continue;
      _drag(
        run.scene['durum_hazirlama'].quad.center,
        run.scene['musteri_slot_${i + 1}'].quad.center,
      );
      return true;
    }
    return false;
  }

  /// Builds towards whatever the longest-waiting customer asked for.
  bool _wrap() {
    final station = run.durumIstasyonu;
    if (station == null) {
      run.tap(run.scene['lavas_kaynak'].quad.center);
      return true;
    }
    if (station.kagitli) return false;
    if (station.sarili) {
      run.tap(run.scene['kagit_kaynak'].quad.center);
      return true;
    }

    final order = _target();
    if (!station.etli) {
      final ready = run.mangal.indexWhere((s) => s.alinabilir);
      if (ready < 0) return false;
      _drag(
        run.scene['mangal_alani'].slots[ready].center,
        run.scene['durum_hazirlama'].quad.center,
      );
      return true;
    }
    for (final malzeme in run.progress.unlocks.malzemeler) {
      if (station.tutam(malzeme) >= Balance.tutamAdedi) continue;
      if (order != null && !order.ister.contains(malzeme.id)) continue;
      run.tap(run.scene[malzeme.region].quad.center);
      return true;
    }
    run.flickUp(run.scene['durum_hazirlama'].quad.center);
    return true;
  }

  /// Keeps the grill as full as it can.
  void _grill() {
    if (run.mangal.every((s) => !s.unlocked || !s.bos)) return;
    run.tap(run.scene['malzeme_kiyma'].quad.center);
  }

  Order? _target() {
    Customer? best;
    for (final customer in run.musteriler) {
      if (customer == null || !customer.yerinde) continue;
      if (customer.anaUrunVerildi) continue;
      if (customer.order.tip != UrunTipi.durum) continue;
      if (best == null || customer.sabirKalan < best.sabirKalan) {
        best = customer;
      }
    }
    return best?.order;
  }

  void _drag(Offset from, Offset to) {
    if (!run.beginDrag(from)) return;
    run
      ..carriedAt = to
      ..endDrag(to);
  }
}

/// Unlocks a player would plausibly own by [day], bought in catalogue order.
Unlocks unlocksFor(int day, {int spend = 0}) {
  final unlocks = Unlocks();
  var left = spend;
  for (final unlock in Unlocks.catalogue) {
    if (!unlocks.available(unlock)) continue;
    if (unlock.price > left) continue;
    left -= unlock.price;
    unlocks.open(unlock.id);
  }
  return unlocks;
}
