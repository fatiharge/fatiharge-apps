import 'package:flutter/material.dart';

/// Light and dark as two readings of one identity. One saturated accent on
/// near-neutral ground: the card has to stand out in a feed with no
/// illustration to do it, and a second colour starts competing.
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
