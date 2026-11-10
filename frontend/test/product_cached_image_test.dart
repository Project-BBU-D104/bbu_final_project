import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/product/widget/product_card_widget.dart';
import 'package:frontend/screen/product/widget/product_table_widget.dart';
import 'package:frontend/widget/app_cached_image.dart';

void main() {
  testWidgets('fallback icon uses the configured size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppCachedImage(
          url: '',
          width: 80,
          height: 80,
          fallbackIcon: Icons.fastfood,
          fallbackIconSize: 32,
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.fastfood));
    expect(icon.size, 32);
  });

  testWidgets('product table renders its photo through AppCachedImage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductTableWidget(
            items: [
              {
                'id': 1,
                'name': 'Coffee',
                'barcode': '123',
                'sale_price': 2.5,
                'currency': {'symbol': r'$', 'code': 'USD'},
                'created_at': '2025-01-01T00:00:00',
                'photo': 'https://example.com/coffee.jpg',
              },
            ],
          ),
        ),
      ),
    );

    final image = tester.widget<AppCachedImage>(find.byType(AppCachedImage));
    expect(image.url, 'https://example.com/coffee.jpg');
  });

  testWidgets('product card renders its photo through AppCachedImage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCardWidget(
            product: {
              'id': 1,
              'name': 'Coffee',
              'barcode': '123',
              'sale_price': 2.5,
              'currency': {'symbol': r'$', 'code': 'USD'},
              'created_at': '2025-01-01T00:00:00',
              'photo': 'https://example.com/coffee.jpg',
            },
          ),
        ),
      ),
    );

    final image = tester.widget<AppCachedImage>(find.byType(AppCachedImage));
    expect(image.url, 'https://example.com/coffee.jpg');
  });
}
