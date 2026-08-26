sealed class DashboardEffect {
  const DashboardEffect();
}

/// The app has just done its job — a month with numbers in it is on screen,
/// for someone who has used the app long enough to have an opinion. The only
/// moment worth spending the store's review quota on.
class DashboardReviewMomentReached extends DashboardEffect {
  const DashboardReviewMomentReached();
}
