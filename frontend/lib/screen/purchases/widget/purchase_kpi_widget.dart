import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class PurchaseKpiWidget extends StatelessWidget {
  final String title;
  final int value; 
  const PurchaseKpiWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: titleColor,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          
            children: [
              Text(title.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
            
            ]
          ),
        ),
      
    );
  }
}