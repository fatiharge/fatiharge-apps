import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:wallet/infrastructure/storage/wallet_storage.dart';

/// `Hive.initFlutter()` cannot be used here — it goes through `path_provider`,
/// which needs platform channels. `Hive.init(path)` is the same thing minus the
/// directory lookup, so these tests exercise the actual storage code rather
/// than a stand-in for it.
class HiveHarness {
  late Directory _directory;
  late WalletStorage storage;

  Future<void> open() async {
    _directory = await Directory.systemTemp.createTemp('wallet_hive_test');
    Hive.init(_directory.path);
    storage = await WalletStorage.open();
  }

  /// This is the check that matters for any change to how records are
  /// encoded: it proves the bytes on disk can be read back, not just that an
  /// in-memory map survived a round trip.
  Future<void> reopen() async {
    await Hive.close();
    storage = await WalletStorage.open();
  }

  Future<void> close() async {
    await Hive.deleteFromDisk();
    if (_directory.existsSync()) {
      await _directory.delete(recursive: true);
    }
  }
}
