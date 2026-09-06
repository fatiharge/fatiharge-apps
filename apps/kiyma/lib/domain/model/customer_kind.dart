import 'package:kiyma/domain/balance.dart';

/// What kind of customer walked in.
///
/// Every customer used to be the same person with a different shopping list,
/// so a run had one texture from the first day to the tenth. These change how
/// a visit *plays* — how long you have, what it pays, whether the order holds
/// still — using only the ticket, because there is no character art and none
/// is coming.
///
/// The weights and the day each becomes possible live here rather than in
/// `Balance` because they are what the type *is*, the same way a trade
/// profile carries its own multipliers.
enum CustomerKind {
  /// One order, one constraint, ordinary patience. Still the commonest
  /// customer on every day: the specials read as specials only because most
  /// people are not one.
  siradan(gun: 1, agirlik: 150),

  /// Less time, more money. The first special, because it needs no
  /// explaining — the bar just drains faster.
  aceleci(gun: 3, agirlik: 24),

  /// Two things they will not have instead of one.
  titiz(gun: 4, agirlik: 22),

  /// Leaves a tip if they are still calm when it lands.
  comert(gun: 5, agirlik: 20),

  /// Changes their mind once, halfway through waiting.
  kararsiz(gun: 6, agirlik: 16),

  /// Two products on one ticket. Held back until the plate line is open:
  /// two wraps is the same job twice, where a wrap and a plate is a
  /// different job — and until then there is only one line to work.
  kalabalik(gun: 7, agirlik: 14, kilit: 'porsiyon_hatti');

  const CustomerKind({
    required this.gun,
    required this.agirlik,
    this.kilit,
  });

  /// The first day this can turn up. Early days stay plain on purpose.
  final int gun;

  /// How likely it is against the others, once it is possible.
  final int agirlik;

  /// An unlock that has to be open first, or null.
  final String? kilit;

  bool get ozel => this != siradan;

  /// What the main product is worth to this person. Here rather than in the
  /// rules because the ticket has to print the same number the till pays.
  double get odemeCarpani => switch (this) {
    aceleci => Balance.aceleciOdeme,
    titiz => Balance.titizOdeme,
    _ => 1,
  };
}
