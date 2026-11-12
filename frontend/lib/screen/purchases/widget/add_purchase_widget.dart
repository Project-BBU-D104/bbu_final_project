import 'package:flutter/material.dart';
import 'package:frontend/screen/purchases/widget/purchase_form_widget.dart';

class AddPurchaseWidget extends StatelessWidget {
  const AddPurchaseWidget({super.key});
  @override
  Widget build(BuildContext context) => PurchaseFormWidget(editing: false);
}
