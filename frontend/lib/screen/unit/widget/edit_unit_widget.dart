import 'package:flutter/material.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/screen/unit/widget/unit_form_widget.dart';
import 'package:get/get.dart';

class EditUnitWidget extends StatelessWidget {
  EditUnitWidget({super.key, required this.unitId});
  final int unitId;
  final ctr = Get.find<UnitController>();

  @override
  Widget build(BuildContext context) => UnitFormWidget(
    controller: ctr,
    title: 'Edit Unit',
    onSubmit: (context) => ctr.onUpdateUnit(unitId, context),
  );
}
