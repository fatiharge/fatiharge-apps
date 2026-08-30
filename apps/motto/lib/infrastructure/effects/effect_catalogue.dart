import 'package:motto/infrastructure/effects/effect.dart';

/// Where the definitions come from.
///
/// An interface because the answer moves: written in code while the engine is
/// being proven, then downloaded and cached like any other content the app is
/// told. Nothing above this line changes when it does.
// ignore: one_member_abstracts
abstract class EffectCatalogue {
  /// Null when this code has no definition. The caller reads that as "we do
  /// not know what to do about this", which is a different thing from "there
  /// is nothing to do".
  List<Effect>? forCode(String code);
}

/// The definitions the app ships with.
///
/// A stand-in for the downloaded catalogue, and the reason the engine can be
/// finished and tested before the endpoint exists.
class WrittenCatalogue implements EffectCatalogue {
  const WrittenCatalogue(this._byCode);

  final Map<String, List<Effect>> _byCode;

  @override
  List<Effect>? forCode(String code) => _byCode[code];
}
