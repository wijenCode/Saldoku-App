import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../models/savings_goal.dart';
import '../db/dao/bill_dao.dart';
import '../db/dao/budget_dao.dart';
import '../db/dao/savings_goal_dao.dart';
import 'shared_prefs_service.dart';

/// Service untuk mengelola notifikasi dan reminder
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final BillDao _billDao = BillDao();
  final BudgetDao _budgetDao = BudgetDao();
  final SavingsGoalDao _savingsGoalDao = SavingsGoalDao();

  /// Check if notifications are enabled
  Future<bool> get isEnabled async {
    return await SharedPrefsService.isNotificationEnabled();
  }

  /// Initialize notification service
  Future<void> init() async {
    // TODO: Initialize local notification plugin
    // In production, use flutter_local_notifications package
    debugPrint('NotificationService initialized');
  }

  /// Schedule bill reminder
  Future<void> scheduleBillReminder(Bill bill) async {
    if (!await isEnabled) return;

    // TODO: Schedule actual notification
    // Example: Schedule 1 day before due date
    final reminderDate = bill.dueDate.subtract(const Duration(days: 1));
    debugPrint('Scheduled bill reminder for ${bill.name} at $reminderDate');
  }

  /// Cancel bill reminder
  Future<void> cancelBillReminder(int billId) async {
    // TODO: Cancel scheduled notification
    debugPrint('Cancelled bill reminder for bill ID: $billId');
  }

  /// Get upcoming bills (within 7 days)
  Future<List<Bill>> getUpcomingBills(int userId) async {
    return await _billDao.getUpcoming(userId, 7);
  }

  /// Get overdue bills
  Future<List<Bill>> getOverdueBills(int userId) async {
    return await _billDao.getOverdue(userId);
  }

  /// Check budget alerts (when spending reaches threshold)
  Future<List<Map<String, dynamic>>> checkBudgetAlerts(int userId) async {
    final budgets = await _budgetDao.getActiveByUserId(userId);

    final alerts = <Map<String, dynamic>>[];

    for (var budget in budgets) {
      final spent = budget.spent;
      final percentage = (spent / budget.amount) * 100;

      // Alert at 80%, 90%, and 100%
      if (percentage >= 80) {
        alerts.add({
          'budget': budget,
          'percentage': percentage,
          'spent': spent,
          'severity': percentage >= 100
              ? 'critical'
              : percentage >= 90
                  ? 'high'
                  : 'medium',
        });
      }
    }

    return alerts;
  }

  /// Get savings goal progress notifications
  Future<List<Map<String, dynamic>>> getSavingsGoalProgress(int userId) async {
    final goals = await _savingsGoalDao.getByUserId(userId);
    final notifications = <Map<String, dynamic>>[];

    for (var goal in goals) {
      if (goal.status != 'active') continue;

      final progress = (goal.currentAmount / goal.targetAmount) * 100;

      // Notify at milestones: 25%, 50%, 75%, 100%
      if (progress >= 25 && progress < 30) {
        notifications.add({
          'goal': goal,
          'milestone': 25,
          'message': '25% tercapai! Terus semangat menabung!',
        });
      } else if (progress >= 50 && progress < 55) {
        notifications.add({
          'goal': goal,
          'milestone': 50,
          'message': 'Setengah jalan! Target 50% telah tercapai!',
        });
      } else if (progress >= 75 && progress < 80) {
        notifications.add({
          'goal': goal,
          'milestone': 75,
          'message': 'Hampir sampai! 75% target tercapai!',
        });
      } else if (progress >= 100) {
        notifications.add({
          'goal': goal,
          'milestone': 100,
          'message': 'Selamat! Target tabungan tercapai! 🎉',
        });
      }
    }

    return notifications;
  }

  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!await isEnabled) return;

    // TODO: Show actual notification using flutter_local_notifications
    debugPrint('Notification: $title - $body');
  }

  /// Show bill due reminder
  Future<void> showBillDueReminder(Bill bill) async {
    await showNotification(
      title: 'Tagihan Jatuh Tempo',
      body: '${bill.name} jatuh tempo pada ${bill.dueDate.toString().split(' ')[0]}',
      payload: 'bill:${bill.id}',
    );
  }

  /// Show budget warning
  Future<void> showBudgetWarning({
    required String categoryName,
    required double percentage,
  }) async {
    await showNotification(
      title: 'Peringatan Anggaran',
      body: 'Pengeluaran $categoryName sudah mencapai ${percentage.toStringAsFixed(0)}%',
      payload: 'budget_warning',
    );
  }

  /// Show savings goal achievement
  Future<void> showSavingsGoalAchievement(SavingsGoal goal) async {
    await showNotification(
      title: 'Target Tercapai! 🎉',
      body: 'Selamat! Target tabungan "${goal.name}" telah tercapai!',
      payload: 'savings_goal:${goal.id}',
    );
  }

  /// Get notification count
  Future<int> getNotificationCount(int userId) async {
    int count = 0;

    // Count upcoming bills
    final upcomingBills = await getUpcomingBills(userId);
    count += upcomingBills.length;

    // Count overdue bills
    final overdueBills = await getOverdueBills(userId);
    count += overdueBills.length;

    // Count budget alerts
    final budgetAlerts = await checkBudgetAlerts(userId);
    count += budgetAlerts.length;

    return count;
  }
}
