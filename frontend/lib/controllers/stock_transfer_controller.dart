import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class StockTransferController extends GetxController{

  var selectedDate = Rxn<DateTime>();

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String get formattedDate {
    if (selectedDate.value == null) return "Select Date";
    return selectedDate.value!.toString().split(" ")[0];
  }




  void addStockTransfer(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddStockTransferWidget()
    );
  }
}