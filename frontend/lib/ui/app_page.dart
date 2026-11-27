import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.maxWidth,
    this.verticalGutter,
  });

  final Widget child;

  /// Defaults to [AppTokens.contentMaxWidth].
  final double? maxWidth;

  /// Overrides top and bottom padding without changing horizontal alignment.
  final double? verticalGutter;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final gutter = constraints.maxWidth < 600
            ? AppTokens.gutterCompact
            : AppTokens.gutterWide;
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: gutter,
              vertical: verticalGutter ?? gutter,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? AppTokens.contentMaxWidth,
              ),
              child: child,
            ),
          ),
        );
      },
    ),
  );
}

/// The page header: an optional back button, a semantic title, a subtitle and
/// right aligned actions.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.compactActionsAlignment = Alignment.centerRight,
    this.translateTitle = true,
  });

  final String? title;
  final String? subtitle;

  /// e.g. a back [IconButton].
  final Widget? leading;

  /// e.g. a [Wrap] of buttons.
  final Widget? actions;

  /// Alignment when actions appear below the title.
  final AlignmentGeometry compactActionsAlignment;

  final bool translateTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleBlock = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 580),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || leading != null)
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  if (title != null) const SizedBox(width: AppSpacing.md),
                ],
                if (title != null)
                  Flexible(
                    child: Semantics(
                      header: true,
                      child: Text(
                        translateTitle ? title!.tr : title!,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          if (subtitle != null) ...[
            if (title != null || leading != null)
              const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
    if (actions == null) return titleBlock;
    final actionsBlock = Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [actions!],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppTokens.bpDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: AppSpacing.xxl),
              actionsBlock,
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleBlock,
            const SizedBox(height: AppSpacing.lg),
            Align(alignment: compactActionsAlignment, child: actionsBlock),
          ],
        );
      },
    );
  }
}
