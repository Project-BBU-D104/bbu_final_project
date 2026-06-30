import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale_controller.dart';
import 'package:frontend/screen/sale/widget/sale_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class SaleListScreen extends StatelessWidget {
  SaleListScreen({super.key});

  final ctr = Get.put(SaleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sale List"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Sale"),
          
              Row(
                children: [
                  ChipWidget(title: "All"),
                  ChipWidget(title: "Pending"),
                  ChipWidget(title: "Completed"),
                  ChipWidget(title: "Canceled"),
                ]
              ),

              SizedBox(height: 10,),

              SaleCardWidget(),
          
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.onNewSale();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}