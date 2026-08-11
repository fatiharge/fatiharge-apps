import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:wallet/features/finance/domain/models/category.dart';

extension CategoryName on Category {
  /// Resolved per build, so a seeded category follows the current language
  /// rather than the one active when it was written.
  String displayName(BuildContext context) =>
      name ?? (nameKey == null ? null : context.tr(nameKey!)) ?? id;
}
