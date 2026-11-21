import 'package:flutter/material.dart';
import 'app_tokens.dart';

enum AppStatusTone { neutral, success, warning, error }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.compact = false,
    this.maxLines,
  });
  final String label;
  final AppStatusTone tone;
  final bool compact;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      AppStatusTone.success => (c.primaryContainer, c.onPrimaryContainer),
      AppStatusTone.warning => (c.secondaryContainer, c.onSecondaryContainer),
      AppStatusTone.error => (c.errorContainer, c.onErrorContainer),
      AppStatusTone.neutral => (c.surfaceContainerHighest, c.onSurface),
    };
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            )
          : const EdgeInsets.all(AppTokens.gutterCompact),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        label,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}
