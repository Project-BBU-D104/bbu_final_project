import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';

/// The shared list row: a flat card with a hairline border.
class AppListCard extends StatelessWidget {
  const AppListCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(
            alpha: AppTokens.borderAlpha,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
