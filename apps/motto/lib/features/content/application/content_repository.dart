import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:motto/features/content/application/content_store.dart';

/// The content package: what was downloaded, what the app shipped with, then
/// the server. The first two are instant, because the day is assembled on the
/// phone.
@lazySingleton
class ContentRepository {
  ContentRepository(this._content, this._store);

  final api.ContentResourceApi _content;
  final ContentStore _store;

  Map<String, dynamic>? _loaded;

  Future<Map<String, dynamic>> current() async =>
      _loaded ??= await _store.readCached() ?? await _store.readBundled();

  /// A 304 comes back as null from the generated client: nothing to write.
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
      // The app already has a package to show.
      return;
    }
  }
}
