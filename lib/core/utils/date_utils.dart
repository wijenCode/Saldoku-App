import 'package:intl/intl.dart';

/// Utility untuk format dan manipulasi tanggal
class AppDateUtils {
  /// Format tanggal ke string (default: dd MMM yyyy)
  static String format(
    DateTime date, {
    String pattern = 'dd MMM yyyy',
    String locale = 'id_ID',
  }) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }

  /// Format tanggal dengan waktu (default: dd MMM yyyy, HH:mm)
  static String formatWithTime(
    DateTime date, {
    String pattern = 'dd MMM yyyy, HH:mm',
    String locale = 'id_ID',
  }) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }

  /// Format waktu saja (default: HH:mm)
  static String formatTime(
    DateTime date, {
    String pattern = 'HH:mm',
    String locale = 'id_ID',
  }) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }

  /// Format relative (Hari ini, Kemarin, 2 hari lalu, dll)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference == -1) {
      return 'Besok';
    } else if (difference > 1 && difference < 7) {
      return '$difference hari lalu';
    } else if (difference < -1 && difference > -7) {
      return '${difference.abs()} hari lagi';
    } else {
      return format(date);
    }
  }

  /// Format relative dengan waktu (5 menit lalu, 2 jam lalu, dll)
  static String formatRelativeWithTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return format(date);
    }
  }

  /// Parse string ke DateTime
  static DateTime? parse(String dateString, {String pattern = 'yyyy-MM-dd'}) {
    try {
      final formatter = DateFormat(pattern);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get first day of week (Monday)
  static DateTime getFirstDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Get last day of week (Sunday)
  static DateTime getLastDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  /// Get month name in Indonesian
  static String getMonthName(int month, {bool short = false}) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final monthsShort = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    if (month < 1 || month > 12) return '';
    return short ? monthsShort[month - 1] : months[month - 1];
  }

  /// Get day name in Indonesian
  static String getDayName(int weekday, {bool short = false}) {
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];

    final daysShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    if (weekday < 1 || weekday > 7) return '';
    return short ? daysShort[weekday - 1] : days[weekday - 1];
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is in current month
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is in current year
  static bool isCurrentYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Get date range for period
  static Map<String, DateTime> getDateRange(String period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (period.toLowerCase()) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'week':
        startDate = getFirstDayOfWeek(now);
        endDate = getLastDayOfWeek(now);
        break;
      case 'month':
        startDate = getFirstDayOfMonth(now);
        endDate = getLastDayOfMonth(now);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    return {'startDate': startDate, 'endDate': endDate};
  }

  /// Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  /// Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Format duration (1:30:45 -> 1 jam 30 menit)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours jam ${minutes > 0 ? "$minutes menit" : ""}';
    } else if (minutes > 0) {
      return '$minutes menit ${seconds > 0 ? "$seconds detik" : ""}';
    } else {
      return '$seconds detik';
    }
  }

  /// Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
  }

  /// Add business days (skip weekend)
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (!isWeekend(result)) {
        addedDays++;
      }
    }

    return result;
  }
}
