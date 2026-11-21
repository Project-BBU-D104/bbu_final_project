import 'package:flutter/material.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_status_badge.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

import '../audit_event.dart';

class AuditCardWidget extends StatelessWidget {
  const AuditCardWidget({super.key, required this.event, required this.onTap});

  final AuditEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final contextLine = [
      if (event.actor.isNotEmpty) event.actor,
      if (event.record.isNotEmpty) event.record,
    ].join(' · ');
    return AppListCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.displayTitle, style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                AuditActionBadge(action: event.action),
                if (contextLine.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(contextLine),
                ],
                if (event.timestamp.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(event.displayTimestamp, style: text.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class AuditActionBadge extends StatelessWidget {
  const AuditActionBadge({
    super.key,
    required this.action,
    this.singleLine = false,
  });

  final String action;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final tone = switch (action) {
      'CREATE' || 'LOGIN' => AppStatusTone.success,
      'UPDATE' => AppStatusTone.warning,
      'DELETE' => AppStatusTone.error,
      _ => AppStatusTone.neutral,
    };
    return Tooltip(
      message: action.isEmpty ? 'Unknown action'.tr : action,
      excludeFromSemantics: true,
      child: AppStatusBadge(
        label: AuditEvent.actionLabel(action),
        tone: tone,
        compact: true,
        maxLines: singleLine ? 1 : null,
      ),
    );
  }
}
