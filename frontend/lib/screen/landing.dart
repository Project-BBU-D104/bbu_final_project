import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: infoColor,
      body: Container(
        color: Colors.white,
        child: const Center(child: Text("Landing Screen")),
      )
    );
  } 
}