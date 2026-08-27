import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';
import 'package:motto/features/daily/domain/daily_content.dart';

/// Written whenever the day or the chain changes, never fetched by the widget
/// itself — one that talks to the network shows a spinner on a home screen.
/// Best-effort: there may be no widget placed at all.
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
