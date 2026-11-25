import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportDateRangeFields extends StatelessWidget {
  const ReportDateRangeFields({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onChooseStart,
    required this.onChooseEnd,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onChooseStart;
  final VoidCallback onChooseEnd;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd MMM yyyy');

    Widget dateField(String label, DateTime date, VoidCallback onTap) =>
        TextFormField(
          key: ValueKey('$label-${date.toIso8601String()}'),
          initialValue: format.format(date),
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            labelText: label.tr,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final start = dateField('Start date', startDate, onChooseStart);
        final end = dateField('End date', endDate, onChooseEnd);
        if (constraints.maxWidth >= AppTokens.bpFormPair) {
          return Row(
            children: [
              Expanded(child: start),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: end),
            ],
          );
        }
        return Column(
          children: [
            start,
            const SizedBox(height: AppSpacing.lg),
            end,
          ],
        );
      },
    );
  }
}
