import 'package:flutter/material.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:get/get.dart';

/// Applies the app preference on top of the device's text scaling strategy.
class AppTextScale extends StatelessWidget {
  const AppTextScale({
    super.key,
    required this.controller,
    required this.child,
  });

  final ThemeController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Obx(
      () => MediaQuery(
        data: media.copyWith(
          textScaler: _ScaledTextScaler(
            media.textScaler,
            controller.fontScale.value,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ScaledTextScaler extends TextScaler {
  const _ScaledTextScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _ScaledTextScaler &&
      other.base == base &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
