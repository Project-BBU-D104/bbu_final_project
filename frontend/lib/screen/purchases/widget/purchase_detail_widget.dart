import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase_controller.dart';
import 'package:intl/intl.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class PurchaseDetailWidget extends StatelessWidget {
  PurchaseDetailWidget({super.key});

  final Map<String, dynamic> purchase = Get.arguments as Map<String, dynamic>;

  final ctr = Get.put(PurchaseController());

  String _formatCurrency(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '0') ?? 0;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(number);
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'active':
        return successColor;
      case 'partial':
      case 'pending':
        return Colors.orange;
      case 'due':
      case 'unpaid':
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplier = purchase['supplier'] as Map<String, dynamic>?;
    final user = purchase['user'] as Map<String, dynamic>?;
    final items = (purchase['purchase_items'] as List?) ?? [];
    final paymentStatus = (purchase['payment_status'] ?? '').toString();
    final status = (purchase['status'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: "Purchase Detail",
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Invoice header card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      purchase['invoice_no']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildStatusChip(paymentStatus),
                        const SizedBox(width: 6),
                        _buildStatusChip(status),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(purchase['purchase_date']),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                if (purchase['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    purchase['description'].toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Supplier & created by
          _buildCard(
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: "Supplier",
                  value: supplier?['name']?.toString() ?? '-',
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: "Created By",
                  value: user?['name']?.toString() ?? '-',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Items
          Text(
            "Items (${items.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          _buildCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index] as Map<String, dynamic>;
                final product = item['product'] as Map<String, dynamic>?;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.inventory_2_outlined,
                                color: successColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product?['name']?.toString() ?? '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${item['qty']} x ${_formatCurrency(item['cost_price'])}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(item['subtotal']),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (index != items.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // Summary
          _buildCard(
            child: Column(
              children: [
                _buildSummaryRow("Subtotal", purchase['subtotal']),
                _buildSummaryRow("Tax", purchase['tax_amount']),
                _buildSummaryRow("Discount", purchase['discount_amount']),
                const Divider(height: 20),
                _buildSummaryRow("Total", purchase['total_amount'],
                    bold: true),
                _buildSummaryRow("Paid", purchase['paid_amount'],
                    valueColor: successColor),
                _buildSummaryRow("Due", purchase['due_amount'],
                    valueColor:
                        (double.tryParse(purchase['due_amount']?.toString() ?? '0') ?? 0) > 0
                            ? Colors.red
                            : null),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctr.deletePurchase(purchase['id'], context);
                  },
                  icon: const Icon(Icons.delete_outline),
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
                    ctr.editPurchase(context, purchase['id']);
                  },
                  icon: const Icon(Icons.edit),
                  label: Text("Edit".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusChip(String status) {
    if (status.isEmpty) return const SizedBox.shrink();
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, dynamic value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? (bold ? Colors.black : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}