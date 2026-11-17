import 'dart:async';
import 'package:frontend/services/main_service/sale_service.dart';

class ManagementSaleService extends SaleService {
  dynamic rows = <Map<String, dynamic>>[];
  Completer<void>? deleteGate;
  @override
  Future<dynamic> deleteSale(int id) async {
    await deleteGate?.future;
    return null;
  }

  int reads = 0;
  Object? readError;
  @override
  Future<dynamic> getSales() async {
    reads++;
    if (readError != null) throw readError!;
    return rows;
  }
}
