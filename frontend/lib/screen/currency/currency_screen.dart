import 'package:flutter/material.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/screen/currency/widget/currency_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class CurrencyScreen extends StatelessWidget {
  CurrencyScreen({super.key});

  final ctr = Get.put(CurrencyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Currency"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Currency"),
              SizedBox(height: 10),
              Obx((){

                if (ctr.isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (ctr.currencyList.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Text("No Currency Found".tr),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctr.currencyList.length,
                    itemBuilder: (context, index){
                      final currency = ctr.currencyList[index];
                      return CurrencyCardWidget(currency: currency);
                    },
                  );
                }
              )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addCurrency(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}