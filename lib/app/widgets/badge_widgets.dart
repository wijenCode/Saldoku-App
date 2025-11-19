import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/widgets/theme_extensions.dart';

/// Badge widget untuk menampilkan status
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    this.color,
    this.icon,
  });

  factory StatusBadge.success(String text) {
    return StatusBadge(
      text: text,
      color: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  factory StatusBadge.warning(String text) {
    return StatusBadge(
      text: text,
      color: AppColors.warning,
      icon: Icons.warning,
    );
  }

  factory StatusBadge.error(String text) {
    return StatusBadge(
      text: text,
      color: AppColors.expense,
      icon: Icons.error,
    );
  }

  factory StatusBadge.info(String text) {
    return StatusBadge(
      text: text,
      color: AppColors.info,
      icon: Icons.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: badgeColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: context.labelSmallStyle.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Counter badge untuk notifikasi
class CounterBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const CounterBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.expense,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: context.labelSmallStyle.copyWith(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
