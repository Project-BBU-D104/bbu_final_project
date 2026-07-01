import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class PurchaseController extends GetxController{
  
  final purchaseList = [
    {
      "id": 1,
      "supplier_id": 1,
      "supplier_name": "Nexus Logistics",
      "user_id": 1,
      "invoice_no": "PUR-20260001",
      "purchase_date": "2026-01-05",
      "subtotal": 180.00,
      "tax_amount": 18.00,
      "discount_amount": 8.00,
      "total_amount": 190.00,
      "paid_amount": 190.00,
      "due_amount": 0.00,
      "payment_status": "paid",
      "status": "completed",
    },
    {
      "id": 2,
      "supplier_id": 2,
      "user_id": 1,
      "invoice_no": "PUR-20260002",
      "purchase_date": "2026-01-08",
      "subtotal": 250.00,
      "tax_amount": 25.00,
      "discount_amount": 0.00,
      "total_amount": 275.00,
      "paid_amount": 100.00,
      "due_amount": 175.00,
      "payment_status": "partial",
      "status": "completed",
    },
    {
      "id": 3,
      "supplier_id": 3,
      "user_id": 2,
      "invoice_no": "PUR-20260003",
      "purchase_date": "2026-01-12",
      "subtotal": 320.00,
      "tax_amount": 32.00,
      "discount_amount": 12.00,
      "total_amount": 340.00,
      "paid_amount": 0.00,
      "due_amount": 340.00,
      "payment_status": "unpaid",
      "status": "pending",
    },
    {
      "id": 4,
      "supplier_id": 1,
      "user_id": 2,
      "invoice_no": "PUR-20260004",
      "purchase_date": "2026-01-15",
      "subtotal": 450.00,
      "tax_amount": 45.00,
      "discount_amount": 20.00,
      "total_amount": 475.00,
      "paid_amount": 475.00,
      "due_amount": 0.00,
      "payment_status": "paid",
      "status": "completed",
    },
    {
      "id": 5,
      "supplier_id": 4,
      "user_id": 1,
      "invoice_no": "PUR-20260005",
      "purchase_date": "2026-01-18",
      "subtotal": 520.00,
      "tax_amount": 52.00,
      "discount_amount": 22.00,
      "total_amount": 550.00,
      "paid_amount": 300.00,
      "due_amount": 250.00,
      "payment_status": "partial",
      "status": "completed",
    },
    {
      "id": 6,
      "supplier_id": 2,
      "user_id": 3,
      "invoice_no": "PUR-20260006",
      "purchase_date": "2026-01-20",
      "subtotal": 140.00,
      "tax_amount": 14.00,
      "discount_amount": 4.00,
      "total_amount": 150.00,
      "paid_amount": 0.00,
      "due_amount": 150.00,
      "payment_status": "unpaid",
      "status": "pending",
    },
    {
      "id": 7,
      "supplier_id": 5,
      "user_id": 1,
      "invoice_no": "PUR-20260007",
      "purchase_date": "2026-01-22",
      "subtotal": 780.00,
      "tax_amount": 78.00,
      "discount_amount": 28.00,
      "total_amount": 830.00,
      "paid_amount": 830.00,
      "due_amount": 0.00,
      "payment_status": "paid",
      "status": "completed",
    },
    {
      "id": 8,
      "supplier_id": 3,
      "user_id": 2,
      "invoice_no": "PUR-20260008",
      "purchase_date": "2026-01-25",
      "subtotal": 610.00,
      "tax_amount": 61.00,
      "discount_amount": 21.00,
      "total_amount": 650.00,
      "paid_amount": 450.00,
      "due_amount": 200.00,
      "payment_status": "partial",
      "status": "completed",
    },
    {
      "id": 9,
      "supplier_id": 4,
      "user_id": 3,
      "invoice_no": "PUR-20260009",
      "purchase_date": "2026-01-27",
      "subtotal": 890.00,
      "tax_amount": 89.00,
      "discount_amount": 39.00,
      "total_amount": 940.00,
      "paid_amount": 0.00,
      "due_amount": 940.00,
      "payment_status": "unpaid",
      "status": "pending",
    },
    {
      "id": 10,
      "supplier_id": 5,
      "user_id": 1,
      "invoice_no": "PUR-20260010",
      "purchase_date": "2026-01-30",
      "subtotal": 1100.00,
      "tax_amount": 110.00,
      "discount_amount": 60.00,
      "total_amount": 1150.00,
      "paid_amount": 1150.00,
      "due_amount": 0.00,
      "payment_status": "paid",
      "status": "completed",
    },
  ];

  final purchaseItems = [
    // Purchase 1
    {
      "id": 1,
      "purchase_id": 1,
      "product_id": 1,
      "qty": 2,
      "cost_price": 50.00,
      "subtotal": 100.00
    },
    {
      "id": 2,
      "purchase_id": 1,
      "product_id": 2,
      "qty": 1,
      "cost_price": 80.00,
      "subtotal": 80.00
    },

    // Purchase 2
    {
      "id": 3,
      "purchase_id": 2,
      "product_id": 1,
      "qty": 3,
      "cost_price": 50.00,
      "subtotal": 150.00
    },
    {
      "id": 4,
      "purchase_id": 2,
      "product_id": 3,
      "qty": 2,
      "cost_price": 50.00,
      "subtotal": 100.00
    },

    // Purchase 3
    {
      "id": 5,
      "purchase_id": 3,
      "product_id": 4,
      "qty": 4,
      "cost_price": 80.00,
      "subtotal": 320.00
    },

    // Purchase 4
    {
      "id": 6,
      "purchase_id": 4,
      "product_id": 2,
      "qty": 5,
      "cost_price": 70.00,
      "subtotal": 350.00
    },
    {
      "id": 7,
      "purchase_id": 4,
      "product_id": 3,
      "qty": 2,
      "cost_price": 50.00,
      "subtotal": 100.00
    },

    // Purchase 5
    {
      "id": 8,
      "purchase_id": 5,
      "product_id": 5,
      "qty": 10,
      "cost_price": 50.00,
      "subtotal": 500.00
    },
    {
      "id": 9,
      "purchase_id": 5,
      "product_id": 1,
      "qty": 2,
      "cost_price": 10.00,
      "subtotal": 20.00
    },

    // Purchase 6
    {
      "id": 10,
      "purchase_id": 6,
      "product_id": 2,
      "qty": 2,
      "cost_price": 60.00,
      "subtotal": 120.00
    },
    {
      "id": 11,
      "purchase_id": 6,
      "product_id": 3,
      "qty": 1,
      "cost_price": 20.00,
      "subtotal": 20.00
    },

    // Purchase 7
    {
      "id": 12,
      "purchase_id": 7,
      "product_id": 6,
      "qty": 8,
      "cost_price": 90.00,
      "subtotal": 720.00
    },
    {
      "id": 13,
      "purchase_id": 7,
      "product_id": 1,
      "qty": 2,
      "cost_price": 30.00,
      "subtotal": 60.00
    },

    // Purchase 8
    {
      "id": 14,
      "purchase_id": 8,
      "product_id": 4,
      "qty": 5,
      "cost_price": 100.00,
      "subtotal": 500.00
    },
    {
      "id": 15,
      "purchase_id": 8,
      "product_id": 2,
      "qty": 2,
      "cost_price": 55.00,
      "subtotal": 110.00
    },

    // Purchase 9
    {
      "id": 16,
      "purchase_id": 9,
      "product_id": 3,
      "qty": 10,
      "cost_price": 80.00,
      "subtotal": 800.00
    },
    {
      "id": 17,
      "purchase_id": 9,
      "product_id": 5,
      "qty": 1,
      "cost_price": 90.00,
      "subtotal": 90.00
    },

    // Purchase 10
    {
      "id": 18,
      "purchase_id": 10,
      "product_id": 6,
      "qty": 10,
      "cost_price": 100.00,
      "subtotal": 1000.00
    },
    {
      "id": 19,
      "purchase_id": 10,
      "product_id": 1,
      "qty": 5,
      "cost_price": 20.00,
      "subtotal": 100.00
    },
  ];

  void addPurchase(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddPurchaseWidget()
    );
  }

  void gotoPurchaseDetail(Map<String, dynamic> purchase){
    Get.toNamed(AppRoutes.purchaseDetail);
  }

  void editPurchase(BuildContext context, Map<String, dynamic> purchase){
    // AppBottomSheets.show(
    //   context,
    //   child: EditPurchaseWidget(purchase: purchase)
    // );
  }

  void deletePurchase(int purchaseId){
    // Implement the logic to delete the purchase with the given purchaseId
  }
}