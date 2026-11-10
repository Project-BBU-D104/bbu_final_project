import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:frontend/utils/currency_formatter.dart';

class ProductCardDetailWidget extends StatelessWidget {
  ProductCardDetailWidget({super.key});

  // Reuse the controller registered by the product list workflow.
  final ctr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // shortcut: detail uses its route snapshot after edit; refresh it when live detail updates are required
    final product = Get.arguments as Map<String, dynamic>;

    final String photo = product['photo']?.toString() ?? '';
    final String description = product['description']?.toString() ?? '';

    final imageSection = Container(
      height: 230,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AppCachedImage(
          url: photo,
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
          _infoRow(
            context,
            Icons.inventory_2_outlined,
            'Product Name',
            _field(product['name']),
          ),
          _infoRow(
            context,
            Icons.qr_code,
            'Barcode',
            _field(product['barcode']),
          ),
          _infoRow(
            context,
            Icons.sell,
            'Sale Price',
            CurrencyFormatter.format(
              double.tryParse(product['sale_price']?.toString() ?? '') ?? 0,
              product['currency'] as Map<String, dynamic>?,
            ),
          ),
          _infoRow(context, Icons.straighten, 'Unit', _field(product['unit'])),
          _infoRow(
            context,
            Icons.category_outlined,
            'Category',
            _field(product['category']),
          ),
        ],
      ),
    );

    final descriptionSection = HomeSectionCard(
      title: 'Description',
      child: Text(
        description.isNotEmpty ? description : 'No description available.'.tr,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.6,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Product Detail'),

      bottomNavigationBar: SafeArea(
        child: Material(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ctr.onDeleteProduct(product['id'], context),
                  icon: const Icon(Icons.delete_outline),
                  label: Text('Delete'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    minimumSize: const Size(140, 52),
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: ctr.isOpeningEdit.value
                        ? null
                        : () => ctr.onEditProduct(product['id'], context),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text('Edit'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(140, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: imageSection),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            infoSection,
                            const SizedBox(height: 20),
                            descriptionSection,
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    imageSection,
                    const SizedBox(height: 20),
                    infoSection,
                    const SizedBox(height: 20),
                    descriptionSection,
                  ],
                );
              },
            ),
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

  static Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
