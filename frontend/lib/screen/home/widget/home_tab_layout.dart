import 'package:flutter/material.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class HomeTabLayout extends StatelessWidget {
  const HomeTabLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
    this.leading,
    this.translateTitle = true,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;
  final Widget? leading;
  final bool translateTitle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final theme = Theme.of(context);
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
                  constraints.maxWidth < 600
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
  const HomeSectionCard({super.key, this.title, required this.child});
  final String? title;
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
            theme.colorScheme.onSurface.withValues(alpha: AppTokens.borderAlpha),
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
              Semantics(
                header: true,
                child: Text(
                  title!.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
