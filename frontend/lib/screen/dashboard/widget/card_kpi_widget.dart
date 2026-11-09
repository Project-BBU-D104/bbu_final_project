import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardKpiWidget extends StatelessWidget {
  const CardKpiWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.status,
  });
  final IconData icon;
  final String title;
  final String value;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(height: 24),
            Text(
              title.tr,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (status != null) ...[
              const SizedBox(height: 12),
              Text(status!.tr, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
