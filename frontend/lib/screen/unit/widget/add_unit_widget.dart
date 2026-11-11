import 'package:flutter/material.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/screen/unit/widget/unit_form_widget.dart';
import 'package:get/get.dart';

class AddUnitWidget extends StatelessWidget {
  AddUnitWidget({super.key});
  final ctr = Get.find<UnitController>();

  @override
  Widget build(BuildContext context) => UnitFormWidget(
    controller: ctr,
    title: 'Add Unit',
    onSubmit: ctr.onSaveUnit,
  );
}
