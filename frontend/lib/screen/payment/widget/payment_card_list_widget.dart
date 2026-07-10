import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentCardListWidget extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentCardListWidget({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final sale = payment["sale"];
    final customer = sale["customer"];

    final amount = payment["amount"];
    final invoice = sale["invoice_no"];
    final method = payment["payment_method"];
    final status = sale["payment_status"];

    final paymentDate =
        DateFormat("dd MMM yyyy").format(DateTime.parse(payment["payment_date"]));

    Color statusColor = Colors.green;

    if (status == "Partial") {
      statusColor = Colors.orange;
    } else if (status == "Unpaid") {
      statusColor = Colors.red;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Header
            Row(
              children: [

                const CircleAvatar(
                  radius: 22,
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        customer["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        invoice,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 12),

            infoRow(
              Icons.attach_money,
              "Amount",
              NumberFormat("#,###").format(amount),
            ),

            infoRow(
              Icons.payment,
              "Method",
              method,
            ),

            infoRow(
              Icons.calendar_today,
              "Date",
              paymentDate,
            ),

          ],
        ),
      ),
    );
  }

  Widget infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [

          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),

          const SizedBox(width: 8),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}