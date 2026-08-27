/// The only identity a free user has.
///
/// There is no account until something is bought, so this is what the counter
/// of free uses hangs off — which is why it has to survive a reinstall, and why
/// what leaves the phone is a hash rather than the identifier itself.
abstract class DeviceIdentity {
  /// SHA-256 of the device identifier, lowercase hex.
  Future<String> hash();

  /// `ios` or `android`, as the API names them.
  String get platform;
}
