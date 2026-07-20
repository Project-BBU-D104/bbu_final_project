import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:get/get.dart';

class AddCurrencyWidget extends StatelessWidget {
  AddCurrencyWidget({super.key});

  final ctr = Get.put(CurrencyController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Currency".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text("Currency Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            controller: ctr.currencyNameController,
            decoration: InputDecoration(
              hintText: "Enter Currency Name".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Currency Code".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            controller: ctr.currencyCodeController,
            decoration: InputDecoration(
              hintText: "Enter Currency Code".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Currency symbol".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            controller: ctr.currencySymbolController,
            decoration: InputDecoration(
              hintText: "Enter Currency symbol".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Exchange Rate".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            controller: ctr.currencyRateController,
            decoration: InputDecoration(
              hintText: "Enter Exchange Rate".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
           Obx(
              () => Row(
                children: [
                  Checkbox(
                    value: ctr.isActive.value,
                    onChanged: (value) {
                      ctr.isActive.value = value ?? false;
                    },
                  ),
                  const Text(
                    "Set as default currency",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
 
           Obx(
              () => Row(
                children: [
                  Checkbox(
                    value: ctr.isDefault.value,
                    onChanged: (value) {
                      ctr.isDefault.value = value ?? false;
                    },
                  ),
                  const Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ctr.onSaveCurrency();
              },
              child: Text(
                "Save".tr,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
              )
            ),
          ),
        ],
      ),
    );
  }
}