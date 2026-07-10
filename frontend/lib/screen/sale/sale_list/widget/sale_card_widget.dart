import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widget/status_widget.dart';

class SaleCardWidget extends StatelessWidget {
  final Map<String, dynamic> sale;

  const SaleCardWidget({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    final customer = sale["customer"];

    final date = DateFormat("dd MMM yyyy").format(
      DateTime.parse(sale["sale_date"]),
    );

    final bool isPaid = sale["due_amount"] == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.put(SaleListController()).gotoSaleListDetail(sale),
          splashColor: const Color(0xff2563EB).withOpacity(0.06),
          highlightColor: const Color(0xff2563EB).withOpacity(0.03),
          hoverColor: const Color(0xffF9FAFB),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header: Avatar, Customer, Invoice + Total
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  /// Avatar with initials
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xffEFF6FF),
                    child: Text(
                      _initials(customer["name"]),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2563EB),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer["name"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sale["invoice_no"],
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "\$${sale["total_amount"]}",
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff111827),
                    ),
                  ),
                ],
              ),
            ),

            /// Divider
            Divider(height: 1, color: Colors.grey.shade100),

            /// Body: Due amount + payment status
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(
                children: [
                  StatusWidget(
                    text: sale["payment_status"],
                  ),

                  const Spacer(),

                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            /// Footer: Payment method
            Divider(height: 1, color: Colors.grey.shade100),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sale["payment_method"],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

}