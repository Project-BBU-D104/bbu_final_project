import 'package:flutter/material.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/screen/customer/widget/customer_form_widget.dart';
import 'package:get/get.dart';

class EditCustomerWidget extends StatelessWidget {
  EditCustomerWidget({super.key, required this.customerId});
  final int customerId;
  final ctr = Get.find<CustomerController>();
  @override
  Widget build(BuildContext context) => CustomerFormWidget(
    controller: ctr,
    title: 'Edit Customer',
    onSubmit: (context) => ctr.onUpdateCustomer(customerId, context),
  );
}