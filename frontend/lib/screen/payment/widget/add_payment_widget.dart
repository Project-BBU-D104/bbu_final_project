import 'package:flutter/material.dart';
import 'package:frontend/screen/payment/widget/payment_form_widget.dart';

class AddPaymentWidget extends StatelessWidget {
  const AddPaymentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentFormWidget(isEditing: false);
  }
}
