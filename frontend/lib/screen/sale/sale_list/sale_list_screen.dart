import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_card_widget.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class SaleListScreen extends StatelessWidget {
  SaleListScreen({super.key});

  final ctr = Get.put(SaleListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sale List"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [

              SizedBox(height: 4),

              SearchWidget(title: "Search Sale"),
               
              SizedBox(height: 10,),

              Obx((){ 
                  if (ctr.isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (ctr.filteredSaleList.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppCachedImage(
                              assetPath: 'assets/images/empty.png',
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                            Text("No Sale Found".tr),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctr.filteredSaleList.length,
                    itemBuilder: (context, index) {
                      final sale = ctr.filteredSaleList[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SaleCardWidget(sale: sale),
                      );
                    },
                  );
                }
              ),
              SizedBox(height: 80,)
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.onNewSale();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}