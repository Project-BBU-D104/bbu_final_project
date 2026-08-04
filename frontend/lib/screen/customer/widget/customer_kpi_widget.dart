import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class CustomerKpiWidget extends StatelessWidget {
  final String title;
  final String value;
  const CustomerKpiWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10
      ),
      color: titleColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold),)
        ],
      )
    );
  }
}