import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:wallet/app/config/injectable.config.dart';

final GetIt getIt = GetIt.instance;

/// Wires every `@injectable` registration.
///
/// Runs as a bootstrap job, so a failure here stops startup with a visible
/// error instead of producing an app with half its dependencies missing.
@InjectableInit(asExtension: true)
Future<void> configureDependencies() => getIt.init();
