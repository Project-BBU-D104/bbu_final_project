import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class PurchaseRequestScreen extends StatelessWidget {
  PurchaseRequestScreen({super.key});

  final ctr = Get.find<PurchaseRequestController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Request"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              onChanged: ctr.setSearchQuery,
              decoration: InputDecoration(
                hintText: "Search requests".tr,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: Obx(
                  () => ctr.searchQuery.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: "Clear search".tr,
                          onPressed: () => ctr.setSearchQuery(""),
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctr.isLoading.value && ctr.requestList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = ctr.filteredRequests;
              if (requests.isEmpty) {
                return Center(
                  child: Text(
                    ctr.searchQuery.value.isEmpty
                        ? "No purchase requests yet".tr
                        : "No matching requests".tr,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: ctr.onGetPurchaseRequests,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                  itemCount: requests.length,
                  itemBuilder: (context, index) => CardPurchaseRequestWidget(
                    purchaseRequest: requests[index],
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => ctr.addPurchaseRequest(context),
        tooltip: "Add purchase request".tr,
        child: const Icon(Icons.add),
      ),
    );
  }
}
