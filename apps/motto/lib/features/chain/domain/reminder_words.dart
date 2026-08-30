import 'package:easy_localization/easy_localization.dart';
import 'package:motto/features/chain/domain/reminder.dart';

/// Everything a reminder says. Lives here rather than in `content/` because a
/// notification has to render with no network; that README points at this file.
///
/// The rule: the chain is waiting for you, never how many days you have
/// missed. One that keeps score gets the app deleted.
///
/// The file used to be named for Turkish, when Turkish was the only language
/// there was. What is left here is which sentence belongs to which kind of
/// reminder — the same in every language; the sentences themselves moved to
/// the translation files.
({String title, String body}) reminderWords(ReminderKind kind, int streak) =>
    switch (kind) {
      ReminderKind.daily => (
        title: 'reminder.daily.title'.tr(),
        body: streak == 0
            ? 'reminder.daily.first'.tr()
            : 'reminder.daily.body'.plural(streak),
      ),
      ReminderKind.dayEnding => (
        title: 'reminder.dayEnding.title'.tr(),
        body: 'reminder.dayEnding.body'.tr(),
      ),
      // The offer rides with the news: two notifications about one thing is two
      // interruptions.
      ReminderKind.broken => (
        title: 'reminder.broken.title'.tr(),
        body: 'reminder.broken.body'.tr(),
      ),
      ReminderKind.freezeRenewed => (
        title: 'reminder.freezeRenewed.title'.tr(),
        body: 'reminder.freezeRenewed.body'.tr(),
      ),
      ReminderKind.mottoReady => (
        title: 'reminder.mottoReady.title'.tr(),
        body: 'reminder.mottoReady.body'.tr(),
      ),
      ReminderKind.milestone => (
        title: 'reminder.milestone.title'.plural(streak),
        body: switch (streak) {
          7 => 'reminder.milestone.week'.tr(),
          21 => 'reminder.milestone.threeWeeks'.tr(),
          _ => 'reminder.milestone.month'.tr(),
        },
      ),
    };
