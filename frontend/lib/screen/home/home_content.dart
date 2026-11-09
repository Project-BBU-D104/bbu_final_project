import 'package:flutter/material.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/screen/home/widget/quick_action_widget.dart';
import 'package:frontend/screen/home/widget/recent_purchase_order_widget.dart';
import 'package:frontend/screen/home/widget/recent_sale_widget.dart';
import 'package:frontend/screen/home/widget/welcome_widget.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) => HomeTabLayout(
    title: 'Home',
    subtitle: 'Your daily inventory workspace.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
  );
}
