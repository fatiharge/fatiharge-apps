import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/domain/rules/summary_schedule.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// The monthly reminder switch and its day.
///
/// Shown both in settings and as a first-run step, so it carries no scaffold
/// of its own.
class ReminderSection extends StatefulWidget {
  const ReminderSection({super.key});

  @override
  State<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderSection> {
  final SummaryReminderController _controller =
      getIt<SummaryReminderController>();

  late bool _enabled = _controller.reminder.enabled;
  late int _day = _controller.reminder.day;
  bool _blocked = false;

  Future<void> _setEnabled({required bool enabled}) async {
    if (!enabled) {
      await _controller.disable();
      if (mounted) {
        setState(() {
          _enabled = false;
          _blocked = false;
        });
      }
      return;
    }

    final refusal = await _controller.enable(day: _day);
    if (!mounted) return;

    setState(() {
      _enabled = refusal == null;
      // Only the blocked case earns a message: a fresh "no" to the prompt is
      // an answer the user just gave and does not need explaining back.
      _blocked = refusal == ReminderRefusal.blocked;
    });
  }

  Future<void> _setDay(int day) async {
    setState(() => _day = day);
    if (_enabled) {
      await _controller.enable(day: day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          value: _enabled,
          onChanged: (value) => _setEnabled(enabled: value),
          secondary: const Icon(Icons.notifications_outlined),
          title: Text(context.tr(LocaleKeys.settings_reminder_enabled)),
        ),
        if (_blocked)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(LocaleKeys.settings_reminder_blocked),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                TextButton(
                  onPressed: _controller.openSystemSettings,
                  child: Text(
                    context.tr(LocaleKeys.settings_reminder_open_settings),
                  ),
                ),
              ],
            ),
          ),
        if (_enabled) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              context.tr(LocaleKeys.settings_reminder_day),
              style: theme.textTheme.labelLarge,
            ),
          ),
          _DayPicker(day: _day, onChanged: _setDay),
        ],
      ],
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.day, required this.onChanged});

  final int day;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (
          var value = SummarySchedule.firstDay;
          value <= SummarySchedule.lastDay;
          value++
        )
          ChoiceChip(
            label: Text('$value'),
            selected: value == day,
            onSelected: (_) => onChanged(value),
          ),
      ],
    ),
  );
}

/// The settings screen's version, with its own heading and explanation.
class ReminderSettings extends StatelessWidget {
  const ReminderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Text(
            context.tr(LocaleKeys.settings_reminder),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            context.tr(LocaleKeys.settings_reminder_hint),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const ReminderSection(),
      ],
    );
  }
}
