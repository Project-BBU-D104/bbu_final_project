import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
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
    return Card(
      color: theme.cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.find<SupplierController>().gotoSupplierDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.business_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusWidget(
                    text: (item.status == true ? 'Active' : 'Inactive').tr,
                    color: item.status == true
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  Text(
                    item.createdAt == null
                        ? '-'
                        : DateFormatter.formatDate(item.createdAt),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
