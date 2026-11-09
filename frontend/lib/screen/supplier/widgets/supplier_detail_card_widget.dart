import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class SupplierDetailCardWidget extends StatelessWidget {
  SupplierDetailCardWidget({super.key});
  final ctr = Get.find<SupplierController>();

  @override
  Widget build(BuildContext context) {
    final argument = Get.arguments;
    final original = argument is SupplierModel ? argument : null;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Supplier Detail', useTheme: true),
      body: original == null
          ? Center(child: Text('No supplier data found'.tr))
          : Obx(() {
              final supplier = ctr.suppliers.firstWhere(
                (s) => original.id != null && s.id == original.id,
                orElse: () => original,
              );
              final theme = Theme.of(context);
              Widget info(String label, String? value) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.tr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText((value ?? '').trim().isEmpty ? '-' : value!),
                  ],
                ),
              );
              return LayoutBuilder(
                builder: (context, constraints) {
                  final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
                  final identity = HomeSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          supplier.name.isEmpty ? '-' : supplier.name,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        StatusWidget(
                          text:
                              (supplier.status == true ? 'Active' : 'Inactive')
                                  .tr,
                          color: supplier.status == true
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(height: 20),
                        info('Phone Number', supplier.phone),
                        info('Email', supplier.email),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: supplier.phone.trim().isEmpty
                                  ? null
                                  : () => callPhone(supplier.phone),
                              icon: const Icon(Icons.phone_outlined),
                              label: Text('Call supplier'.tr),
                            ),
                            OutlinedButton.icon(
                              onPressed: (supplier.email ?? '').trim().isEmpty
                                  ? null
                                  : () => openEmail(supplier.email!),
                              icon: const Icon(Icons.email_outlined),
                              label: Text('Email supplier'.tr),
                            ),
                            OutlinedButton.icon(
                              onPressed: usableMapValue(supplier.map) == null
                                  ? null
                                  : () => openGoogleMap(supplier.map!),
                              icon: const Icon(Icons.location_on_outlined),
                              label: Text('Open location'.tr),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                  final details = HomeSectionCard(
                    title: 'Supplier Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        info('Address', supplier.address),
                        info('Map', supplier.map),
                        info(
                          'Created At',
                          supplier.createdAt == null
                              ? null
                              : DateFormatter.formatDate(supplier.createdAt),
                        ),
                        info(
                          'Updated At',
                          supplier.updatedAt == null
                              ? null
                              : DateFormatter.formatDate(supplier.updatedAt),
                        ),
                      ],
                    ),
                  );
                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Padding(
                          padding: EdgeInsets.all(gutter),
                          child: LayoutBuilder(
                            builder: (context, content) =>
                                content.maxWidth < 900
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      identity,
                                      const SizedBox(height: 24),
                                      details,
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: identity),
                                      const SizedBox(width: 24),
                                      Expanded(child: details),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
      bottomNavigationBar: original == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: original.id == null
                          ? null
                          : () => ctr.deleteSupplier(
                              supplierId: original.id!,
                              context: context,
                            ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text('Delete'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        minimumSize: const Size(100, 48),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: original.id == null
                          ? null
                          : () => ctr.editSupplier(original.id!, context),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text('Edit'.tr),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
