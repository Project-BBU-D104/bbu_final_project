import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/stock_adjustment_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class StockAdjustmentScreen extends StatelessWidget {
StockAdjustmentScreen({super.key});

  final ctr = Get.find<StockAdjustmentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Stock Adjustment"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              SizedBox(height: 8,),

              SearchWidget(title: "Search Stock Adjustment"),

              SizedBox(height: 8,),

              Row(
                children: [
                  ChipWidget(title: "All"),
                  ChipWidget(title: "Increases"),
                  ChipWidget(title: "Decreases"),
                  ChipWidget(title: "Rejected"),
                ]
              ),
        
              SizedBox(height: 10,),
              
               ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ctr.stockAdjustmentList.length,
                  itemBuilder: (context, index){
                    return StockAdjustmentCardWidget(stockAdjustment: ctr.stockAdjustmentList[index]);
                  }
                ),

              SizedBox(height: 80,),

            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addStockAdjustment(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}