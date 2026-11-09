import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/supplier/widgets/supplier_form_widget.dart';
import 'package:get/get.dart';

class SupplierAddWidget extends StatelessWidget {
  SupplierAddWidget({super.key});
  final ctr = Get.find<SupplierController>();
  @override
  Widget build(BuildContext context) => SupplierFormWidget(
    controller: ctr,
    title: 'Add Supplier',
    onSubmit: ctr.saveSupplier,
  );
}
