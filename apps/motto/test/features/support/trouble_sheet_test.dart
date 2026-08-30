import 'package:api_client_motto/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/support/presentation/widgets/trouble_sheet.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    required Object failure,
    Future<void> Function()? retry,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    showTroubleSheet(context, failure: failure, retry: retry),
                child: const Text('yap'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('yap'));
    await tester.pumpAndSettle();
  }

  group('when something somebody pressed did not happen', () {
    testWidgets('a request that never arrived is a connection', (
      tester,
    ) async {
      await open(tester, failure: Exception('socket'));

      // The one thing the person can actually act on.
      expect(find.text('Bağlanamadım'), findsOneWidget);
      expect(
        find.text('İnternet bağlantını kontrol edip tekrar dene.'),
        findsOneWidget,
      );
    });

    testWidgets('a request the server answered is ours to own', (tester) async {
      await open(tester, failure: api.ApiException(500, 'boom'));

      // No status code reaches the screen: that is a fact about our server,
      // not about anything they can do.
      expect(find.text('Olmadı'), findsOneWidget);
      expect(find.textContaining('500'), findsNothing);
      expect(find.textContaining('Bizim tarafımızda'), findsOneWidget);
    });

    testWidgets('it offers the thing again when there is one', (tester) async {
      var tried = 0;
      await open(
        tester,
        failure: Exception('socket'),
        retry: () async => tried++,
      );

      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();

      expect(tried, 1);
      expect(find.text('Bağlanamadım'), findsNothing);
    });

    testWidgets('and only closes when there is nothing to retry', (
      tester,
    ) async {
      await open(tester, failure: Exception('socket'));

      expect(find.text('Tekrar dene'), findsNothing);
      expect(find.text('Tamam'), findsOneWidget);
    });
  });
}
