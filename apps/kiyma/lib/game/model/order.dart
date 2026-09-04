import 'package:kiyma/game/balance.dart';
import 'package:kiyma/game/model/items.dart';
import 'package:kiyma/game/model/products.dart';

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

/// A customer at the counter: an order, a patience bar, and a record of which
/// line items have already been handed over.
class Customer {
  Customer({required this.order, required this.day})
    : sabirToplam = Balance.patience(day),
      sabirKalan = Balance.patience(day);

  final Order order;
  final int day;

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

  /// A refusal costs a fifth of what is left, and the customer waits on with
  /// the same order.
  void reddet() => sabirKalan *= Balance.refusalKeeps;
}
