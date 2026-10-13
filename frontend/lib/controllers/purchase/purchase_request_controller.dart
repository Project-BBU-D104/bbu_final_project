import 'package:flutter/material.dart';
import 'package:frontend/screen/purchase_request/widget/add_purchase_request_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class PurchaseRequestController extends GetxController{
  
  Future<void> addPurchaseRequest(BuildContext context) async{
    AppBottomSheets.show(
      context,
      child: AddPurchaseRequestWidget()
    );
  }
}