import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/main_service/product_transfer_service.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';

void initTransferEnvironment() =>
    dotenv.testLoad(fileInput: 'API_URL=http://localhost');
Map<String, dynamic> stockJson({int warehouse = 1, int qty = 10}) => {
  'warehouse_id': warehouse,
  'qty': qty,
  'product': {'id': 1, 'name': 'Rice'},
};
Map<String, dynamic> transferJson(
  int id, {
  int fromId = 1,
  int toId = 2,
  int qty = 3,
}) => {
  'id': id,
  'from_warehouse_id': fromId,
  'to_warehouse_id': toId,
  'from_warehouse': {'id': fromId, 'name': 'Source'},
  'to_warehouse': {'id': toId, 'name': 'Destination'},
  'reference_no': 'TR-$id',
  'transfer_date': '2026-11-14T17:30:00.000Z',
  'product_transfer_items': <Map<String, dynamic>>[
    {
      'product_id': 1,
      'product': {'id': 1, 'name': 'Rice'},
      'qty': qty,
    },
  ],
};

class FakeProductTransferService extends ProductTransferService {
  List<Map<String, dynamic>> records = [transferJson(1)];
  bool failList = false,
      failWrite = false,
      failDetail = false,
      failDelete = false;
  int createCalls = 0, updateCalls = 0, deleteCalls = 0;
  Map<String, dynamic>? payload;
  void Function()? afterWrite;
  Completer<dynamic>? listGate, detailGate, writeGate;
  @override
  Future<dynamic> getProductTransfers() async {
    if (listGate != null) return listGate!.future;
    if (failList) throw Exception('private server data');
    return records;
  }

  @override
  Future<dynamic> getProductTransferById(int id) async {
    if (detailGate != null) return detailGate!.future;
    if (failDetail) throw Exception('private server data');
    return records.firstWhere((r) => r['id'] == id);
  }

  @override
  Future<dynamic> createProductTransfer(Map<String, dynamic> data) async {
    createCalls++;
    payload = data;
    if (failWrite) throw Exception('private server data');
    afterWrite?.call();
    return writeGate == null ? null : await writeGate!.future;
  }

  @override
  Future<dynamic> updateProductTransfer(
    int id,
    Map<String, dynamic> data,
  ) async {
    updateCalls++;
    payload = data;
    if (failWrite) throw Exception('private server data');
    afterWrite?.call();
    records = [
      {...transferJson(id), ...data},
    ];
    return null;
  }

  @override
  Future<dynamic> deleteProductTransfer(int id) async {
    deleteCalls++;
    if (failDelete) throw Exception('private server data');
    records = [];
  }
}

class FakeTransferStockService extends WarehouseStockService {
  List<Map<String, dynamic>> records = [stockJson()];
  bool fail = false;
  Completer<dynamic>? gate;
  @override
  Future<dynamic> getWarehouseStock() async {
    if (gate != null) return gate!.future;
    if (fail) throw Exception('private server data');
    return records;
  }
}

// Existing interfaces stay unchanged; no requests or global workers in this fake.
class TransferWarehouseController extends WarehouseController {
  int refreshCalls = 0;
  @override
  Future<void> getWarehouses() async {
    refreshCalls++;
  }

  @override
  // Intentionally skip network requests and global workers in test doubles.
  // ignore: must_call_super
  void onInit() {}
}

class TransferProductController extends ProductController {
  int refreshCalls = 0;
  @override
  // Intentionally skip network requests and global workers in test doubles.
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> getProducts({bool showLoading = true}) async {
    refreshCalls++;
  }
}

class TransferWarehouseStockController extends WarehouseStockController {
  int refreshCalls = 0;
  @override
  // Intentionally skip network requests and global workers in test doubles.
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> getWarehouseStock() async {
    refreshCalls++;
  }
}
