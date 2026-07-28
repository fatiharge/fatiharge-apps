import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wallet/features/about/domain/app_version_port.dart';

@LazySingleton(as: AppVersionPort)
class PackageInfoVersionAdapter implements AppVersionPort {
  @override
  Future<AppVersion> read() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion(name: info.version, build: info.buildNumber);
  }
}
