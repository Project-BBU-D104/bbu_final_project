import 'package:flutter/material.dart';

class InputAmountWidget extends StatelessWidget {
  const InputAmountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter Amount',
          border: OutlineInputBorder(),
        )
      ),
    );
  }
}