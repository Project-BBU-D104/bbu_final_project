import 'package:flutter/material.dart';

class PaymentMethodCardWidget extends StatelessWidget {
  const PaymentMethodCardWidget({
    super.key,
    required this.paymentTypes,
    required this.selectedPaymentType,
    required this.onChanged,
    this.isLoading = false,
  });

  final List<Map<String, dynamic>> paymentTypes;
  final Map<String, dynamic>? selectedPaymentType;
  final ValueChanged<Map<String, dynamic>?> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined, color: Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  value: selectedPaymentType,
                  hint: Text(
                    isLoading
                        ? 'Loading payment types...'
                        : paymentTypes.isEmpty
                        ? 'No payment types available'
                        : 'Select payment type',
                  ),
                  items: paymentTypes.map((paymentType) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: paymentType,
                      child: Text(paymentType['name']?.toString() ?? ''),
                    );
                  }).toList(),
                  onChanged: isLoading || paymentTypes.isEmpty
                      ? null
                      : onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
