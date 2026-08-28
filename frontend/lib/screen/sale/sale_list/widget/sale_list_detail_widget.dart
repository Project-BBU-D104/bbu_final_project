import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SaleListDetailWidget extends StatelessWidget {
  SaleListDetailWidget({super.key});
  final ctr = Get.find<SaleListController>();

  static const _ink = Color(0xFF1E293B);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFD97706);
      case 'due':
      case 'unpaid':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  String _money(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;
    return NumberFormat.currency(symbol: '\$').format(number);
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: _muted)),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? _ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children, String? title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sale = Get.arguments as Map<String, dynamic>;
    final customer = sale["customer"] ?? {};
    final statusColor = _statusColor(sale["payment_status"] ?? '');
    final due = (sale["due_amount"] ?? 0) is num ? sale["due_amount"] as num : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: "Sale Detail"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice number + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale["invoice_no"] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _date(sale["sale_date"]),
                      style: const TextStyle(fontSize: 13, color: _muted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sale["payment_status"] ?? '',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Total amount banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: titleColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle( fontSize: 14),
                  ),
                  Text(
                    _money(sale["total_amount"]),
                    style: const TextStyle(
                     
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Customer + payment method
            _card(
              title: "CUSTOMER",
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(
                        (customer["name"] ?? '?').toString().isNotEmpty
                            ? customer["name"][0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFF4338CA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer["name"] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customer["phone"]?.toString() ?? '-',
                            style: const TextStyle(fontSize: 13, color: _muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: _border),
                ),
                _row("Payment Method", sale["payment_method"] ?? '-'),
                _row("Sale Status", sale["status"] ?? '-'),
              ],
            ),

            const SizedBox(height: 16),
            _saleItemCard(
              sale["sale_items"] ?? [],
            ),

            const SizedBox(height: 16),

            // Amount breakdown
            _card(
              title: "AMOUNT BREAKDOWN",
              children: [
                _row("Subtotal", _money(sale["subtotal"])),
                _row("Tax", " ${_money(sale["tax_amount"])}"),
                _row("Discount", " ${_money(sale["discount_amount"])}"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(height: 1, color: _border),
                ),
                _row("Total", _money(sale["total_amount"]), bold: true),
                _row("Paid", _money(sale["paid_amount"]), valueColor: const Color(0xFF16A34A)),
                _row(
                  "Due",
                  _money(sale["due_amount"]),
                  bold: due > 0,
                  valueColor: due > 0 ? const Color(0xFFDC2626) : _muted,
                ),
              ],
            ),

            const SizedBox(height: 16),
            
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: _border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctr.onDeleteSale(sale["id"], context);
                  },
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: Text("Delete".tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ctr.onNewSale();
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: Text("New Sale".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saleItemCard(List<dynamic> items) {
  return _card(
    title: "SALE ITEMS",
    children: [
      ...items.map((item) {
        final product = item["product"] ?? {};

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF475569),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product["name"] ?? "-",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Qty: ${item["qty"]} × ${_money(item["sale_price"])}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    _money(item["subtotal"]),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(
                height: 1,
                color: _border,
              ),
            ],
          ),
        );
      }),
    ],
  );
}
}
