import 'package:flutter/material.dart';
import 'package:frontend/screen/home/widget/quick_action_widget.dart';
import 'package:frontend/screen/home/widget/recent_purchase_order_widget.dart';
import 'package:frontend/screen/home/widget/recent_sale_widget.dart';
import 'package:frontend/screen/home/widget/welcome_widget.dart';
import 'package:get/get.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 600 ? 16 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home'.tr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                WelcomeWidget(),
                const SizedBox(height: 32),
                QuickActionWidget(),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 900) {
                      return Column(
                        children: [
                          RecentStockOutWidget(),
                          const SizedBox(height: 24),
                          RecentStockInWidget(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: RecentStockOutWidget()),
                        const SizedBox(width: 24),
                        Expanded(child: RecentStockInWidget()),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
