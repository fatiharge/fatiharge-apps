import 'package:flutter/material.dart';

/// The colours, once, so that light and dark are two readings of one identity
/// rather than two designs.
///
/// A single saturated accent on near-neutral ground: the result card has to
/// stand out in a feed without an illustration to do it, and one strong colour
/// against grey does that where a second one starts competing.
abstract final class MottoPalette {
  /// Deliberately not the indigo-violet the astrology apps share. The product
  /// claims to be an inventory, and looking like a horoscope undoes that before
  /// a word is read.
  static const seed = Color(0xFF1F8A70);

  static const lightSurface = Color(0xFFFAFAF8);
  static const lightInk = Color(0xFF14171A);

  static const darkSurface = Color(0xFF0E1116);
  static const darkElevated = Color(0xFF171B22);
  static const darkInk = Color(0xFFF2F4F5);
}
