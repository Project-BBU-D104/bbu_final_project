import 'package:flutter/material.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

import 'audit_event.dart';
import 'widget/audit_card_widget.dart';

class AuditLogsScreen extends StatelessWidget {
  AuditLogsScreen({super.key});

  final controller = Get.find<AuditLogController>();

  @override
  Widget build(BuildContext context) {
    final desktop = DesktopAppShell.isVisible(context);
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      appBar: desktop
          ? null
          : CustomAppBar(
              title: 'Audit Logs',
              showBack: canGoBack,
              actions: [
                Obx(
                  () => IconButton(
                    tooltip: 'Refresh'.tr,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.getAuditLogs,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ],
            ),
      body: AppPage(
        child: LayoutBuilder(
          builder: (context, content) {
            final standardText =
                MediaQuery.textScalerOf(context).scale(16) <=
                AppTokens.tableMaxScaledBodySize;
            final useTable =
                content.maxWidth >= AppTokens.tableMinWidth && standardText;
            return Obx(() {
              final query = controller.search.keyword.value
                  .trim()
                  .toLowerCase();
              final action = controller.actionFilter.value;
              final loading = controller.isLoading.value;
              final failed = controller.loadFailed.value;
              final events = controller.auditLogs.map(AuditEvent.new).toList();
              final actions = {
                if (action.isNotEmpty) action,
                for (final event in events)
                  if (event.action.isNotEmpty) event.action,
              }.toList()..sort();
              final terms = query.isEmpty
                  ? <String>[]
                  : query.split(RegExp(r'\s+'));
              final matches = events
                  .where(
                    (event) =>
                        (action.isEmpty || event.action == action) &&
                        event.matches(terms),
                  )
                  .toList();
              void openEvent(AuditEvent event) =>
                  controller.gotoAuditLogDetail(event.data);

              return RefreshIndicator(
                onRefresh: controller.getAuditLogs,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (desktop) ...[
                            AppPageHeader(
                              title: 'Audit Logs',
                              leading: canGoBack
                                  ? IconButton.outlined(
                                      tooltip: 'Back'.tr,
                                      onPressed: () => Get.back<void>(),
                                      icon: const Icon(Icons.arrow_back),
                                    )
                                  : null,
                              actions: OutlinedButton.icon(
                                onPressed: loading
                                    ? null
                                    : controller.getAuditLogs,
                                icon: const Icon(Icons.refresh),
                                label: Text('Refresh'.tr),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                          _filters(
                            sideBySide:
                                content.maxWidth >= AppTokens.bpFormPair &&
                                standardText,
                            action: action,
                            actions: actions,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (loading && events.isNotEmpty) ...[
                            LinearProgressIndicator(
                              semanticsLabel: 'Loading audit history'.tr,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (failed) ...[
                            AppSectionCard(
                              child: Semantics(
                                liveRegion: true,
                                child: Wrap(
                                  spacing: AppSpacing.md,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('Unable to load audit history.'.tr),
                                    TextButton(
                                      onPressed: controller.getAuditLogs,
                                      child: Text('Retry'.tr),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (matches.isNotEmpty && !useTable) ...[
                            Text(
                              '@count audit events'.trParams({
                                'count': '${matches.length}',
                              }),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),
                    if (loading && events.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Loading audit history'.tr,
                          ),
                        ),
                      )
                    else if (matches.isEmpty && !(failed && events.isEmpty))
                      SliverToBoxAdapter(
                        child: AppEmptyState(
                          icon: events.isEmpty
                              ? Icons.history
                              : Icons.search_off,
                          message: events.isEmpty
                              ? 'No audit events yet'
                              : 'No matching audit events',
                        ),
                      )
                    else if (matches.isNotEmpty && useTable)
                      SliverToBoxAdapter(
                        child: _AuditHistoryTable(
                          key: ValueKey((query, action)),
                          events: matches,
                          onOpen: openEvent,
                        ),
                      )
                    else if (matches.isNotEmpty)
                      SliverList.builder(
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final event = matches[index];
                          return AuditCardWidget(
                            event: event,
                            onTap: () => openEvent(event),
                          );
                        },
                      ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _filters({
    required bool sideBySide,
    required String action,
    required List<String> actions,
  }) {
    final search = AppSearchField(
      title: 'Search audit logs',
      searchController: controller.search,
    );
    final filter = DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Audit action'.tr),
      isExpanded: true,
      initialValue: action,
      items: [
        DropdownMenuItem(value: '', child: Text('All actions'.tr)),
        for (final option in actions)
          DropdownMenuItem(
            value: option,
            child: Text(
              AuditEvent.actionLabel(option),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (value) => controller.actionFilter.value = value ?? '',
    );
    if (sideBySide) {
      return Row(
        children: [
          Expanded(flex: 2, child: search),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: filter),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        search,
        const SizedBox(height: AppSpacing.md),
        filter,
      ],
    );
  }
}

class _AuditHistoryTable extends StatefulWidget {
  const _AuditHistoryTable({
    super.key,
    required this.events,
    required this.onOpen,
  });

  final List<AuditEvent> events;
  final ValueChanged<AuditEvent> onOpen;

  @override
  State<_AuditHistoryTable> createState() => _AuditHistoryTableState();
}

class _AuditHistoryTableState extends State<_AuditHistoryTable> {
  static const _pageSize = 25;
  int _page = 0;

  int get _lastPage => (widget.events.length - 1) ~/ _pageSize;

  @override
  void didUpdateWidget(covariant _AuditHistoryTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page > _lastPage) _page = _lastPage;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.events.length;
    final start = _page * _pageSize;
    final page = widget.events.skip(start).take(_pageSize).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                (_lastPage == 0
                        ? '@count audit events'
                        : '@start–@end of @count audit events')
                    .trParams({
                      'start': '${start + 1}',
                      'end': '${start + page.length}',
                      'count': '$count',
                    }),
              ),
            ),
            if (_lastPage > 0) ...[
              IconButton.outlined(
                tooltip: 'Previous audit page'.tr,
                onPressed: _page > 0 ? () => setState(() => _page--) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.outlined(
                tooltip: 'Next audit page'.tr,
                onPressed: _page < _lastPage
                    ? () => setState(() => _page++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTable<AuditEvent>(
          rows: page,
          onRowTap: widget.onOpen,
          columns: [
            AppTableColumn(
              title: 'Audit event',
              flex: 3,
              builder: (context, event) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => widget.onOpen(event),
                  child: Tooltip(
                    message: event.displayTitle,
                    child: Text(
                      event.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            AppTableColumn(
              title: 'Audit action',
              flex: 2,
              builder: (context, event) =>
                  AuditActionBadge(action: event.action, singleLine: true),
            ),
            AppTableColumn(
              title: 'User',
              flex: 2,
              builder: (context, event) =>
                  AppTableColumn.value(context, event.actor),
            ),
            AppTableColumn(
              title: 'Affected record',
              flex: 2,
              builder: (context, event) =>
                  AppTableColumn.value(context, event.record),
            ),
            AppTableColumn(
              title: 'Recorded at',
              flex: 3,
              builder: (context, event) =>
                  AppTableColumn.value(context, event.displayTimestamp),
            ),
          ],
        ),
      ],
    );
  }
}
