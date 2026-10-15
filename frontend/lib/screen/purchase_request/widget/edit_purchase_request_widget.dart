import 'package:flutter/material.dart';
import 'package:frontend/screen/purchase_request/widget/purchase_request_form_widget.dart';

class EditPurchaseRequestWidget extends StatelessWidget {
  const EditPurchaseRequestWidget({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context) {
    return PurchaseRequestFormWidget(requestId: requestId);
  }
}
