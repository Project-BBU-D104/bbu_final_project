import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:frontend/controllers/search_feature_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/card_feature_widget.dart';
import 'package:frontend/widget/search_feature_widget.dart';
import 'package:get/get.dart';

class FeatureDirectoryWidget extends StatelessWidget {
  const FeatureDirectoryWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchTitle,
    required this.searchController,
    required this.sections,
    required this.onNavigate,
    required this.maxColumns,
    this.stickySearch = false,
    this.alignContentStart = false,
  });
  final String title;
  final String subtitle;
  final String searchTitle;
  final SearchFeatureController searchController;
  final List<Map<String, dynamic>> sections;
  final ValueChanged<String> onNavigate;
  final int maxColumns;
  final bool stickySearch;
  final bool alignContentStart;

  @override
  Widget build(BuildContext context) => HomeTabLayout(
    title: title,
    subtitle: subtitle,
    alignContentStart: alignContentStart,
    pinnedChild: stickySearch
        ? SearchFeatureWidget(title: searchTitle, ctr: searchController)
        : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!stickySearch) ...[
          SearchFeatureWidget(title: searchTitle, ctr: searchController),
          const SizedBox(height: AppSpacing.xxxl),
        ],
        if (sections.isEmpty)
          HomeSectionCard(
            child: Column(
              children: [
                Icon(
                  Icons.search_off_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No matching results'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search or clear the filter.'.tr,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: searchController.clear,
                  child: Text('Clear search'.tr),
                ),
              ],
            ),
          ),
        for (final section in sections) ...[
          Semantics(
            header: true,
            child: Text(
              section['title'].toString().tr,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = math.max(
                1.0,
                MediaQuery.textScalerOf(context).scale(14) / 14,
              );
              final fittingColumns = math.max(
                1,
                ((constraints.maxWidth + AppSpacing.lg) /
                        (AppTokens.featureCardMinWidth * textScale +
                            AppSpacing.lg))
                    .floor(),
              );
              final columns = math.min(maxColumns, fittingColumns);
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final item in section['items'] as List)
                    SizedBox(
                      width:
                          (constraints.maxWidth -
                              AppSpacing.lg * (columns - 1)) /
                          columns,
                      child: CardFeatureWidget(
                        title: item['title'],
                        icon: item['icon'],
                        onTap: () => onNavigate(item['route']),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ],
    ),
  );
}
