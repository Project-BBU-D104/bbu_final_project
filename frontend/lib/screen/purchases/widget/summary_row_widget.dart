import 'package:flutter/material.dart';

class SummaryRowWidget extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  final Color? color;
  const SummaryRowWidget({super.key, required this.label, required this.value, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}