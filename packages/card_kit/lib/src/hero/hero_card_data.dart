import 'package:flutter/foundation.dart';

/// Everything the hero card draws, and nothing else.
///
/// Not the record it came from: a card that took a domain object would have to
/// be given a whole news item to show a title and a picture, and every field it
/// did not draw would still have to be fetched, sent and parsed.
@immutable
class HeroCardData {
  const HeroCardData({
    required this.imageUrl,
    required this.headline,
    this.eyebrow,
  });

  /// Null or empty draws the placeholder rather than collapsing the card.
  final String? imageUrl;

  final String headline;

  /// A category, a time, a competition. Absent on most cards.
  final String? eyebrow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeroCardData &&
          other.imageUrl == imageUrl &&
          other.headline == headline &&
          other.eyebrow == eyebrow;

  @override
  int get hashCode => Object.hash(imageUrl, headline, eyebrow);
}
