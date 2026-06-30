import 'package:flutter/material.dart';
import 'package:frontend/screen/customer/widget/add_customer_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController{
  void addCustomer(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddCustomerWidget()
    );
  }
}