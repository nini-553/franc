package com.undiyal.fintracker.deepblue

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class UndiyalWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_small).apply {
                // Open App on Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.tv_today_spent, pendingIntent)

                // Get Data from Shared Prefs (saved by Flutter)
                val todaySpent = widgetData.getFloat("today_spent", 0.0f).toDouble()
                val streak = widgetData.getInt("current_streak", 0)

                // Update UI
                setTextViewText(R.id.tv_today_spent, "₹${todaySpent.toInt()}")
                setTextViewText(R.id.tv_streak, "$streak Day Streak")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
