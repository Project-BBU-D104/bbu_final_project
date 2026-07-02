import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class KpiUserWidget extends StatelessWidget {
  final String title;
  final int value;
  const KpiUserWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: titleColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.tr, style: const TextStyle(fontWeight: FontWeight.bold),),
            Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          ],
        ),
      ),
    );
  }
}