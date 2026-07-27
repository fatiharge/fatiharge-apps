import 'package:bootstrap_kit/src/domain/bootstrap_job.dart';

/// The app's side of the bootstrap boundary: it supplies the jobs to run and
/// decides what happens once they finish.
///
/// Deliberately free of Flutter. An earlier version also demanded the splash
/// widget, which dragged `package:flutter` into this domain layer and forced
/// UI into whatever class implemented the port — in practice an adapter
/// sitting in the app's infrastructure layer. What to *show* is the page's
/// business; the port only says what to *do*.
abstract class BootstrapPort {
  /// The ordered startup jobs to execute.
  List<BootstrapJob> jobs();

  /// Called once every job has completed successfully.
  void bootstrapFinished();
}
