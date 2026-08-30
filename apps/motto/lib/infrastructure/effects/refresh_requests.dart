import 'dart:async';

import 'package:injectable/injectable.dart';

/// Asks the screens to read everything again.
///
/// A definition can end with "and now go and look again" — after something was
/// fixed, or after a turn was earned somewhere else. The shell is the only
/// thing that knows what "everything" means, so it listens rather than being
/// called.
@lazySingleton
class RefreshRequests {
  final _asked = StreamController<void>.broadcast();

  Stream<void> get stream => _asked.stream;

  void ask() => _asked.add(null);

  @disposeMethod
  void close() => unawaited(_asked.close());
}
