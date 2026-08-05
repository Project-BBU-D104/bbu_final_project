import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/screen/category/widget/card_category_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final ctr = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: lightColor.shade50,
      appBar: CustomAppBar(title: "Category"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Obx(
          () => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: const SizedBox(
                  height: 10,
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 10,
                ),
              ),
              /// Search Bar
              SliverAppBar(
                pinned: true,
                elevation: 0,
                floating: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: SearchWidget(
                  title: "Search Category",
                )
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
                        label: Text(
                          "Add Category".tr,
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
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = ctr.categoryList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CardCategoryWidget(
                          category: item,
                        ),
                      );
                    },
                    childCount: ctr.categoryList.length,
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