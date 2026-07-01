import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class PaymentSuccessWidget extends StatefulWidget {
  const PaymentSuccessWidget({super.key});

  @override
  State<PaymentSuccessWidget> createState() => _PaymentSuccessWidgetState();
}
class _PaymentSuccessWidgetState extends State<PaymentSuccessWidget>
    with TickerProviderStateMixin {
  static const primaryBlue = Color(0xFF1479F2);
  static const darkNavy = Color(0xFF16215B);
  static const lightGrey = Color(0xFFF3F4F8);

  late final AnimationController _badgeController;
  late final AnimationController _checkController;
  late final AnimationController _sparkleController;
  late final AnimationController _contentController;

  late final Animation<double> _badgeScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _sparkleOpacity;
  late final Animation<double> _sparkleScale;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();

    // Outer rings pop in with a slight overshoot
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    );

    // Checkmark scales/fades in after the badge
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutBack,
    );
    _checkOpacity = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeIn,
    );

    // Sparkles fade/pop in last, slightly staggered
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sparkleOpacity = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeIn,
    );
    _sparkleScale = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.elasticOut,
    );

    // Text + details slide up and fade in
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOut));
    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _badgeController.forward();
    await _checkController.forward();
    _sparkleController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _contentController.forward();
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _checkController.dispose();
    _sparkleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),

              // Animated badge with sparkles
              SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _sparkle(
                      left: 30,
                      top: 20,
                      child: Icon(Icons.auto_awesome, color: Colors.purple.shade300, size: 22),
                    ),
                    _sparkle(
                      right: 100,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
                      ),
                    ),
                    _sparkle(
                      left: 40,
                      bottom: 20,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
                      ),
                    ),
                    _sparkle(
                      right: 30,
                      bottom: 30,
                      child: Icon(Icons.auto_awesome, color: Colors.pinkAccent, size: 22),
                    ),

                    ScaleTransition(
                      scale: _badgeScale,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue.withOpacity(0.15),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _badgeScale,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue.withOpacity(0.35),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _checkScale,
                      child: FadeTransition(
                        opacity: _checkOpacity,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryBlue,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Successful',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your transaction has been completed',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      _detailRow('Payment Method:', 'VISA Classic'),
                      const SizedBox(height: 12),
                      _detailRow('Date:', '26 Sep 2022'),
                      const SizedBox(height: 12),
                      _detailRow('Transaction ID:', 'FT4J5KN0'),
                      const SizedBox(height: 12),
                      _detailRow('Subtotal:', '\$450'),
                      const SizedBox(height: 12),
                      CustomPaint(
                        painter: _DashedLinePainter(),
                        child: const SizedBox(width: double.infinity, height: 1),
                      ),
                      const SizedBox(height: 12),
                      _detailRow('Total:', '\$450', boldValue: true),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // --- Your original button block, untouched ---
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryBlue,
                          elevation: 0,
                          side: const BorderSide(color: primaryBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Export Receipt',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed(AppRoutes.sale);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Back to Sale',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sparkle({double? left, double? right, double? top, double? bottom, required Widget child}) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ScaleTransition(
        scale: _sparkleScale,
        child: FadeTransition(
          opacity: _sparkleOpacity,
          child: child,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool boldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        Text(
          value,
          style: TextStyle(
            fontSize: boldValue ? 18 : 14,
            fontWeight: boldValue ? FontWeight.bold : FontWeight.w600,
            color: darkNavy,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}