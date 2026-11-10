import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class SupplierDetailCardWidget extends StatelessWidget {
  SupplierDetailCardWidget({super.key})
    : _supplier = Get.arguments is SupplierModel
          ? Get.arguments as SupplierModel
          : null;
  final SupplierModel? _supplier;
  final ctr = Get.find<SupplierController>();

  Widget _actions(
    BuildContext context,
    SupplierModel supplier, {
    required bool desktop,
  }) => Obx(() {
    final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (desktop)
          IconButton.outlined(
            tooltip: 'Back'.tr,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
        OutlinedButton.icon(
          onPressed: busy || supplier.id == null
              ? null
              : () => ctr.deleteSupplier(
                  supplierId: supplier.id!,
                  context: context,
                ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, 48),
            foregroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text('Delete'.tr),
        ),
        FilledButton.icon(
          onPressed: busy || supplier.id == null
              ? null
              : () => ctr.editSupplier(supplier.id!, context),
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('Edit'.tr),
        ),
      ],
    );
  });

  @override
  Widget build(BuildContext context) {
    final original = _supplier;
    final desktop = DesktopAppShell.isVisible(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final active = theme.brightness == Brightness.light
        ? colors.primaryContainer
        : colors.primary;
    return Theme(
      data: theme.copyWith(
        dividerColor: colors.onSurface.withValues(alpha: 0.08),
        dividerTheme: DividerThemeData(
          color: colors.onSurface.withValues(alpha: 0.08),
          thickness: 1,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            side: BorderSide(color: colors.onSurface.withValues(alpha: 0.12)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: desktop
            ? null
            : const CustomAppBar(title: 'Supplier Detail', useTheme: true),
        body: original == null
            ? Center(child: Text('No supplier data found'.tr))
            : Obx(() {
                final supplier = ctr.suppliers.firstWhere(
                  (s) => original.id != null && s.id == original.id,
                  orElse: () => original,
                );
                final error = ctr.formError.value;
                Widget info(String label, String? value) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        (value ?? '').trim().isEmpty ? '-' : value!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
                final contact = HomeSectionCard(
                  title: 'Contact details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.business_outlined,
                              size: 24,
                              color: active,
                            ),
                          ),
                          const SizedBox(width: 12),
                          StatusWidget(
                            text:
                                (supplier.status == true
                                        ? 'Active'
                                        : 'Inactive')
                                    .tr,
                            color: supplier.status == true
                                ? active
                                : colors.onSurface,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      info('Phone Number', supplier.phone),
                      info('Email', supplier.email),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: supplier.phone.trim().isEmpty
                                ? null
                                : () => callPhone(supplier.phone),
                            icon: const Icon(Icons.phone_outlined, size: 18),
                            label: Text('Call supplier'.tr),
                          ),
                          OutlinedButton.icon(
                            onPressed: (supplier.email ?? '').trim().isEmpty
                                ? null
                                : () => openEmail(supplier.email!),
                            icon: const Icon(Icons.email_outlined, size: 18),
                            label: Text('Email supplier'.tr),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                final location = HomeSectionCard(
                  title: 'Location details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info('Address', supplier.address),
                      info('Map', supplier.map),
                      OutlinedButton.icon(
                        onPressed: usableMapValue(supplier.map) == null
                            ? null
                            : () => openGoogleMap(supplier.map!),
                        icon: const Icon(Icons.location_on_outlined, size: 18),
                        label: Text('Open location'.tr),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth >= 400
                                  ? (constraints.maxWidth - 20) / 2
                                  : constraints.maxWidth,
                              child: info(
                                'Created At',
                                supplier.createdAt == null
                                    ? null
                                    : DateFormatter.formatDate(
                                        supplier.createdAt,
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth >= 400
                                  ? (constraints.maxWidth - 20) / 2
                                  : constraints.maxWidth,
                              child: info(
                                'Updated At',
                                supplier.updatedAt == null
                                    ? null
                                    : DateFormatter.formatDate(
                                        supplier.updatedAt,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                return HomeTabLayout(
                  translateTitle: false,
                  title: supplier.name.isEmpty ? '-' : supplier.name,
                  subtitle: 'Supplier Detail',
                  action: desktop
                      ? _actions(context, supplier, desktop: true)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              error,
                              style: TextStyle(color: colors.error),
                            ),
                          ),
                        ),
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 900
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: contact),
                                  const SizedBox(width: 24),
                                  Expanded(child: location),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  contact,
                                  const SizedBox(height: 24),
                                  location,
                                ],
                              ),
                      ),
                    ],
                  ),
                );
              }),
        bottomNavigationBar: original == null || desktop
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _actions(context, original, desktop: false),
                ),
              ),
      ),
    );
  }
}
