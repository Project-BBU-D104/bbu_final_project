import 'package:flutter/material.dart';

class KpiUserWidget extends StatelessWidget {
  final String title;
  final int value;
  const KpiUserWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
            Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          ],
        ),
      ),
    );
  }
}