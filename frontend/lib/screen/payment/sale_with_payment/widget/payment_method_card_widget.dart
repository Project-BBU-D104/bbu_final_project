import 'package:flutter/material.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:get/get.dart';

class PaymentMethodCardWidget extends StatelessWidget {
  const PaymentMethodCardWidget({
    super.key,
    required this.paymentTypes,
    required this.selectedPaymentType,
    required this.onChanged,
    this.isLoading = false,
    this.loadError,
    this.onRetry,
    this.enabled = true,
  });
  final List<Map<String, dynamic>> paymentTypes;
  final Map<String, dynamic>? selectedPaymentType;
  final ValueChanged<Map<String, dynamic>?> onChanged;
  final bool isLoading;
  final String? loadError;
  final VoidCallback? onRetry;
  final bool enabled;
  @override
  Widget build(BuildContext context) => AppSectionCard(
    title: 'Payment Method',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if ((loadError?.isNotEmpty ?? false) ||
            (!isLoading && paymentTypes.isEmpty)) ...[
          Text(
            loadError?.isNotEmpty == true
                ? loadError!
                : 'No payment types available'.tr,
          ),
          TextButton(
            onPressed: enabled ? onRetry : null,
            child: Text('Retry'.tr),
          ),
        ],
        DropdownButtonFormField<int>(
          key: ValueKey(selectedPaymentType?['id']),
          itemHeight: null,
          isExpanded: true,
          initialValue:
              paymentTypes.any((p) => p['id'] == selectedPaymentType?['id'])
              ? (selectedPaymentType?['id'] as int?)
              : null,

          hint: Text(
            (isLoading
                    ? 'Loading payment types...'
                    : paymentTypes.isEmpty
                    ? 'No payment types available'
                    : 'Select payment type')
                .tr,
          ),
          items: paymentTypes
              .map(
                (p) => DropdownMenuItem<int>(
                  value: p['id'],
                  child: Text(p['name']?.toString() ?? ''),
                ),
              )
              .toList(),
          onChanged: isLoading || !enabled
              ? null
              : (id) => onChanged(
                  paymentTypes.firstWhereOrNull((p) => p['id'] == id),
                ),
        ),
      ],
    ),
  );
}
