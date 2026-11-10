import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:frontend/utils/currency_formatter.dart';

class ProductCardDetailWidget extends StatelessWidget {
  ProductCardDetailWidget({super.key})
    : _snapshot = Get.arguments is Map<String, dynamic>
          ? Get.arguments as Map<String, dynamic>
          : <String, dynamic>{};

  // Captured once: opening the edit modal replaces Get.arguments.
  final Map<String, dynamic> _snapshot;

  // Reuse the controller registered by the product list workflow.
  final ctr = Get.find<ProductController>();

  Widget _actions(BuildContext context, Map<String, dynamic> product) =>
      Obx(() {
        final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
        final id = product['id'];
        return Wrap(
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: busy || id == null
                  ? null
                  : () => ctr.onDeleteProduct(id, context),
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
              onPressed: busy || id == null
                  ? null
                  : () => ctr.onEditProduct(id, context),
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
    final snapshot = _snapshot;
    final desktop = DesktopAppShell.isVisible(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: desktop
            ? null
            : const CustomAppBar(title: 'Product Detail', useTheme: true),
        body: Obx(() {
          // Keep the detail in sync with the controller's current record
          // after an edit refreshes the list.
          final product = snapshot['id'] == null
              ? snapshot
              : ctr.products.firstWhere(
                  (p) => p['id'] == snapshot['id'],
                  orElse: () => snapshot,
                );
          final error = ctr.formError.value;
          final name = product['name']?.toString().trim() ?? '';
          final barcode = product['barcode']?.toString().trim() ?? '';
          final description = product['description']?.toString().trim() ?? '';
          final price = CurrencyFormatter.format(
            double.tryParse(product['sale_price']?.toString() ?? '') ?? 0,
            product['currency'] as Map<String, dynamic>?,
          );

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
                Text(
                  (value ?? '').trim().isEmpty ? '-' : value!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );

          final imageSection = Container(
            height: 230,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AppCachedImage(
                url: product['photo']?.toString(),
                width: double.infinity,
                height: 230,
                fallbackIcon: Icons.image_not_supported_outlined,
                errorIcon: Icons.broken_image_outlined,
                fallbackIconSize: 80,
              ),
            ),
          );

          final infoSection = HomeSectionCard(
            title: 'Product Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info('Barcode', barcode),
                info('Sale Price', price),
                info('Unit', _field(product['unit'])),
                info('Category', _field(product['category'])),
              ],
            ),
          );

          final descriptionSection = HomeSectionCard(
            title: 'Description',
            child: Text(
              description.isEmpty
                  ? 'No description available.'.tr
                  : description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          );

          return HomeTabLayout(
            translateTitle: false,
            title: name.isEmpty ? '-' : name,
            subtitle: 'Product Detail',
            leading: desktop
                ? IconButton.outlined(
                    tooltip: 'Back'.tr,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, size: 20),
                  )
                : null,
            action: desktop ? _actions(context, product) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(error, style: TextStyle(color: colors.error)),
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth >= 900
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: imageSection),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  infoSection,
                                  const SizedBox(height: 24),
                                  descriptionSection,
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            imageSection,
                            const SizedBox(height: 24),
                            infoSection,
                            const SizedBox(height: 24),
                            descriptionSection,
                          ],
                        ),
                ),
              ],
            ),
          );
        }),
        bottomNavigationBar: desktop
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _actions(context, snapshot),
                ),
              ),
      ),
    );
  }

  /// Optional lookup fields arrive as embedded maps or plain values.
  static String _field(dynamic value) {
    if (value == null) return '-';
    if (value is Map) {
      final name = value['name']?.toString().trim() ?? '';
      return name.isEmpty ? '-' : name;
    }
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }
}
