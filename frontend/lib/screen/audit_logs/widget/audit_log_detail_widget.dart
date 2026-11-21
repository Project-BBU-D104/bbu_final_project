import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

import '../audit_event.dart';
import 'audit_card_widget.dart';

class AuditLogDetailWidget extends StatelessWidget {
  const AuditLogDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final event = args is Map && args.keys.every((key) => key is String)
        ? AuditEvent(Map<String, dynamic>.from(args))
        : null;
    final desktop = DesktopAppShell.isVisible(context);
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      appBar: desktop
          ? null
          : CustomAppBar(title: 'Audit event details', showBack: canGoBack),
      body: AppPage(
        child: LayoutBuilder(
          builder: (context, content) {
            final standardText =
                MediaQuery.textScalerOf(context).scale(16) <=
                AppTokens.tableMaxScaledBodySize;
            return SelectionArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      title: event?.displayTitle ?? 'Audit event details',
                      translateTitle: event == null,
                      leading: desktop && canGoBack
                          ? IconButton.outlined(
                              tooltip: 'Back'.tr,
                              onPressed: () => Get.back<void>(),
                              icon: const Icon(Icons.arrow_back),
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (event == null)
                      const AppEmptyState(
                        icon: Icons.history,
                        message: 'Audit event unavailable',
                      )
                    else ...[
                      _metadata(
                        event,
                        paired:
                            standardText &&
                            content.maxWidth >= AppTokens.bpFormPair,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _snapshots(
                        event,
                        context,
                        paired:
                            standardText &&
                            content.maxWidth >= AppTokens.bpTwoColumn,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _metadata(AuditEvent event, {required bool paired}) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AuditActionBadge(action: event.action),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AuditPair(
            paired: paired,
            first: _AuditValue(label: 'User'.tr, value: event.actor),
            second: _AuditValue(
              label: 'Recorded at'.tr,
              value: event.displayTimestamp,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AuditPair(
            paired: paired,
            first: _AuditValue(label: 'Audit table'.tr, value: event.table),
            second: _AuditValue(label: 'Record ID'.tr, value: event.recordId),
          ),
        ],
      ),
    );
  }

  Widget _snapshots(
    AuditEvent event,
    BuildContext context, {
    required bool paired,
  }) {
    final before = _decode(event.data['old_value']);
    final after = _decode(event.data['new_value']);
    final hasBefore = before != null && (before is! Map || before.isNotEmpty);
    final hasAfter = after != null && (after is! Map || after.isNotEmpty);
    if (!hasBefore && !hasAfter) {
      return AppSectionCard(
        title: 'Recorded values',
        child: Text('No values recorded'.tr),
      );
    }
    if (before is Map &&
        after is Map &&
        (hasBefore && hasAfter || event.action == 'UPDATE')) {
      final changed = <Object?>[];
      final unchanged = <Object?>[];
      for (final key in {...before.keys, ...after.keys}) {
        final same =
            before.containsKey(key) &&
            after.containsKey(key) &&
            _sameValue(before[key], after[key]);
        (same ? unchanged : changed).add(key);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (changed.isNotEmpty)
            AppSectionCard(
              title: 'Changed fields',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, key) in changed.indexed) ...[
                    if (index > 0) const Divider(height: AppSpacing.xxl),
                    Text(
                      key.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _AuditPair(
                      paired: paired,
                      first: _AuditValue(
                        label: 'Before'.tr,
                        value: before.containsKey(key)
                            ? _valueText(before[key])
                            : null,
                      ),
                      second: _AuditValue(
                        label: 'After'.tr,
                        value: after.containsKey(key)
                            ? _valueText(after[key])
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (unchanged.isNotEmpty) ...[
            if (changed.isNotEmpty) const SizedBox(height: AppSpacing.lg),
            _snapshot('Unchanged fields', {
              for (final key in unchanged) key: before[key],
            }),
          ],
        ],
      );
    }

    if (!hasBefore) return _snapshot('After', after);
    if (!hasAfter) return _snapshot('Before', before);
    return _AuditPair(
      paired: paired,
      first: _snapshot('Before', before),
      second: _snapshot('After', after),
    );
  }

  Widget _snapshot(String title, Object? value) {
    return AppSectionCard(
      title: title,
      child: value is Map
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, entry) in value.entries.indexed) ...[
                  if (index > 0) const Divider(height: AppSpacing.xxl),
                  _AuditValue(
                    label: entry.key.toString(),
                    value: _valueText(entry.value),
                  ),
                ],
              ],
            )
          : Text(_valueText(value)),
    );
  }

  Object? _decode(Object? value) {
    if (value is! String) return value;
    if (value.trim().isEmpty) return null;
    try {
      return jsonDecode(value);
    } on FormatException {
      return value;
    }
  }

  String _valueText(Object? value) {
    if (value is String) return value.isEmpty ? 'Empty text'.tr : value;
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  bool _sameValue(Object? before, Object? after) {
    if (before is Map && after is Map) {
      return before.length == after.length &&
          before.keys.every(
            (key) =>
                after.containsKey(key) && _sameValue(before[key], after[key]),
          );
    }
    if (before is List && after is List) {
      return before.length == after.length &&
          before.indexed.every(
            (entry) => _sameValue(entry.$2, after[entry.$1]),
          );
    }
    return before == after;
  }
}

class _AuditValue extends StatelessWidget {
  const _AuditValue({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(text == null || text.isEmpty ? 'Not recorded'.tr : text),
      ],
    );
  }
}

class _AuditPair extends StatelessWidget {
  const _AuditPair({
    required this.paired,
    required this.first,
    required this.second,
  });

  final bool paired;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    if (paired) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: second),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        first,
        const SizedBox(height: AppSpacing.md),
        second,
      ],
    );
  }
}
