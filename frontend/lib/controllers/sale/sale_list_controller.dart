import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
class SaleListController extends GetxController{
  
  var isLoading = false.obs;

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < _cacheTtl;

 @override
  void onInit() {
    super.onInit();

    if(_hasFreshCache){
      saleList.value = List<Map<String, dynamic>>.from(_cache);
    }else{
      onGetSaleList();
    }
  }

  final SaleService service = SaleService();
    final saleList = <Map<String, dynamic>> [].obs;

  final searchCtr = Get.put(SearchController());

  List<Map<String, dynamic>> get filteredSaleList {
    final keyword = searchCtr.keyword.value.trim().toLowerCase();

    if (keyword.isEmpty) return saleList;

    return saleList.where((sale) {
      final customer = sale['customer'];
      final customerName = customer is Map
          ? (customer['name'] ?? '').toString()
          : (customer ?? '').toString();

      final searchable = [
        customerName,
        sale['invoice_no'],
        sale['payment_status'],
        sale['payment_method'],
        sale['sale_date'],
        sale['total_amount'],
      ].map((value) => (value ?? '').toString().toLowerCase()).join(' ');

      return searchable.contains(keyword);
    }).toList();
  }

  void gotoSaleListDetail(Map<String, dynamic> sale){
    Get.toNamed(AppRoutes.saleListDetail, arguments: sale);
  }


void onNewSale(){
    Get.toNamed(AppRoutes.sale);
  }


    Future <void> onGetSaleList() async{
    try{
      isLoading.value = true;

    final resp =  await service.getSales();

      if(resp is List){

        saleList.value = List<Map<String, dynamic>>.from(resp);

        _cache
          ..clear()
          ..addAll(saleList);
        _cachedAt = DateTime.now();
      }
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }  

  Future<void> onDeleteSale(int saleId,BuildContext context) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this sale?".tr,
      onConfirm: () async {
        try{
          await service.deleteSale(saleId);

          Get.back();

          // Refresh category list
          await onGetSaleList();

          ToastWidget.show(
            message: "Category deleted successfully".tr,
            type: ToastType.success,
          );

        }catch(e){
          ToastWidget.show(
            message: e.toString(),
            type: ToastType.error,
          );
        }
      },
      onCancel: () {
        // Do nothing
      },
    );
  }
}