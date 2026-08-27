import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:motto/features/content/application/content_store.dart';

/// The content package: what was downloaded, or the server.
///
/// Nothing ships inside the app. A phone that has never been online has no
/// content and the flow stops there — a screen that is empty but pretends to
/// work is worse than one that says what is wrong.
@lazySingleton
class ContentRepository {
  ContentRepository(this._content, this._store);

  final api.ContentResourceApi _content;
  final ContentStore _store;

  Map<String, dynamic>? _loaded;

  /// Null when this device has never had a package.
  Future<Map<String, dynamic>?> current() async =>
      _loaded ??= await _store.readCached();

  /// Throws only when there is nothing to fall back on. A refresh that fails
  /// with a package already on the phone is not a failure anyone can see.
  Future<void> refresh() async {
    try {
      final bundle = await _content.contentBundle(
        ifNoneMatch: _store.version == null ? null : '"${_store.version}"',
      );
      if (bundle == null) return;

      final json = bundle.toJson();
      await _store.save(json, bundle.version);
      _loaded = json;
    } on Object {
      if (await current() == null) rethrow;
    }
  }
}
