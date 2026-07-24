/// State of the bootstrap flow.
sealed class BootstrapState {
  const BootstrapState();
}

/// Jobs are running. Progress is expressed as [completed]/[total]; the UI
/// derives the ratio from [progress].
class BootstrapRunning extends BootstrapState {
  const BootstrapRunning({required this.completed, required this.total});

  final int completed;
  final int total;

  /// Completion ratio in the range `0.0 .. 1.0`.
  double get progress => total == 0 ? 0 : completed / total;
}

/// A job failed and the flow stopped.
class BootstrapFailed extends BootstrapState {
  const BootstrapFailed({
    required this.jobName,
    required this.error,
    required this.canRetry,
    this.stackTrace,
  });

  final String jobName;
  final Object error;

  /// Stack trace captured where the error was caught (for logging/debugging).
  final StackTrace? stackTrace;

  /// `true` under the `retry` policy (the UI shows "Retry"); `false` under
  /// `restart` (the app must be restarted).
  final bool canRetry;
}
