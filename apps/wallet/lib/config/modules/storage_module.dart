import 'package:injectable/injectable.dart';
import 'package:wallet/infrastructure/storage/wallet_storage.dart';

/// `@preResolve` makes `configureDependencies()` await the boxes, so by the
/// time any repository is resolved its box is guaranteed to be open.
@module
abstract class StorageModule {
  @preResolve
  @singleton
  Future<WalletStorage> get storage => WalletStorage.open();
}
