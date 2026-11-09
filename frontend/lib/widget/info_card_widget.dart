import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  const InfoCardWidget({
    super.key,
    required this.title,
    this.icon,
    this.active,
    this.onTap,
    this.onSwitch,
  });

  final String title;
  final IconData? icon;
  final bool? active;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.iconTheme.color),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (active != null && onSwitch != null)
              Switch(value: active!, onChanged: onSwitch)
            else if (onTap != null)
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
