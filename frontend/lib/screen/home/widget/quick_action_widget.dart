import 'package:flutter/material.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:get/get.dart';

class QuickActionWidget extends StatelessWidget {
  QuickActionWidget({super.key});
  final ctr = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final actions = [
      (title: 'Sale', icon: Icons.shopping_cart_outlined, onTap: ctr.gotoSale),
      (
        title: 'Category',
        icon: Icons.category_outlined,
        onTap: ctr.gotoCategory,
      ),
      (
        title: 'Product',
        icon: Icons.inventory_2_outlined,
        onTap: ctr.gotoProduct,
      ),
      (
        title: 'Supplier',
        icon: Icons.local_shipping_outlined,
        onTap: ctr.gotoSupplier,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Action'.tr,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 600 ? 2 : 4;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final action in actions)
                  SizedBox(
                    width:
                        (constraints.maxWidth - 12 * (columns - 1)) / columns,
                    child: Material(
                      color: colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: action.onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExcludeSemantics(
                                child: Icon(
                                  action.icon,
                                  color: colors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                action.title.tr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
