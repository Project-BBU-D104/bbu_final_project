import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class StockAdjustmentController extends GetxController{
  void addStockAdjustment(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddStockAdjustmentWidget()
    );
  }
}