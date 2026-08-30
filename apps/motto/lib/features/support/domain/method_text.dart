import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';

@immutable
class MethodSection {
  const MethodSection(this.heading, this.body);

  final String heading;
  final String body;
}

/// What the result is built on, and what it is not. The limitations section is
/// the point of the screen, not an appendix: saying plainly that an archetype
/// is an editorial reading is what keeps this on the right side of 1.4.1.
///
/// Read rather than held as a constant: a `const` list is built once, and once
/// is before anybody has said which language they read in.
List<MethodSection> get methodSections => [
  for (final key in const [
    'scale',
    'adaptation',
    'matching',
    'limits',
    'sources',
  ])
    MethodSection('method.$key.heading'.tr(), 'method.$key.body'.tr()),
];
