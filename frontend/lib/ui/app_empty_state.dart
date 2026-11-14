import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';

/// The shared "nothing here yet" block.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.business_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: AppTokens.borderAlpha),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.onSurfaceVariant),
          const SizedBox(height: AppSpacing.lg),
          Text(message, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
