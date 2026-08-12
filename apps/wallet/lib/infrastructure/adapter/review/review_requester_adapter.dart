import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:wallet/features/settings/domain/review_requester.dart';

/// [ReviewRequester] over `in_app_review`, which wraps
/// `SKStoreReviewController` on iOS and the Play In-App Review API on Android.
///
/// Reaches for `InAppReview.instance` itself rather than taking it: the type
/// is one injectable cannot resolve, and there is nothing to gain from
/// injecting a singleton the port already stands in front of.
@LazySingleton(as: ReviewRequester)
class ReviewRequesterAdapter implements ReviewRequester {
  const ReviewRequesterAdapter();

  InAppReview get _reviews => InAppReview.instance;

  @override
  Future<bool> isAvailable() => _reviews.isAvailable();

  @override
  Future<void> request() => _reviews.requestReview();
}
