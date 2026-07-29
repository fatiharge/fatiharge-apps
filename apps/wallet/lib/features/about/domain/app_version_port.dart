/// The app's own version, as installed.
class AppVersion {
  const AppVersion({required this.name, required this.build});

  final String name;
  final String build;

  @override
  String toString() => '$name ($build)';
}

// A function typedef cannot be registered by type in get_it, which is how
// every other adapter here is wired.
// ignore: one_member_abstracts
abstract interface class AppVersionPort {
  Future<AppVersion> read();
}
