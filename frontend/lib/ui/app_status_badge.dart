import 'package:flutter/material.dart';
import 'app_tokens.dart';

enum AppStatusTone { neutral, success, warning, error }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
  });
  final String label;
  final AppStatusTone tone;
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
      padding: const EdgeInsets.all(AppTokens.gutterCompact),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}
