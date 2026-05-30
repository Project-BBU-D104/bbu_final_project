import 'package:flutter/material.dart';

class StockMovementscreen extends StatelessWidget {
  const StockMovementscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Movement")),
      body: Center(child: Text("Stock Movementscreen")),
    );
  }
}