import 'package:flutter/material.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/screen/customer/widget/customer_form_widget.dart';
import 'package:get/get.dart';

class AddCustomerWidget extends StatelessWidget {
  AddCustomerWidget({super.key});
  final ctr = Get.find<CustomerController>();
  @override
  Widget build(BuildContext context) => CustomerFormWidget(
    controller: ctr,
    title: 'Add Customer',
    onSubmit: ctr.onSaveCustomer,
  );
}
