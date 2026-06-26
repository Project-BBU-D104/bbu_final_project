import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/screen/category/widget/card_category_widget.dart';
import 'package:frontend/widget/button_change_table_or_card_widget.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final ctr = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: lightColor.shade50,
      appBar: AppBar(
        backgroundColor: titleColor,
        surfaceTintColor: titleColor,
        elevation: 0.5,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Category",
          style: TextStyle(
            color: darkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ButtonChangeTableOrCardWidget(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(
          () => CustomScrollView(
            slivers: [
              /// Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: darkColor.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SearchWidget(
                            title: "Search Category",
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${ctr.categoryList.length} CATEGORIES",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                        ),
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Add Category",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: (){
                          ctr.addCategory(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// Loading
              if (ctr.isLoading.value)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )

              /// Empty State
              else if (ctr.categoryList.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No Category Found",
                    ),
                  ),
                )

              /// Grid
              else
                SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item =
                          ctr.categoryList[index];

                      return CardCategoryWidget(
                        category: item,
                      );
                    },
                    childCount:
                        ctr.categoryList.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}