/// What to do when a job keeps failing (after its retries are exhausted).
enum BootstrapErrorPolicy {
  /// Log the error and move on to the next job (optional work).
  skip,

  /// Halt the flow; the user restarts it from the error screen via "Retry".
  retry,

  /// Halt the flow; the error is unrecoverable and the app must be restarted.
  restart,
}

/// A single unit of work run during bootstrap.
///
/// Instead of a bare `Future<void> Function()`, each job carries its own rules
/// (retry count, error policy, fallback) declaratively.
class BootstrapJob {
  const BootstrapJob(
    this.name,
    this.run, {
    this.retries = 0,
    this.retryDelay = const Duration(milliseconds: 300),
    this.errorPolicy = BootstrapErrorPolicy.retry,
    this.fallback,
  });

  /// Human-readable name, used in logs and the failure state.
  final String name;

  /// The work to run.
  final Future<void> Function() run;

  /// Extra attempts after the first (`0` = a single attempt).
  final int retries;

  /// Delay between attempts.
  final Duration retryDelay;

  /// What to do once every attempt (and the [fallback], if any) has failed.
  final BootstrapErrorPolicy errorPolicy;

  /// Runs after all attempts are exhausted, before [errorPolicy] is applied.
  ///
  /// A manual recovery point — e.g. load defaults and carry on. Returning
  /// normally means the job is recovered and bootstrap continues; throwing
  /// hands control to [errorPolicy].
  final Future<void> Function(Object error)? fallback;
}
