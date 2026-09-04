import 'package:kiyma/domain/balance.dart';
import 'package:kiyma/domain/model/items.dart';
import 'package:kiyma/domain/model/products.dart';

/// What one customer wants. `ister` and `istemez` never overlap.
///
/// This is the game's central trade-off: every extra ingredient pays, and one
/// ingredient from `istemez` throws the whole product away.
class Order {
  Order({
    required this.tip,
    required this.ister,
    required this.istemez,
    this.tatli,
    this.icecek,
  });

  final UrunTipi tip;

  /// Wrap ingredients or plate components, depending on [tip]. Held as ids so
  /// one order type covers both lines.
  final Set<String> ister;
  final Set<String> istemez;

  final Tatli? tatli;
  final Icecek? icecek;

  bool anaUrunKabul(Urun urun) {
    final icerik = switch (urun) {
      DurumUrun(:final durum) when tip == UrunTipi.durum =>
        durum.malzemeler.map((m) => m.id).toSet(),
      PorsiyonUrun(:final porsiyon) when tip == UrunTipi.porsiyon =>
        porsiyon.bilesenler.map((b) => b.id).toSet(),
      _ => null,
    };
    if (icerik == null) return false;
    return ister.every(icerik.contains) && !istemez.any(icerik.contains);
  }
}

/// Where a customer is in their visit.
///
/// One value drives what they are drawn as. For now that is a flat colour, so
/// the states can be seen and argued about before anybody animates them.
enum MusteriHali {
  yuruyor,
  bekliyorCokSakin,
  bekliyorSakin,
  bekliyorStabil,
  bekliyorSupheli,
  bekliyorKizgin,
  gidiyorMutlu,
  gidiyorStabil,
  gidiyorKizgin,
}

/// Somebody on their way out, walking off to the left.
///
/// They leave the seat the moment they turn to go — the next customer is
/// already on their way in — so this holds nothing but what is still on
/// screen.
class Ayrilan {
  Ayrilan({required this.slot, required this.hal, required this.hiz});

  final int slot;
  final MusteriHali hal;
  final double hiz;

  double gidis = 0;

  bool get gitti => gidis >= 1;
}

/// A customer at the counter: an order, a patience bar, and a record of which
/// line items have already been handed over.
class Customer {
  Customer({required this.order, required this.day, this.hiz = 1})
    : sabirToplam = Balance.patience(day),
      sabirKalan = Balance.patience(day);

  final Order order;
  final int day;

  /// How fast they walk, as a fraction of the quickest. Kept for the walk
  /// out, so somebody who dawdled in dawdles out.
  final double hiz;

  /// `0..1` of the walk in from the right of the shop.
  ///
  /// Nothing about them counts until it is over: no patience, no order card,
  /// and nothing can be handed over — they have not asked for anything yet.
  double varis = 0;

  bool get yerinde => varis >= 1;

  final double sabirToplam;
  double sabirKalan;

  bool anaUrunVerildi = false;
  bool tatliVerildi = false;
  bool icecekVerildi = false;

  /// Paid as items arrive rather than at the end, so closing the app never
  /// costs money already earned (design doc 11.4).
  int odenen = 0;

  double get sabirOrani => (sabirKalan / sabirToplam).clamp(0, 1);

  bool get bekliyorTatli => order.tatli != null && !tatliVerildi;
  bool get bekliyorIcecek => order.icecek != null && !icecekVerildi;

  bool get tamamlandi => anaUrunVerildi && !bekliyorTatli && !bekliyorIcecek;

  bool get hicAlmadi => odenen == 0;

  MusteriHali get hal => switch (this) {
    _ when !yerinde => MusteriHali.yuruyor,
    _ when sabirOrani > 0.8 => MusteriHali.bekliyorCokSakin,
    _ when sabirOrani > 0.6 => MusteriHali.bekliyorSakin,
    _ when sabirOrani > 0.4 => MusteriHali.bekliyorStabil,
    _ when sabirOrani > 0.2 => MusteriHali.bekliyorSupheli,
    _ => MusteriHali.bekliyorKizgin,
  };

  /// Served in full, served in part, or served nothing at all.
  MusteriHali get cikisHali => switch (this) {
    _ when tamamlandi => MusteriHali.gidiyorMutlu,
    _ when hicAlmadi => MusteriHali.gidiyorKizgin,
    _ => MusteriHali.gidiyorStabil,
  };

  /// A refusal costs a fifth of what is left, and the customer waits on with
  /// the same order.
  void reddet() => sabirKalan *= Balance.refusalKeeps;
}
