import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:motto/infrastructure/api/outcome.dart';

/// The failures that mean the same thing wherever they happen.
///
/// A dead session and a door we should not have offered do not become
/// different problems because a different screen was asking. Answering them in
/// every cubit is how one meaning turns into six sentences, so they are said
/// once, above the tabs.
///
/// What does *not* come through here is [Refused]: a named refusal is the one
/// kind that means something local — the screen that asked is the only thing
/// that knows what to do about it.
@lazySingleton
class TroubleBus {
  final _troubles = StreamController<Trouble>.broadcast();

  Stream<Trouble> get stream => _troubles.stream;

  /// Called from `asked`. What the shell cannot answer is dropped here rather
  /// than at the listener, so the stream only carries what it can.
  void add(Trouble trouble) {
    if (trouble is SessionOver || trouble is NotAllowed) {
      _troubles.add(trouble);
    }
  }

  @disposeMethod
  void close() => unawaited(_troubles.close());
}
