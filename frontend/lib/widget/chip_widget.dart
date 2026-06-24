import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class ChipWidget extends StatelessWidget {
  final String title;
  const ChipWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(title,
        style: TextStyle(
          color: darkColor.shade100,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
       
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: BorderSide(
          width: 1,
          color: secondaryColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}