/// Content cards for club apps.
///
/// One widget per card. A card takes a view model and an `onTap`, and does
/// nothing else: no network, no navigation, no data fetching. That is what lets
/// an editor preview the real card while composing it — the preview is the same
/// widget, not a copy that drifts.
///
/// Import this barrel; do not reach into `src/`.
library;

export 'src/common/index.dart';
export 'src/hero/index.dart';
