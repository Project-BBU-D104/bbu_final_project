import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class SummaryOrderWidget extends StatelessWidget {
  const SummaryOrderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final labelColor = darkColor.shade100;
    final valueColor = darkColor;
    final greenColor = successColor;
    final dividerColor = lightColor.shade600;
    final badgeBg = lightColor.shade600;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 20),

            _buildRow(
              label: 'Items Subtotal',
              value: '\$1,093.38',
              labelColor: labelColor,
              valueColor: valueColor,
            ),
            const SizedBox(height: 12),
              Divider(color: dividerColor, height: 1),
            const SizedBox(height: 12),

            _buildRow(
              label: 'Tax',
              value: '\$87.47',
              labelColor: labelColor,
              valueColor: valueColor,
              badge: '8%',
              badgeBg: badgeBg,
            ),
            const SizedBox(height: 12),
              Divider(color: dividerColor, height: 1),
            const SizedBox(height: 12),

            _buildRow(
              label: 'Discount',
              value: '-\$50.00',
              labelColor: labelColor,
              valueColor: greenColor,
              icon: Icons.local_offer_outlined,
            ),
            const SizedBox(height: 16),
             Divider(color: dividerColor, height: 1),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                   
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                      '\$1,130.85',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: greenColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
    String? badge,
    Color? badgeBg,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 15, color: labelColor),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: labelColor),
            ],
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}