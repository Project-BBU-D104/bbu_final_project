import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/search_widget.dart';

/// The bordered search box every list screen wraps around [SearchWidget].
class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, required this.title, this.showScan = false});

  final String title;
  final bool showScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(
            alpha: AppTokens.borderAlpha,
          ),
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusControl),
      ),
      child: SearchWidget(title: title, showScan: showScan),
    );
  }
}
