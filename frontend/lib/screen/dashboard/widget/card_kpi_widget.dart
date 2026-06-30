import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class CardKpiWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? status;

  const CardKpiWidget({super.key, required this.icon, required this.title, required this.value, this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: titleColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon),
                const SizedBox(width: 10,),
                Text(status ?? "", style: const TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 15,),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          ],
        ),
      ),
    );
  }
}