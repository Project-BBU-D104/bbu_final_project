import 'package:flutter/material.dart';

class CustomerKpiWidget extends StatelessWidget {
  final String title;
  final String value;
  const CustomerKpiWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold),)
    ],
  )
 );
  }
}