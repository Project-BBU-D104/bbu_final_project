import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:get/get.dart';
import 'widgets/supplier_top_action_widget.dart';
import 'widgets/supplier_add_widget.dart';
import 'widgets/supplier_edit_widget.dart';
import 'widgets/supplier_bottom_action_widget.dart';

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupplierController controller = Get.put(SupplierController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 245, 248),
      appBar: const SupplierTopAction(),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => controller.isEditMode.value
                ? const SupplierEditForm()
                : const SupplierAddForm(),
          ),
        ),
      ),
      bottomNavigationBar: const SupplierBottomAction(),
    );
  }
}
