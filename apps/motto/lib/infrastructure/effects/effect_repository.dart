import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:motto/infrastructure/effects/effect.dart';
import 'package:motto/infrastructure/effects/effect_catalogue.dart';
import 'package:motto/infrastructure/effects/effect_store.dart';

/// The catalogue, from the server or from the last time it answered.
///
/// Unlike the content package this one is allowed to be missing. An app with
/// no definitions still works: every refusal reads as a code nobody wrote for,
/// which already has an answer. That is why nothing here throws.
/// Registered under its own name as well as the interface: the bootstrap job
/// has to ask it to refresh, and `as:` alone leaves the concrete type
/// unregistered — the job threw, was skipped because it is allowed to be, and
/// the catalogue silently never arrived.
@lazySingleton
class EffectRepository implements EffectCatalogue {
  EffectRepository(this._effects, this._store);

  final api.EffectResourceApi _effects;
  final EffectStore _store;

  Map<String, List<Effect>> _loaded = const {};

  @override
  List<Effect>? forCode(String code) => _loaded[code];

  /// Reads what is on the phone, then asks whether anything changed.
  Future<void> refresh() async {
    _loaded = _read(await _store.readCached());

    try {
      final catalogue = await _effects.errorEffects(
        ifNoneMatch: _store.version == null ? null : '"${_store.version}"',
      );
      if (catalogue == null) return;

      final byCode = <String, dynamic>{
        for (final entry in catalogue.codes) entry.code: entry.definition,
      };
      await _store.save(byCode, catalogue.version);
      _loaded = _read(byCode);
    } on Object {
      // Whatever is already on the phone stays. Definitions are how an app
      // answers refusals well, not whether it answers them at all.
    }
  }

  /// A definition that will not read is dropped rather than half-kept: the
  /// engine treats a missing code as unknown, which is exactly right for one
  /// this app cannot run.
  Map<String, List<Effect>> _read(Map<String, dynamic>? stored) {
    if (stored == null) return const {};

    final byCode = <String, List<Effect>>{};
    for (final entry in stored.entries) {
      final effects = Effect.listFrom(entry.value);
      if (effects != null) byCode[entry.key] = effects;
    }
    return byCode;
  }
}
