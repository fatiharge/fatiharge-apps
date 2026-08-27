package com.dafalabs.motto

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * The day, on the home screen.
 *
 * Needs no permission, which is why it exists: for someone who said no to
 * notifications this is the only daily contact left, and asking again is not
 * something iOS or good manners allow.
 *
 * It renders whatever the app last wrote and never fetches anything itself — a
 * widget that talks to the network is a widget that shows a spinner on a lock
 * screen.
 */
class MottoWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.motto_widget).apply {
                setTextViewText(
                    R.id.widget_day,
                    widgetData.getString("widget_day", "") ?: "",
                )
                setTextViewText(
                    R.id.widget_action,
                    widgetData.getString("widget_action", "") ?: "",
                )
                setTextViewText(
                    R.id.widget_streak,
                    widgetData.getString("widget_streak", "") ?: "",
                )
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
