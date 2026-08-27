import 'package:motto/features/chain/domain/reminder.dart';

/// Everything a reminder says.
///
/// This file is the home for reminder copy — `content/README.md` points here
/// rather than holding it, because a notification has to render with no
/// network and nothing served can be relied on at the moment it fires.
///
/// The rule the whole file follows: **the chain is waiting for you, never how
/// many days you have missed.** A reminder that keeps score is a reminder that
/// gets the app deleted, and the one it would scold is the one already having
/// a bad week.
({String title, String body}) turkishReminderCopy(
  ReminderKind kind,
  int streak,
) => switch (kind) {
  ReminderKind.daily => (
    title: 'Zincirin seni bekliyor',
    body: streak == 0
        ? 'Bugün başlıyor. Bir dakikanı alacak.'
        : '$streak gün oldu. Bugünü de ekle.',
  ),
  ReminderKind.dayEnding => (
    title: 'Gün bitmeden',
    body: 'Bir dakika yeter, zincirin duruyor.',
  ),
  // The offer is in the same notification as the news, on purpose: telling
  // someone their chain stopped and then asking them to come back for the fix
  // is two interruptions about one thing.
  ReminderKind.broken => (
    title: 'Zincirin durdu',
    body: 'Bir günlük telafi hakkın var. Kaldığın yerden devam edebilirsin.',
  ),
  ReminderKind.freezeRenewed => (
    title: 'Telafi hakkın yenilendi',
    body: 'Bu ay bir gün kaçırsan da zincirin kalır.',
  ),
  ReminderKind.mottoReady => (
    title: 'Yeni mottona hazırsın',
    body: 'Bekleme süresi doldu.',
  ),
  ReminderKind.milestone => (
    title: '$streak gün',
    body: switch (streak) {
      7 => 'Bir hafta. En zor kısmı geçtin.',
      21 => 'Üç hafta. Artık kendiliğinden geliyor.',
      _ => 'Bir ay. Bunu sen yaptın.',
    },
  ),
};
