/// The only identity a free user has. The free-use counter hangs off it, which
/// is why it has to survive a reinstall — and why what leaves the phone is a
/// hash rather than the identifier.
abstract class DeviceIdentity {
  /// SHA-256 of the device identifier, lowercase hex.
  Future<String> hash();

  /// `ios` or `android`, as the API names them.
  String get platform;
}
