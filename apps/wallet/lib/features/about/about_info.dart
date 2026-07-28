import 'package:meta/meta.dart';

/// Who made the app and where to file issues.
///
/// Sits at the feature root rather than in `domain/` for the same reason
/// `default_categories.dart` does: it is feature *content*, not a rule. Keeping
/// it in one file means adding a name or repointing a link is a one-line change
/// that never touches a widget.
///
/// There is deliberately no email here: GitHub issues are the only channel we
/// commit to answering, and offering a second one that nobody watches is worse
/// than offering none.
@immutable
class Maintainer {
  const Maintainer(this.name, this.handle);

  final String name;

  /// The GitHub username. Shown next to [name] rather than hidden behind it —
  /// it is the part a reader can act on.
  final String handle;

  /// Spelled `@github/handle` rather than the bare `@handle`: the page lists
  /// no other network, so an unqualified handle would leave the reader
  /// guessing which one it belongs to.
  String get mention => '@github/$handle';

  String get githubUrl => 'https://github.com/$handle';
}

/// Listed owner-first, which is also the order they show up on the page.
const maintainers = [
  Maintainer('Fatih Çetin', 'fatiharge'),
  Maintainer('Damla Saymaz', 'damlasaymaz'),
];

const repositoryUrl = 'https://github.com/fatiharge/fatiharge-apps';

/// Deep links into the repository's issue forms, so a report lands with the
/// template already applied instead of on an empty issue body. The `template`
/// values are the filenames under `.github/ISSUE_TEMPLATE/` — renaming one
/// there silently drops the query parameter and GitHub falls back to the
/// chooser, so this never breaks loudly.
const bugReportUrl = '$repositoryUrl/issues/new?template=bug_report.yml';

const featureRequestUrl =
    '$repositoryUrl/issues/new?template=feature_request.yml';
