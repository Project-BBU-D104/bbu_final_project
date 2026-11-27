import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class PaymentActionsWidget extends StatelessWidget {
  const PaymentActionsWidget({super.key, this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return PopupMenuButton<String>(
      tooltip: 'Actions'.tr,
      enabled: onEdit != null || onDelete != null,
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit?.call();
        } else if (value == 'delete') {
          onDelete?.call();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          enabled: onEdit != null,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined),
              const SizedBox(width: AppSpacing.sm),
              Text('Edit'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          enabled: onDelete != null,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: errorColor),
              const SizedBox(width: AppSpacing.sm),
              Text('Delete'.tr, style: TextStyle(color: errorColor)),
            ],
          ),
        ),
      ],
    );
  }
}
