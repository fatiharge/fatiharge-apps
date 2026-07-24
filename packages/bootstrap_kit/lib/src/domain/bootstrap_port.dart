import 'package:bootstrap_kit/src/domain/bootstrap_job.dart';
import 'package:flutter/widgets.dart';

/// The app's side of the bootstrap boundary: it supplies the jobs to run, the
/// view to show while they run, and what happens once they finish.
abstract class BootstrapPort {
  /// The ordered startup jobs to execute.
  List<BootstrapJob> jobs();

  /// The widget shown while bootstrap is running (e.g. a splash screen).
  Widget get bootstrapView;

  /// Called once every job has completed successfully.
  void bootstrapFinished();
}
