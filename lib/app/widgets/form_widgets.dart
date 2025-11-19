import 'package:flutter/material.dart';
import '../theme/widgets/theme_extensions.dart';

/// Custom dropdown field
class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool enabled;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
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
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
          ),
          style: context.bodyStyle,
          dropdownColor: context.surfaceColor,
        ),
      ],
    );
  }
}

/// Custom search field
class SearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: context.bodyStyle,
      decoration: InputDecoration(
        hintText: hint ?? 'Cari...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
      ),
    );
  }
}

/// Custom checkbox tile
class CustomCheckboxTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool?) onChanged;
  final Widget? secondary;

  const CustomCheckboxTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        title,
        style: context.bodyStyle,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.labelStyle,
            )
          : null,
      value: value,
      onChanged: onChanged,
      secondary: secondary,
      activeColor: context.primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

/// Custom radio tile
class CustomRadioTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final T groupValue;
  final void Function(T?) onChanged;
  final Widget? secondary;

  const CustomRadioTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: context.bodyStyle,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.labelStyle,
            )
          : null,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      secondary: secondary,
      activeColor: context.primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
