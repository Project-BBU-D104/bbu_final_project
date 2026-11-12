import 'package:flutter/material.dart';
import 'package:frontend/screen/purchases/widget/purchase_form_widget.dart';

class EditPurchaseWidget extends StatelessWidget {
  const EditPurchaseWidget({super.key});
  @override
  Widget build(BuildContext context) => PurchaseFormWidget(editing: true);
}
