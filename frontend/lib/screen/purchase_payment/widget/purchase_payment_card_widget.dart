import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchasePaymentCardWidget extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PurchasePaymentCardWidget({
    super.key,
    required this.payment,
  });

  String formatDate(String? date) {
    if (date == null) return '-';

    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.parse(date));
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchase = payment['purchase'] ?? {};
    final supplier = payment['supplier'] ?? {};
    final paymentType = payment['payment_type'] ?? {};
    final currency = payment['currency'] ?? {};

    final status = payment['status'] ?? 'Unknown';
    final isPaid = status.toString().toLowerCase() == 'paid';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [

            // ==========================
            // TOP
            // ==========================
            Row(
              children: [

                // Payment Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 12),

                // Payment No + Supplier
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['payment_no'] ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        supplier['name'] ?? '-',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPaid
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(height: 1),

            const SizedBox(height: 12),

            // ==========================
            // PAYMENT INFO
            // ==========================
            Row(
              children: [

                // Invoice
                Expanded(
                  child: _Info(
                    icon: Icons.receipt_long_outlined,
                    label: 'Invoice',
                    value: purchase['invoice_no'] ?? '-',
                  ),
                ),

                // Payment Type
                Expanded(
                  child: _Info(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Payment',
                    value: paymentType['name'] ?? '-',
                  ),
                ),

                // Date
                Expanded(
                  child: _Info(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: formatDate(
                      payment['payment_date'],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==========================
            // BOTTOM AMOUNT
            // ==========================
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                Text(
                  '${payment['amount'] ?? 0} ${currency['symbol'] ?? ''}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ========================================
// INFO WIDGET
// ========================================

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Info({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey.shade500,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}