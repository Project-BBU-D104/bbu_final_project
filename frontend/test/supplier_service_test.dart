import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/main_service/supplier_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'supplier_test_support.dart';

void main() {
  setUp(setUpSupplierTests);

  test('supplier reads reflect status edits despite cached HTTP responses', () {
    var stored = supplierJson(1, 'Alpha');
    final cached = <String, String>{};
    return http.runWithClient(
      () async {
        final service = SupplierService();
        expect((await service.getSuppliers() as List).single['status'], true);
        expect((await service.getSupplierById(1))['status'], true);

        for (final status in [false, true]) {
          await service.updateSupplier(1, {'status': status});
          expect(
            (await service.getSuppliers() as List).single['status'],
            status,
          );
          expect((await service.getSupplierById(1))['status'], status);
        }
      },
      () => MockClient((request) async {
        final path = request.url.path;
        if (request.method == 'PUT') {
          stored = {
            ...stored,
            ...jsonDecode(request.body) as Map<String, dynamic>,
          };
          // Updating /supplier/1 does not invalidate a browser's /supplier/ cache.
          cached.remove(path);
          return http.Response(jsonEncode(stored), 200);
        }
        if (!cached.containsKey(path) ||
            request.headers['Cache-Control'] == 'no-cache') {
          cached[path] = jsonEncode(path.endsWith('/') ? [stored] : stored);
        }
        return http.Response(
          cached[path]!,
          200,
          headers: {'cache-control': 'max-age=60'},
        );
      }),
    );
  });
}
