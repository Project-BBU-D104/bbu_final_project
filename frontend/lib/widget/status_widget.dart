import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final String text;
  final Color? color;

  const StatusWidget({
    super.key,
    required this.text,
    this.color,
  });

  Color _getColor(BuildContext context) {
    if (color != null) return color!;

    // Auto color based on status text (optional smart behavior)
    switch (text.toLowerCase()) {
      case "verified":
        return Colors.green;
      case "on hold":
        return Colors.red;
      case "pending":
        return Colors.orange;
      case "in stock":
        return Colors.green;
      case "low stock":
        return Colors.yellow;
      case "in transit":
        return Colors.green;
      case "out of stock":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _getColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}