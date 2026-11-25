import 'package:flutter/material.dart';

class ReportVisibilityCheckbox extends StatelessWidget {
  const ReportVisibilityCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Flexible(child: Text(label)),
        ],
      ),
    ),
  );
}
