import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/role/widget/role_card_widget.dart';
import 'package:frontend/screen/role/widget/role_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class RoleScreen extends StatelessWidget {
  RoleScreen({super.key});

  final controller = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(title: 'Roles', useTheme: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.all(gutter),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              runSpacing: 16,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth < 600
                                        ? constraints.maxWidth - gutter * 2
                                        : 580,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (desktop) ...[
                                        Row(
                                          children: [
                                            IconButton.outlined(
                                              tooltip: 'Back'.tr,
                                              onPressed: Get.back,
                                              icon: const Icon(
                                                Icons.arrow_back,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Flexible(
                                              child: Semantics(
                                                header: true,
                                                child: Text(
                                                  'Roles'.tr,
                                                  style: theme
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Text(
                                        'Manage roles and access permissions.'
                                            .tr,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    IconButton.outlined(
                                      tooltip: 'Refresh'.tr,
                                      onPressed: controller.getRoles,
                                      icon: const Icon(Icons.refresh),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          controller.addRole(context),
                                      icon: const Icon(Icons.add),
                                      label: Text('Add Role'.tr),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            LayoutBuilder(
                              builder: (context, content) => Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 20,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: content.maxWidth < 440
                                        ? content.maxWidth
                                        : 420,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SearchWidget(
                                        title: 'Search Roles'.tr,
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      '${controller.searchRoleList.length} ${'Roles'.tr}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      SliverFillRemaining(
                        child: Obx(() {
                          final loading = controller.isListLoading.value;
                          final error = controller.loadError.value;
                          final items = controller.searchRoleList.toList();
                          if (loading && controller.roleList.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (loading)
                                const LinearProgressIndicator(minHeight: 2),
                              if (error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Wrap(
                                    spacing: 12,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'Unable to refresh roles'.tr,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: loading
                                            ? null
                                            : controller.getRoles,
                                        child: Text('Retry'.tr),
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                child: items.isEmpty
                                    ? _emptyState(context, error != null)
                                    : LayoutBuilder(
                                        builder: (context, content) {
                                          final table =
                                              content.maxWidth >= 800 &&
                                              MediaQuery.textScalerOf(
                                                    context,
                                                  ).scale(16) <=
                                                  20.8;
                                          return RefreshIndicator(
                                            onRefresh: controller.getRoles,
                                            child: table
                                                ? SingleChildScrollView(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    child: RoleTableWidget(
                                                      roles: items,
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemCount: items.length,
                                                    itemBuilder: (_, index) =>
                                                        RoleCardWidget(
                                                          role: items[index],
                                                        ),
                                                  ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, bool error) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              error
                  ? 'Unable to load roles'.tr
                  : (controller.roleList.isEmpty
                            ? 'No roles yet'
                            : 'No matching roles')
                        .tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
