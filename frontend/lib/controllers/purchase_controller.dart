import 'package:flutter/material.dart';
import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
import 'package:get/get.dart';

class PurchaseController extends GetxController{

  void addPurchase(BuildContext context){
    showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return AddPurchaseWidget(); 
    }
  );
  }
}