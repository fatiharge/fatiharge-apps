import 'package:flutter/foundation.dart';

/// Flipped once the container exists.
///
/// `MaterialApp.builder` wraps the router, not the page, so it runs once — at
/// app start, when `configureDependencies` has not happened yet. Anything the
/// builder puts above the router therefore reads an empty container and never
/// gets a second chance. This is that second chance.
final ValueNotifier<bool> appReady = ValueNotifier(false);
