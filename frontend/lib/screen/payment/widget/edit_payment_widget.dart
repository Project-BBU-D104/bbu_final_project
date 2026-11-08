import 'package:flutter/material.dart';
import 'package:frontend/screen/payment/widget/payment_form_widget.dart';

class EditPaymentWidget extends StatelessWidget {
  const EditPaymentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentFormWidget(isEditing: true);
  }
}
