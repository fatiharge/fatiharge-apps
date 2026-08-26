import 'package:bootstrap_kit/bootstrap_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/domain/repository/category_repository.dart';
import 'package:wallet/features/settings/application/review_prompt.dart';
import 'package:wallet/features/settings/application/summary_reminder_controller.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/infrastructure/adapter/bootstrap/bootstrap_adapter.dart';
import 'package:wallet/route/app_router.dart';

import '../support/finance_fixtures.dart';
import '../support/in_memory_repositories.dart';

void main() {
  late FakeCategoryRepository categories;
  late FakeSettingsRepository settings;
  late FakeSummaryNotifier notifier;
  late SummaryReminderController reminders;
  final now = DateTime(2026, 8, 12);

  setUp(() async {
    categories = FakeCategoryRepository();
    settings = FakeSettingsRepository();
    notifier = FakeSummaryNotifier();
    reminders = SummaryReminderController(settings, notifier);
    await getIt.reset();
    getIt
      ..registerSingleton<RouteManager>(RouteManager())
      ..registerSingleton<CategoryRepository>(categories)
      ..registerSingleton<SettingsRepository>(settings)
      ..registerFactory<ReviewPrompt>(
        () => ReviewPrompt(settings, FakeReviewRequester(), clock: () => now),
      )
      ..registerSingleton<SummaryReminderController>(reminders);
  });

  tearDown(() async {
    await categories.dispose();
    await getIt.reset();
  });

  Future<void> run(String name) async {
    const adapter = BootstrapAdapter();
    final job = adapter.jobs().firstWhere((job) => job.name == name);
    await job.run();
  }

  group('BootstrapAdapter', () {
    test('storage runs before anything can read or write', () {
      const adapter = BootstrapAdapter();
      final names = adapter.jobs().map((job) => job.name).toList();

      expect(names.first, 'storage');
      expect(
        names.indexOf('dependencies'),
        lessThan(names.indexOf('seed_categories')),
      );
    });

    test('a storage failure restarts rather than skips', () {
      const adapter = BootstrapAdapter();
      final storage = adapter.jobs().firstWhere((job) => job.name == 'storage');

      expect(storage.errorPolicy, BootstrapErrorPolicy.restart);
    });

    test('seeding failure must not block startup', () {
      const adapter = BootstrapAdapter();
      final seed = adapter.jobs().firstWhere(
        (job) => job.name == 'seed_categories',
      );

      expect(seed.errorPolicy, BootstrapErrorPolicy.skip);
    });

    test('demo data stays out unless the build asks for it', () {
      const adapter = BootstrapAdapter();

      expect(
        adapter.jobs().map((job) => job.name),
        isNot(contains('demo_data')),
      );
    });

    test('seeds the default categories on a first launch', () async {
      await run('seed_categories');

      final seeded = await categories.fetchAll();
      expect(seeded, isNotEmpty);
      expect(seeded.map((c) => c.id), contains('food'));
    });

    test('seeding is skipped when categories already exist', () async {
      categories.seed([categoryOf('mine')]);

      await run('seed_categories');

      final after = await categories.fetchAll();
      expect(after.map((c) => c.id), ['mine']);
    });

    test('stamps the install date on a first launch, once', () async {
      await run('first_launch');
      expect(settings.installed, now);

      settings.installed = DateTime(2020);
      await run('first_launch');

      // A later launch must not move it, or the app would never be old enough
      // to ask for a review.
      expect(settings.installed, DateTime(2020));
    });

    test('pushes the reminder window forward on launch', () async {
      notifier.permitted = true;
      await reminders.enable(day: 9);
      notifier.scheduledDay = null;

      await run('reminder_window');

      // Only a fixed number of occurrences are ever scheduled, so a launch
      // that did not rewrite the window would let the reminder run out.
      expect(notifier.scheduledDay, 9);
    });
  });
}
