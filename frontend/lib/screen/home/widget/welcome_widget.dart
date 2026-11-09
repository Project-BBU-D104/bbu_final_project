import 'package:flutter/material.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:get/get.dart';

class WelcomeWidget extends StatelessWidget {
  WelcomeWidget({super.key});
  final ctr = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back'.tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        ctr.welcomePage.value?['name']?.toString() ?? '',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ExcludeSemantics(
                child: ClipOval(
                  child: Obx(
                    () => AppCachedImage(
                      url: ctr.welcomePage.value?['photo']?.toString(),
                      width: 56,
                      height: 56,
                      fallbackIcon: Icons.person_outline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.onPrimaryContainer,
              foregroundColor: colors.primaryContainer,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: ctr.gotoSale,
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: Text('New sale'.tr),
          ),
        ],
      ),
    );
  }
}
