import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/features/finance/presentation/views/reminder_nudge.dart';

import '../../../support/widget_harness.dart';

void main() {
  testWidgets('offers both answers and reports which was given', (
    tester,
  ) async {
    var accepted = 0;
    var dismissed = 0;

    await pumpLocalized(
      tester,
      ReminderNudge(
        onAccept: () => accepted++,
        onDismiss: () => dismissed++,
      ),
    );

    expect(
      find.text('Her ayın özeti hazır olduğunda haber verelim mi?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Hayır, teşekkürler'));
    await tester.pumpAndSettle();
    expect(dismissed, 1);
    expect(accepted, 0);

    await tester.tap(find.text('Evet, hatırlat'));
    await tester.pumpAndSettle();
    expect(accepted, 1);
  });
}
