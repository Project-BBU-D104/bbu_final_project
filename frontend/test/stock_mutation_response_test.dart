import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'supplier_test_support.dart';

void main() {
  setUp(setUpSupplierTests);

  for (final endpoint in [
    'warehouse',
    'warehouse_stock',
    'stock_adjustment',
    'product_transfer',
  ]) {
    for (final method in ['POST', 'PUT', 'DELETE']) {
      test(
        '$method $endpoint treats malformed HTTP success as committed',
        () async {
          var requests = 0;
          final api = ApiService(
            baseUrl: 'http://localhost',
            client: MockClient((request) async {
              requests++;
              expect(request.method, method);
              return http.Response('not json', 200);
            }),
          );
          final mutation = switch (method) {
            'POST' => api.post(endpoint, {}),
            'PUT' => api.put(endpoint, '1', {}),
            _ => api.delete(endpoint, '1'),
          };
          await expectLater(mutation, completion(isNull));
          expect(requests, 1);
        },
      );
    }
  }

  test('stock read still rejects malformed success', () async {
    final api = ApiService(
      baseUrl: 'http://localhost',
      client: MockClient((_) async => http.Response('not json', 200)),
    );
    await expectLater(api.get('warehouse_stock'), throwsFormatException);
  });

  test('other mutation response parsing stays strict', () async {
    final api = ApiService(
      baseUrl: 'http://localhost',
      client: MockClient((_) async => http.Response('not json', 200)),
    );
    await expectLater(api.post('sale', {}), throwsFormatException);
  });

  test('rejected stock mutation stays a retryable service failure', () async {
    final api = ApiService(
      baseUrl: 'http://localhost',
      client: MockClient(
        (_) async => http.Response('{"detail":"rejected"}', 409),
      ),
    );
    await expectLater(
      api.post('product_transfer', {}),
      throwsA(isA<ApiException>()),
    );
  });
}
