package com.undiyal.fintracker.deepblue

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Widget provider for Undiyal expense tracker
 * Handles updates for all three widget sizes (small, medium, large)
 */
class UndiayalWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update all widgets
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // Get widget data from SharedPreferences
        val widgetData = HomeWidgetPlugin.getData(context)
        val spent = widgetData.getFloat("spent", 0f).toDouble()
        val budget = widgetData.getFloat("budget", 15000f).toDouble()
        val percentage = widgetData.getFloat("percentage", 0f).toDouble()
        val remaining = widgetData.getFloat("remaining", 0f).toDouble()
        val lastCategory = widgetData.getString("lastCategory", "No expenses")
        val lastAmount = widgetData.getFloat("lastAmount", 0f).toDouble()
        val lastTime = widgetData.getString("lastTime", "Start tracking!")
        val lastIcon = widgetData.getString("lastIcon", "📊")
        val colorHex = widgetData.getString("colorHex", "#00FF88")
        val hasExpenses = widgetData.getBoolean("hasExpenses", false)
        
        // Format amounts
        val spentFormatted = "${spent.toInt()} \$"
        val budgetFormatted = "${budget.toInt()} \$"
        val lastAmountFormatted = if (hasExpenses) "- ${lastAmount.toInt()} \$" else ""
        val budgetDisplay = "${spent.toInt()} / ${budget.toInt()} \$"
        val remainingFormatted = "${remaining.toInt()} \$ remaining"
        val percentageText = "${percentage.toInt()}% used"
        
        // Get widget info to determine size
        val widgetInfo = appWidgetManager.getAppWidgetInfo(appWidgetId)
        val widgetLayout = when {
            widgetInfo.minWidth <= 110 -> R.layout.undiyal_widget_small
            widgetInfo.minWidth <= 250 -> R.layout.undiyal_widget_medium
            else -> R.layout.undiyal_widget_large
        }
        
        val views = RemoteViews(context.packageName, widgetLayout)
        
        // Parse color
        val progressColor = try {
            Color.parseColor(colorHex)
        } catch (e: Exception) {
            Color.parseColor("#00FF88")
        }
        
        // Update views based on widget size
        when (widgetLayout) {
            R.layout.undiyal_widget_small -> {
                views.setTextViewText(R.id.widget_budget_display, budgetDisplay)
                views.setProgressBar(R.id.widget_progress_small, 100, percentage.toInt(), false)
                views.setTextViewText(R.id.widget_last_icon_small, lastIcon)
                views.setTextViewText(R.id.widget_last_amount_small, "${lastAmount.toInt()} \$")
                
                // Setup click for add button
                val addIntent = getAddExpenseIntent(context)
                views.setOnClickPendingIntent(R.id.widget_add_button_small, addIntent)
            }
            
            R.layout.undiyal_widget_medium -> {
                views.setTextViewText(R.id.widget_spent, spentFormatted)
                views.setTextViewText(R.id.widget_budget, budgetFormatted)
                views.setProgressBar(R.id.widget_progress, 100, percentage.toInt(), false)
                views.setTextViewText(R.id.widget_last_icon, lastIcon)
                views.setTextViewText(R.id.widget_last_category, lastCategory)
                views.setTextViewText(R.id.widget_last_amount, lastAmountFormatted)
                
                // Setup click for add button
                val addIntent = getAddExpenseIntent(context)
                views.setOnClickPendingIntent(R.id.widget_add_button, addIntent)
            }
            
            R.layout.undiyal_widget_large -> {
                views.setTextViewText(R.id.widget_spent_large, spentFormatted)
                views.setTextViewText(R.id.widget_budget_large, budgetFormatted)
                views.setTextViewText(R.id.widget_percentage, percentageText)
                views.setProgressBar(R.id.widget_progress_large, 100, percentage.toInt(), false)
                views.setTextViewText(R.id.widget_remaining, remainingFormatted)
                views.setTextViewText(R.id.widget_last_icon_large, lastIcon)
                views.setTextViewText(R.id.widget_last_category_large, lastCategory)
                views.setTextViewText(R.id.widget_last_time, lastTime ?: "")
                views.setTextViewText(R.id.widget_last_amount_large, lastAmountFormatted)
                
                // Setup click for add button
                val addIntent = getAddExpenseIntent(context)
                views.setOnClickPendingIntent(R.id.widget_add_button_large, addIntent)
            }
        }
        
        // Set click listener for widget itself (opens app)
        val openAppIntent = getOpenAppIntent(context)
        views.setOnClickPendingIntent(R.id.widget_spent, openAppIntent)
        
        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    /**
     * Create intent to open app to add expense screen
     */
    private fun getAddExpenseIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = "ADD_EXPENSE"
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
    
    /**
     * Create intent to open app to home screen
     */
    private fun getOpenAppIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        return PendingIntent.getActivity(
            context,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    override fun onEnabled(context: Context) {
        // First widget is added
    }

    override fun onDisabled(context: Context) {
        // Last widget is removed
    }
}
