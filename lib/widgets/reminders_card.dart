import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/reminders_service.dart';
import '../screens/reminders/all_reminders_screen.dart';

class RemindersCard extends StatelessWidget {
  const RemindersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final urgentReminders = RemindersService.getUrgentReminders();
    final upcomingReminders = RemindersService.getUpcomingReminders();
    
    // Show urgent first, then upcoming (max 3 total)
    final displayReminders = [
      ...urgentReminders.take(2),
      ...upcomingReminders.where((r) => !urgentReminders.contains(r)).take(1),
    ];

    if (displayReminders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.bell,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Reminders', style: AppTextStyles.h3),
                ],
              ),
              if (urgentReminders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.urgentBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${urgentReminders.length} urgent',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.urgent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayReminders.asMap().entries.map((entry) {
            final index = entry.key;
            final reminder = entry.value;
            return Column(
              children: [
                _buildReminderTile(reminder),
                if (index < displayReminders.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: AppColors.divider),
                  ),
              ],
            );
          }).toList(),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const AllRemindersScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'View All Reminders',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTile(Reminder reminder) {
    final isUrgent = reminder.isUrgentStatus;
    final daysText = _getDaysText(reminder);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUrgent 
                  ? AppColors.urgentBackground
                  : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                reminder.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${reminder.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                daysText,
                style: AppTextStyles.caption.copyWith(
                  color: isUrgent ? AppColors.urgent : AppColors.textSecondary,
                  fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              if (isUrgent)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.urgent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDaysText(Reminder reminder) {
    if (reminder.isOverdue) {
      final daysOverdue = DateTime.now().difference(reminder.dueDate).inDays;
      return daysOverdue == 0 ? 'Overdue' : '${daysOverdue}d overdue';
    } else if (reminder.isDueToday) {
      return 'Today';
    } else if (reminder.isDueTomorrow) {
      return 'Tomorrow';
    } else {
      final days = reminder.daysUntilDue;
      return '${days}d left';
    }
  }
}