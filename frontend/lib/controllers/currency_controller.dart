import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/currency/widget/add_currency_widget.dart';
import 'package:frontend/screen/currency/widget/edit_currency_widget.dart';
import 'package:frontend/services/main_service/currency_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class CurrencyController extends GetxController{
  
  final CurrencyService service = CurrencyService();
  var isLoading = false.obs;

  final currencyNameController = TextEditingController();
  final currencyCodeController = TextEditingController();
  final currencySymbolController = TextEditingController();
  final currencyRateController = TextEditingController();
  final isDefault = false.obs;
  final isActive = false.obs;

  var currencyList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() async {
    await getCurrencyList();
    super.onInit();
  }

  void onClear(){
    currencyNameController.clear();
    currencyCodeController.clear();
    currencySymbolController.clear();
    currencyRateController.clear();

    isDefault.value = false;
    isActive.value = false;
  }

  Future<void> getCurrencyList() async {
    try{
      isLoading.value = true;

      final resp = await service.getCurrencies();

      if(resp is List){
        currencyList.value = List<Map<String, dynamic>>.from(resp);
      }

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
    finally{
      isLoading.value = false;
    }
  }

  void addCurrency(BuildContext context) {
    onClear();
    AppBottomSheets.show(
      context,
      child: AddCurrencyWidget()
    );
  }

  Future<void> onSaveCurrency() async{
    try{
      isLoading.value = true;

      final data = {
        "name": currencyNameController.text,
        "code": currencyCodeController.text,
        "symbol": currencySymbolController.text,
        "exchange_rate": currencyRateController.text,
        "is_default": isDefault.value,
        "status": isActive.value,
      };
      
      await service.createCurrency(data);

      ToastWidget.show(
        message: "Currency created successfully",
        type: ToastType.success,
      );

      await getCurrencyList();

      Navigator.pop(Get.context!);

      onClear();

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void editCurrency(BuildContext context, int currencyId) async{
    try{
      final currency = await service.getCurrencyById(currencyId);

      currencyNameController.text = currency["name"] ?? "";
      currencyCodeController.text = currency["code"] ?? "";
      currencySymbolController.text = currency["symbol"] ?? "";
      currencyRateController.text =
        currency["exchange_rate"]?.toString() ?? "";
      isDefault.value = currency["is_default"] ?? false;
      isActive.value = currency["status"] ?? false;

      AppBottomSheets.show(
        context,
        child: EditCurrencyWidget(
          currencyId: currencyId
        )
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> onUpdateCurrency(
    int currencyId,
    BuildContext context
  ) async{
    try{
      isLoading.value = true;

      final data = {
        "name": currencyNameController.text,
        "code": currencyCodeController.text,
        "symbol": currencySymbolController.text,
        "exchange_rate": currencyRateController.text,
        "is_default": isDefault.value,
        "status": isActive.value,
      };

      await service.updateCurrency(
        currencyId,
        data
      );

      await getCurrencyList();

      Navigator.pop(context);

      ToastWidget.show(
        message: "Currency updated successfully",
        type: ToastType.success,
      );

      onClear();

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void onDeleteCurrency(BuildContext context, int currencyId) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this currency?".tr,
      onConfirm: () async {
        try{
          await service.deleteCurrency(currencyId);

          // Refresh currency list
          await getCurrencyList();

          ToastWidget.show(
            message: "Currency deleted successfully".tr,
            type: ToastType.success,
          );

          Get.back();

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