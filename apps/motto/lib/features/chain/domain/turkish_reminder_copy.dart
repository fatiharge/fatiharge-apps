import 'package:motto/features/chain/domain/reminder.dart';

/// Everything a reminder says. Lives here rather than in `content/` because a
/// notification has to render with no network; that README points at this file.
///
/// The rule: the chain is waiting for you, never how many days you have
/// missed. One that keeps score gets the app deleted.
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
  // The offer rides with the news: two notifications about one thing is two
  // interruptions.
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
