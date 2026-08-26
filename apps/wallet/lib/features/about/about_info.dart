import 'package:meta/meta.dart';

/// No email on purpose: GitHub issues are the only channel we commit to
/// answering.
@immutable
class Maintainer {
  const Maintainer(this.name, this.handle);

  final String name;

  final String handle;

  /// Qualified, because the page lists no other network to infer it from.
  String get mention => '@github/$handle';

  String get githubUrl => 'https://github.com/$handle';
}

const maintainers = [
  Maintainer('Fatih Çetin', 'fatiharge'),
  Maintainer('Damla Saymaz', 'damlasaymaz'),
];

const repositoryUrl = 'https://github.com/fatiharge/fatiharge-apps';

/// `template` values are filenames under `.github/ISSUE_TEMPLATE/`. Renaming
/// one there drops the parameter silently — GitHub just falls back.
const bugReportUrl = '$repositoryUrl/issues/new?template=bug_report.yml';

const featureRequestUrl =
    '$repositoryUrl/issues/new?template=feature_request.yml';
