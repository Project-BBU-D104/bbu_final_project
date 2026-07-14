import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reactive form-state for one purchase_items row (product_id, qty, cost_price).
class PurchaseItemForm {
  final id = UniqueKey();

  // Selected product — adjust type to your Product model if you have one.
  // Assumed shape here matches your other lists: Map<String, dynamic> with 'id'.
  final Rxn<Map<String, dynamic>> product = Rxn<Map<String, dynamic>>();

  final qtyCtrl = TextEditingController(text: '1');
  final costCtrl = TextEditingController();

  final RxDouble qty = 1.0.obs;
  final RxDouble cost = 0.0.obs;

  double get subtotal => qty.value * cost.value;

  PurchaseItemForm() {
    qtyCtrl.addListener(() {
      qty.value = double.tryParse(qtyCtrl.text) ?? 0;
    });
    costCtrl.addListener(() {
      cost.value = double.tryParse(costCtrl.text) ?? 0;
    });
  }

  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
  }
}