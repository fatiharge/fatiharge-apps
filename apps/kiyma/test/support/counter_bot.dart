import 'dart:math' as math;
import 'dart:ui';
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
///
/// It works every line the counter has — wraps, plates, drinks and desserts.
/// It used to build wraps only, which was fine while wraps were all there
/// was; the moment the plate line opened, half of every order was one the bot
/// could not make, so the measured economy said that buying the plate line
/// cost you nine tenths of your income. That was the measurement being wrong,
/// not the game.
///
/// It is still not a good player — one decision per tick, no planning past
/// the neediest customer — so what it earns is a **floor**.
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

  Unlocks get _unlocks => run.progress.unlocks;

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
    if (_handOver()) return;
    if (_pourDrinks()) return;
    if (_build()) return;
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
        run.copKoseleri.first.center,
      );
      return true;
    }
    return false;
  }

  // --- Handing things over ---

  /// Everything finished that somebody at the counter is waiting for: the
  /// main product first, then the extras, because a main product occupies a
  /// station and an extra does not.
  bool _handOver() {
    final durum = run.durumIstasyonu;
    if (durum != null &&
        durum.hazir &&
        _give('durum_hazirlama', WrapProduct(durum))) {
      return true;
    }
    final tabak = run.tabakIstasyonu;
    if (tabak != null &&
        tabak.hazir &&
        _give('tabak_hazirlama', PlateProduct(tabak))) {
      return true;
    }
    for (var i = 0; i < run.bekleme.length; i++) {
      final urun = run.bekleme[i];
      if (urun == null) continue;
      if (_give('bekleme_alani', urun, slot: i)) return true;
    }
    for (var i = 0; i < run.bardakBekletme.length; i++) {
      final bardak = run.bardakBekletme[i];
      if (bardak == null || !bardak.hazir) continue;
      if (_give('bardak_bekletme', DrinkProduct(bardak.icerik!), slot: i)) {
        return true;
      }
    }
    // A dessert is never built, only fetched, so it is only worth picking up
    // when somebody is already asking for it.
    for (final tatli in _unlocks.tatlilar) {
      final index = _wants((c) => c.bekliyorTatli && c.order.tatli == tatli);
      if (index < 0) continue;
      _drag(
        run.scene[tatli.region].quad.center,
        run.scene['musteri_slot_${index + 1}'].quad.center,
      );
      return true;
    }
    // Cola comes out of the crate and goes straight over: no glass, no pour.
    if (_unlocks.icecekler.contains(Drink.kola)) {
      final index = _wants(
        (c) => c.bekliyorIcecek && c.order.icecek == Drink.kola,
      );
      if (index >= 0) {
        _drag(
          run.scene['kola_kaynak'].quad.center,
          run.scene['musteri_slot_${index + 1}'].quad.center,
        );
        return true;
      }
    }
    return false;
  }

  /// Hands [urun] to the first customer it settles something for.
  bool _give(String from, Product urun, {int? slot}) {
    for (var i = 0; i < run.musteriler.length; i++) {
      final customer = run.musteriler[i];
      if (customer == null || !customer.yerinde) continue;
      if (!_kabulEder(customer, urun)) continue;
      final region = run.scene[from];
      _drag(
        slot == null ? region.quad.center : region.slots[slot].center,
        run.scene['musteri_slot_${i + 1}'].quad.center,
      );
      return true;
    }
    return false;
  }

  bool _kabulEder(Customer customer, Product urun) => switch (urun) {
    DrinkProduct(:final icecek) =>
      customer.bekliyorIcecek && customer.order.icecek == icecek,
    DessertProduct(:final tatli) =>
      customer.bekliyorTatli && customer.order.tatli == tatli,
    _ => !customer.anaUrunVerildi && customer.order.anaUrunKabul(urun),
  };

  int _wants(bool Function(Customer) test) {
    for (var i = 0; i < run.musteriler.length; i++) {
      final customer = run.musteriler[i];
      if (customer != null && customer.yerinde && test(customer)) return i;
    }
    return -1;
  }

  // --- Drinks ---

  /// Starts a glass for the first poured drink somebody is waiting on.
  bool _pourDrinks() {
    if (!_unlocks.icecekHatti) return false;
    for (final icecek in _unlocks.icecekler) {
      if (!icecek.poured) continue;
      if (_wants((c) => c.bekliyorIcecek && c.order.icecek == icecek) < 0) {
        continue;
      }
      // Already on its way: pouring locks the glass, so there is nothing to
      // do but let it finish.
      if (run.bardakBekletme.any(
        (b) => b != null && (b.icecek == icecek && !b.bos),
      )) {
        continue;
      }
      final empty = run.bardakBekletme.indexWhere((b) => b != null && b.bos);
      if (empty >= 0) {
        _drag(
          run.scene[icecek.sourceRegion].quad.center,
          run.scene['bardak_bekletme'].slots[empty].center,
        );
        return true;
      }
      if (run.bardakBekletme.any((b) => b == null)) {
        run.tap(run.scene['bardak_kaynak'].quad.center);
        return true;
      }
    }
    return false;
  }

  // --- Building ---

  /// Builds towards whoever is closest to walking out.
  bool _build() {
    final order = _target();
    if (order == null) {
      // Nobody to build for, so keep a wrap going: it is the line that is
      // always open and the grill is running anyway.
      return _wrap(null);
    }
    return order.tip == ProductKind.porsiyon ? _plate(order) : _wrap(order);
  }

  bool _wrap(Order? order) {
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
    if (!station.etli) {
      final ready = run.mangal.indexWhere((s) => s.alinabilir);
      if (ready < 0) return false;
      _drag(
        run.scene['mangal_alani'].slots[ready].center,
        run.scene['durum_hazirlama'].quad.center,
      );
      return true;
    }
    // Bread and meat get prepared ahead; the rest waits for somebody to ask.
    // Loading a wrap with every ingredient the counter happens to own cost
    // three handfuls each and made *buying an ingredient* measure as a loss,
    // and rolling one with nothing in it closes a wrap that satisfies
    // nobody and blocks the station for the rest of the run.
    if (order == null) return false;
    for (final malzeme in _unlocks.malzemeler) {
      if (station.tutam(malzeme) >= station.gerekenTutam) continue;
      if (!order.ister.contains(malzeme.id)) continue;
      run.tap(run.scene[malzeme.region].quad.center);
      return true;
    }
    run.flickUp(run.scene['durum_hazirlama'].quad.center);
    return true;
  }

  bool _plate(Order order) {
    final station = run.tabakIstasyonu;
    if (station == null) {
      run.tap(run.scene['tabak_kaynak'].quad.center);
      return true;
    }
    if (!station.lavasli) {
      _drag(
        run.scene['lavas_kaynak'].quad.center,
        run.scene['tabak_hazirlama'].quad.center,
      );
      return true;
    }
    if (!station.etli) {
      final ready = run.mangal.indexWhere((s) => s.alinabilir);
      if (ready < 0) return false;
      _drag(
        run.scene['mangal_alani'].slots[ready].center,
        run.scene['tabak_hazirlama'].quad.center,
      );
      return true;
    }
    for (final bilesen in _unlocks.bilesenler) {
      if (station.tutam(bilesen) >= station.gerekenTutam) continue;
      if (!order.ister.contains(bilesen.id)) continue;
      run.tap(run.scene[bilesen.region].quad.center);
      return true;
    }
    // Nothing left to add: a plate is servable as soon as it has meat on
    // bread, so it is already waiting to be handed over.
    return false;
  }

  /// Cooks what is actually owed, plus one.
  ///
  /// It used to fill every slot every chance it got, which meant better coal
  /// measured as a *loss*: meat came off sooner, sat with nowhere to go, and
  /// burned. Keeping one ahead is what a person does.
  void _grill() {
    if (run.mangal.every((s) => !s.unlocked || !s.bos)) return;
    final owed = run.musteriler
        .where((c) => c != null && c.yerinde && !c.anaUrunVerildi)
        .length;
    final onIt = run.mangal.where((s) => !s.bos && !s.yanmis).length;
    if (onIt > owed) return;
    run.tap(run.scene['malzeme_kiyma'].quad.center);
  }

  /// The order of whoever is closest to walking out without their main
  /// product, whichever line it is on.
  Order? _target() {
    Customer? best;
    for (final customer in run.musteriler) {
      if (customer == null || !customer.yerinde) continue;
      if (customer.anaUrunVerildi) continue;
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

/// The shop a player would plausibly own having earned [spend].
///
/// Cheapest reachable rung first, over and over. It is not clever — nobody
/// buys purely by price — but it is the one rule that spreads across the
/// ladders instead of pouring everything into whichever group happens to be
/// first in the catalogue, and a measurement of a lopsided counter is a
/// measurement of nothing.
Unlocks unlocksFor(int day, {int spend = 0}) {
  final unlocks = Unlocks();
  var left = spend;
  while (true) {
    Unlock? ucuz;
    for (final unlock in unlocks.forSale) {
      if (unlock.price > left) continue;
      if (ucuz == null || unlock.price < ucuz.price) ucuz = unlock;
    }
    if (ucuz == null) return unlocks;
    left -= ucuz.price;
    unlocks.open(ucuz.id);
  }
}
