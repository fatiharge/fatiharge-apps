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

      await _store.save(bundle.toJson(), bundle.version);
      // Read back rather than keeping what toJson() returned. The generated
      // client writes nested lists as the model objects themselves and lets
      // jsonEncode convert them, so that map holds DTOs where this app expects
      // maps — it parses only after a trip through the file. Keeping it in
      // memory made the day's content fail on the launch that fetched it and
      // work on every launch after, which is the worst shape a bug can have.
      _loaded = await _store.readCached();
    } on Object {
      if (await current() == null) rethrow;
    }
  }
}
