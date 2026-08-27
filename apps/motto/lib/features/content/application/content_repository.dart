import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:motto/features/content/application/content_store.dart';

/// The content package, from wherever it is freshest.
///
/// Three sources, in this order: what was downloaded, what the app shipped
/// with, and the server. The first two are instant and offline, which is the
/// whole point — the day someone reads is assembled on the phone, so a plane
/// or a dead cell is not a reason to show nothing.
@lazySingleton
class ContentRepository {
  ContentRepository(this._content, this._store);

  final api.ContentResourceApi _content;
  final ContentStore _store;

  Map<String, dynamic>? _loaded;

  /// What to show right now. Never waits on the network.
  Future<Map<String, dynamic>> current() async =>
      _loaded ??= await _store.readCached() ?? await _store.readBundled();

  /// Asks the server whether anything changed, and keeps it if so.
  ///
  /// A 304 comes back as null from the generated client, which is exactly the
  /// answer wanted: nothing to write, nothing to reload.
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
      // Silent: the app already has a package to show, and a failure here is
      // not a failure anyone can act on.
      return;
    }
  }
}
