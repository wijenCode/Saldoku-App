import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/widgets/theme_extensions.dart';

/// Widget untuk menampilkan jumlah uang dengan format yang konsisten
class MoneyDisplay extends StatelessWidget {
  final double amount;
  final String? currency;
  final TextStyle? style;
  final bool showSign;
  final bool isIncome;
  final MainAxisAlignment alignment;

  const MoneyDisplay({
    super.key,
    required this.amount,
    this.currency = 'Rp',
    this.style,
    this.showSign = false,
    this.isIncome = true,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = _formatCurrency(amount.abs());
    final sign = showSign ? (isIncome ? '+' : '-') : '';
    final color = showSign
        ? (isIncome ? AppColors.success : AppColors.expense)
        : null;

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          '$sign$currency $formattedAmount',
          style: style?.copyWith(color: color) ??
              context.bodyBoldStyle.copyWith(color: color),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

/// Widget untuk input jumlah uang
class MoneyInput extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final String currency;

  const MoneyInput({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.currency = 'Rp',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.labelStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          style: context.bodyStyle,
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                currency,
                style: context.bodyStyle,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
          ),
        ),
      ],
    );
  }
}
