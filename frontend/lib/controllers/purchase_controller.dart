import 'package:flutter/material.dart';
import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class PurchaseController extends GetxController{

  void addPurchase(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddPurchaseWidget()
    );
  }
}