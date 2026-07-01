import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class SelectCustomerCardWidget extends StatelessWidget {
  const SelectCustomerCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: titleColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Customer",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Please select a customer for this sale.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        )
      ),
    );
  }
}