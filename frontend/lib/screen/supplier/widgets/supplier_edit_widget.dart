import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/supplier/widgets/supplier_form_widget.dart';
import 'package:get/get.dart';

class SupplierEditWidget extends StatelessWidget {
  SupplierEditWidget({super.key, required this.supplierId});
  final int supplierId;
  final ctr = Get.find<SupplierController>();
  @override
  Widget build(BuildContext context) => SupplierFormWidget(
    controller: ctr,
    title: 'Edit Supplier',
    showStatus: true,
    onSubmit: (context) => ctr.updateSupplier(supplierId, context),
  );
}
