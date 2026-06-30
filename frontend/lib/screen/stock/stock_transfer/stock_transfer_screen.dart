import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_transfer_controller.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class StockTransferScreen extends StatelessWidget {
  StockTransferScreen({super.key});

  final ctr = Get.find<StockTransferController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Stock Transfer"),
      body: Column(
        children: [
          SearchWidget(title: "Search Stock Transfer"),

          Row(
            children: [
              ChipWidget(title: "All"),
              ChipWidget(title: "Sent"),
              ChipWidget(title: "Received"),
            ],
          ),
          StockTransferCardWidget(),
        ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: (){
        ctr.addStockTransfer(context);
      },
      child: const Icon(Icons.add),
    ),
    );
  }
}