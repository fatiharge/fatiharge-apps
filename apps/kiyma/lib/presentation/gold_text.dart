/// A price a player can read at a glance.
///
/// The late shop is priced in hundreds of millions, and a tag reading
/// 1180000000 is a smear of noughts on a piece of paper thirty pixels wide.
/// Three significant figures and a letter is what every game of this shape
/// does, and it is what makes the difference between two rungs legible.
String goldText(num value) {
  final n = value.abs();
  if (n < 1000) return '${value.round()}';
  for (final (limit, suffix) in const [
    (1000000000, 'b'),
    (1000000, 'm'),
    (1000, 'k'),
  ]) {
    if (n < limit) continue;
    final scaled = value / limit;
    // One decimal under ten, none above: 1.2m, then 12m.
    return scaled.abs() < 10
        ? '${scaled.toStringAsFixed(1)}$suffix'
        : '${scaled.round()}$suffix';
  }
  return '${value.round()}';
}
