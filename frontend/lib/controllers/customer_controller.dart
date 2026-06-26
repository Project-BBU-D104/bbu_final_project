import 'package:flutter/material.dart';
import 'package:frontend/screen/customer/widget/add_customer_widget.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController{

void addCustomer(BuildContext context){
    showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return AddCustomerWidget(); 
    }
  );
}

}