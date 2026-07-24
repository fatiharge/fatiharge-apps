/// App startup orchestration for the Fatiharge monorepo: a guarded crash
/// boundary and a retryable startup-job engine.
///
/// Import this barrel; do not reach into `src/` directly.
library;

export 'src/application/index.dart';
export 'src/crash/index.dart';
export 'src/domain/index.dart';
