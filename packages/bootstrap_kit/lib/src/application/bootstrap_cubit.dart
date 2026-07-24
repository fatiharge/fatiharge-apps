import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:bootstrap_kit/src/application/bootstrap_state.dart';
import 'package:bootstrap_kit/src/domain/bootstrap_job.dart';
import 'package:bootstrap_kit/src/domain/bootstrap_port.dart';

/// Runs the [BootstrapPort]'s jobs in order, applying each job's retry and
/// error policy, and emits progress until the flow finishes or stops on a
/// failure that can be retried from where it left off.
class BootstrapCubit extends Cubit<BootstrapState> {
  BootstrapCubit(this._port)
    : super(const BootstrapRunning(completed: 0, total: 0));

  final BootstrapPort _port;

  /// Minimum time the running state stays visible, so the view does not flash.
  static const _minDuration = Duration(seconds: 1);

  List<BootstrapJob>? _jobs;
  int _resumeFrom = 0;

  /// Starts the flow from the first job.
  Future<void> start() async {
    _jobs = _port.jobs();
    _resumeFrom = 0;
    await _execute();
  }

  /// Re-runs from the job that last failed (used by the "Retry" action).
  Future<void> retry() => _execute();

  Future<void> _execute() async {
    final jobs = _jobs ??= _port.jobs();

    final minWait = Future<void>.delayed(_minDuration);

    final completed = await _runJobs(jobs, from: _resumeFrom);
    if (!completed) return; // BootstrapFailed emitted; the flow stopped.

    await minWait;
    _port.bootstrapFinished();
  }

  /// Runs [jobs] in order starting at [from]. On a `retry`/`restart` failure it
  /// emits [BootstrapFailed], records the resume point, and returns `false`.
  Future<bool> _runJobs(List<BootstrapJob> jobs, {int from = 0}) async {
    emit(BootstrapRunning(completed: from, total: jobs.length));

    for (var i = from; i < jobs.length; i++) {
      final job = jobs[i];
      var failure = await _runWithRetry(job);

      // Attempts exhausted — try to recover through the fallback.
      if (failure != null && job.fallback != null) {
        failure = await _runFallback(job, failure.error);
      }

      if (failure != null) {
        if (job.errorPolicy == BootstrapErrorPolicy.skip) {
          developer.log(
            'Job "${job.name}" skipped after failure (errorPolicy: skip)',
            name: 'bootstrap',
            error: failure.error,
            stackTrace: failure.stackTrace,
          );
        } else {
          _resumeFrom = i; // retry resumes here.
          emit(
            BootstrapFailed(
              jobName: job.name,
              error: failure.error,
              stackTrace: failure.stackTrace,
              canRetry: job.errorPolicy == BootstrapErrorPolicy.retry,
            ),
          );
          return false;
        }
      }

      emit(BootstrapRunning(completed: i + 1, total: jobs.length));
    }

    return true;
  }

  /// Runs the fallback. Returns `null` on success (recovered); if the fallback
  /// itself throws, returns that error so the policy is applied.
  Future<({Object error, StackTrace stackTrace})?> _runFallback(
    BootstrapJob job,
    Object originalError,
  ) async {
    try {
      await job.fallback!(originalError);
      return null;
    } on Object catch (error, stackTrace) {
      developer.log(
        'Fallback for job "${job.name}" failed',
        name: 'bootstrap',
        error: error,
        stackTrace: stackTrace,
      );
      return (error: error, stackTrace: stackTrace);
    }
  }

  /// Attempts [job] up to [BootstrapJob.retries] extra times. Returns `null` on
  /// success or the last error (with its stack trace) otherwise; every failed
  /// attempt is logged.
  Future<({Object error, StackTrace stackTrace})?> _runWithRetry(
    BootstrapJob job,
  ) async {
    var attempt = 0;
    while (true) {
      try {
        await job.run();
        return null;
      } on Object catch (error, stackTrace) {
        developer.log(
          'Job "${job.name}" failed (attempt ${attempt + 1}/${job.retries + 1})',
          name: 'bootstrap',
          error: error,
          stackTrace: stackTrace,
        );
        if (attempt >= job.retries) {
          return (error: error, stackTrace: stackTrace);
        }
        attempt++;
        await Future<void>.delayed(job.retryDelay);
      }
    }
  }
}
