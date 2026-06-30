import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: lightColor.shade50,
      child: child,
    );
  }
}