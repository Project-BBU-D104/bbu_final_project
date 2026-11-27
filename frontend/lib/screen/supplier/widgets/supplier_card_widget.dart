import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class SupplierCardWidget extends StatelessWidget {
  const SupplierCardWidget({super.key, required this.item});
  final SupplierModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = item.status == true ? 'Active' : 'Inactive';
    return AppListCard(
      onTap: () => Get.find<SupplierController>().gotoSupplierDetail(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Tooltip(
                  message: item.name,
                  child: Text(
                    item.name.isEmpty ? '-' : item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: StatusWidget(
                  text: status.tr,
                  status: status,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.phone.isEmpty ? '-' : item.phone),
          const SizedBox(height: 8),
          Tooltip(
            message: item.email ?? '',
            child: Text(
              (item.email ?? '').isEmpty ? '-' : item.email!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    IconButton(
                      tooltip: 'Call supplier'.tr,
                      onPressed: item.phone.trim().isEmpty
                          ? null
                          : () => callPhone(item.phone),
                      icon: const Icon(Icons.phone_outlined),
                    ),
                    IconButton(
                      tooltip: 'Email supplier'.tr,
                      onPressed: (item.email ?? '').trim().isEmpty
                          ? null
                          : () => openEmail(item.email!),
                      icon: const Icon(Icons.email_outlined),
                    ),
                    IconButton(
                      tooltip: 'Open location'.tr,
                      onPressed: usableMapValue(item.map) == null
                          ? null
                          : () => openGoogleMap(item.map!),
                      icon: const Icon(Icons.location_on_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.createdAt == null
                      ? '-'
                      : DateFormatter.formatDate(item.createdAt),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
