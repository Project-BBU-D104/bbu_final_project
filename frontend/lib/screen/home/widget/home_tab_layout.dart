import 'package:flutter/material.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class HomeTabLayout extends StatelessWidget {
  const HomeTabLayout({
    super.key,
    this.title,
     this.subtitle,
    required this.child,
    this.action,
    this.leading,
    this.pinnedChild,
    this.alignContentStart = false,
    this.translateTitle = true,
  });
  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? action;
  final Widget? leading;
  final Widget? pinnedChild;
  final bool alignContentStart;
  final bool translateTitle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final theme = Theme.of(context);
      if (pinnedChild != null) {
        final gutter = constraints.maxWidth < AppTokens.bpPageGutter
            ? AppTokens.gutterCompact
            : AppTokens.gutterWide;

        Widget constrained(Widget child) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: alignContentStart
                ? SizedBox(width: double.infinity, child: child)
                : child,
          ),
        );

        return Material(
          color: theme.scaffoldBackgroundColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: constrained(
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      gutter,
                      gutter,
                      AppSpacing.xl,
                    ),
                    child: AppPageHeader(
                      title: title,
                      subtitle: subtitle,
                      leading: leading,
                      actions: action,
                      translateTitle: translateTitle,
                    ),
                  ),
                ),
              ),
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: theme.scaffoldBackgroundColor,
                  child: constrained(
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        gutter,
                        AppSpacing.sm,
                        gutter,
                        AppSpacing.lg,
                      ),
                      child: pinnedChild!,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: constrained(
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      AppSpacing.lg,
                      gutter,
                      gutter,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Material(
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.contentMaxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  constraints.maxWidth < AppTokens.bpPageGutter
                      ? AppTokens.gutterCompact
                      : AppTokens.gutterWide,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppPageHeader(
                      title: title,
                      subtitle: subtitle,
                      leading: leading,
                      actions: action,
                      translateTitle: translateTitle,
                    ),
                    const SizedBox(height: 28),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class HomeSectionCard extends StatelessWidget {
  const HomeSectionCard({
    super.key,
    this.title,
    this.action,
    required this.child,
  });
  final String? title;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: BorderSide(
          color: Color.alphaBlend(
            theme.colorScheme.onSurface.withValues(
              alpha: AppTokens.borderAlpha,
            ),
            theme.cardColor,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title!.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (action != null) action!,
                ],
              ),
              const SizedBox(height: 20),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
