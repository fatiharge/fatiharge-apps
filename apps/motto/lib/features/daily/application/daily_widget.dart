import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

/// Pushes the day onto the home screen.
///
/// Written whenever the day or the chain changes, and never fetched by the
/// widget itself: a widget that talks to the network is a widget that shows a
/// spinner on somebody's home screen.
///
/// Every call is best-effort. There may be no widget placed at all, and a
/// failure here must never be able to break the screen that triggered it.
@lazySingleton
class DailyWidget {
  const DailyWidget();

  static const androidName = 'MottoWidgetProvider';

  Future<void> publish(DailyContent content, {required int streak}) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'widget_day',
        '${content.day}. GÜN',
      );
      await HomeWidget.saveWidgetData<String>('widget_action', content.action);
      await HomeWidget.saveWidgetData<String>(
        'widget_streak',
        streak > 0 ? '$streak gün' : 'Zincir bekliyor',
      );
      await HomeWidget.updateWidget(androidName: androidName);
    } on Object {
      return;
    }
  }
}
