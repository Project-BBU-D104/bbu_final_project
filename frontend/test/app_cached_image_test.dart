import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widget/app_cached_image.dart';

void main() {
  testWidgets('shows the default fallback icon when url is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppCachedImage(url: null, width: 80, height: 80),
      ),
    );

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('shows the custom fallback icon when url is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppCachedImage(
          url: '',
          width: 80,
          height: 80,
          fallbackIcon: Icons.fastfood,
        ),
      ),
    );

    expect(find.byIcon(Icons.fastfood), findsOneWidget);
  });

  testWidgets('supports an infinite width without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCachedImage(
            url: 'https://example.com/product.jpg',
            width: double.infinity,
            height: 230,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
