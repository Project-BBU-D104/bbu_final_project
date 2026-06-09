import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  // Static const data list
  static const List<OperationalGroup> groups = [
    OperationalGroup(title: "Electronics", productCount: 412, icon: Icons.developer_board, trend: 12),
    OperationalGroup(title: "Hardware", productCount: 1204, icon: Icons.build, trend: 5),
    OperationalGroup(title: "Logistics", productCount: 88, icon: Icons.local_shipping, trend: 0),
    OperationalGroup(title: "Tools", productCount: 340, icon: Icons.handyman, trend: 21),
    OperationalGroup(title: "Safety Gear", productCount: 156, icon: Icons.construction, trend: -3),
    OperationalGroup(title: "Raw Materials", productCount: 782, icon: Icons.precision_manufacturing, trend: 44),
  ];

  @override
  Widget build(BuildContext context) {
    // 🟢 CHANGED: Light theme colors matching your Stock Movement screen
    final backgroundColor = const Color(0xFFF5F7FA); // Soft light grey/white background
    final cardColor = Colors.white;                 // Crisp white cards
    final primaryAccent = Colors.blue;              // Professional blue accent
    final textColor = Colors.black87;               // Dark readable text

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5, // Subtle shadow line under the app bar
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor), 
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Inventory Pro", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textColor), 
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            hintText: "Search Industrial categories...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      Icon(Icons.tune, color: primaryAccent),
                    ],
                  ),
                ),
              ),
            ),
            
            // Header Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Operational Groups",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      "${groups.length} CATEGORIES",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ),

            // Grid of Category Cards
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = groups[index];
                  return _buildCategoryCard(item, cardColor, primaryAccent, textColor);
                },
                childCount: groups.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(OperationalGroup item, Color cardColor, Color accentColor, Color textColor) {
    Color trendBg = item.trend > 0 
        ? Colors.green.withOpacity(0.1) 
        : (item.trend < 0 ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1));
    
    Color trendColor = item.trend > 0 
        ? Colors.green 
        : (item.trend < 0 ? Colors.redAccent : Colors.grey);

    String trendText = item.trend > 0 
        ? "+${item.trend}" 
        : "${item.trend}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: accentColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    if (item.trend != 0)
                      Icon(
                        item.trend > 0 ? Icons.trending_up : Icons.trending_down, 
                        color: trendColor, 
                        size: 12
                      ),
                    const SizedBox(width: 4),
                    Text(
                      trendText,
                      style: TextStyle(color: trendColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                "${item.productCount} Products",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// Immutable Data Model class 
class OperationalGroup {
  final String title;
  final int productCount;
  final IconData icon;
  final int trend;

  const OperationalGroup({
    required this.title,
    required this.productCount,
    required this.icon,
    required this.trend,
  });
}