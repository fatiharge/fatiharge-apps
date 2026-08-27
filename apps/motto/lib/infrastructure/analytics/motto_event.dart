/// Every question the product asks of itself, named once. An enum because a
/// misspelled event name is a hole in a funnel that still looks plausible.
enum MottoEvent {
  appOpen('app_open'),
  testStart('test_start'),
  questionAnswered('question_answered'),
  testComplete('test_complete'),
  resultView('result_view'),
  shareSheetOpen('share_sheet_open'),
  shareComplete('share_complete'),
  paywallView('paywall_view'),
  purchaseComplete('purchase_complete'),
  chainStart('chain_start'),
  notifPermission('notif_permission'),
  chainDayMarked('chain_day_marked'),
  chainBroken('chain_broken'),
  dailyContentView('daily_content_view'),
  deeplinkOpen('deeplink_open'),
  inviteCodeUsed('invite_code_used'),
  feedbackSubmit('feedback_submit'),
  archetypeRejected('archetype_rejected');

  const MottoEvent(this.wireName);

  /// What the server stores. Detached from the Dart name so renaming the
  /// constant cannot silently split one metric into two.
  final String wireName;
}
