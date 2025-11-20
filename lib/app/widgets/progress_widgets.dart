import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/widgets/theme_extensions.dart';

/// Widget untuk menampilkan progress bar
class ProgressBar extends StatelessWidget {
  final double percentage;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.percentage,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);
    final progressColor = color ?? _getColorByPercentage(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor:
                backgroundColor ??
                context.textColor.withAlpha((0.1 * 255).round()),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: context.labelSmallStyle.copyWith(
              color: progressColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorByPercentage(double percentage) {
    if (percentage >= 100) return AppColors.expense;
    if (percentage >= 80) return AppColors.warning;
    return AppColors.success;
  }
}

/// Widget untuk circular progress
class CircularProgress extends StatelessWidget {
  final double percentage;
  final Color? color;
  final double size;
  final double strokeWidth;
  final Widget? child;

  const CircularProgress({
    super.key,
    required this.percentage,
    this.color,
    this.size = 100,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);
    final progressColor = color ?? AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: context.textColor.withAlpha((0.1 * 255).round()),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          if (child != null)
            child!
          else
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: context.bodyBoldStyle.copyWith(
                fontSize: size / 4,
                color: progressColor,
              ),
            ),
        ],
      ),
    );
  }
}
