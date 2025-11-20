import 'package:flutter/material.dart';
import '../theme/widgets/theme_extensions.dart';
import 'package:intl/intl.dart';

/// Widget untuk date picker
class DatePickerField extends StatefulWidget {
  final String? label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime) onDateSelected;
  final String? Function(DateTime?)? validator;

  const DatePickerField({
    super.key,
    this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.validator,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.labelStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_today),
              errorText: widget.validator?.call(_selectedDate),
            ),
            child: Text(
              _selectedDate != null
                  ? DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!)
                  : 'Pilih tanggal',
              style:
                  _selectedDate != null
                      ? context.bodyStyle
                      : context.bodyStyle.copyWith(
                        color: context.textColor.withAlpha((0.5 * 255).round()),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget untuk time picker
class TimePickerField extends StatefulWidget {
  final String? label;
  final TimeOfDay? initialTime;
  final void Function(TimeOfDay) onTimeSelected;
  final String? Function(TimeOfDay?)? validator;

  const TimePickerField({
    super.key,
    this.label,
    this.initialTime,
    required this.onTimeSelected,
    this.validator,
  });

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      widget.onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.labelStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _selectTime(context),
          child: InputDecorator(
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.access_time),
              errorText: widget.validator?.call(_selectedTime),
            ),
            child: Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : 'Pilih waktu',
              style:
                  _selectedTime != null
                      ? context.bodyStyle
                      : context.bodyStyle.copyWith(
                        color: context.textColor.withAlpha((0.5 * 255).round()),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
