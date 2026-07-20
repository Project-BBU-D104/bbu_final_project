  import 'package:flutter/material.dart';
  import 'package:frontend/constants/constant.dart';
  import 'package:frontend/controllers/product_controller.dart';
  import 'package:frontend/controllers/product_transfer_controller.dart';
  import 'package:frontend/controllers/warehouse_controller.dart';
  import 'package:get/get.dart';

  class EditStockTransferWidget extends StatelessWidget {

    EditStockTransferWidget({super.key});

  final ctr = Get.find<ProductTransferController>();
  final warehouseCtr = Get.put(WarehouseController());
  final productCtr = Get.put(ProductController());

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Stock Transfer".tr,
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
              Text("From Warehouse".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
              SizedBox(height: 5,),
              
              Obx(() {
                if (warehouseCtr.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return DropdownButtonFormField<int>(
                  value: ctr.selectedFromWarehouse.value,
                  decoration: const InputDecoration(
                    hintText: "Select Warehouse",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: warehouseCtr.warehouseList.map((warehouse) {
                    return DropdownMenuItem<int>(
                      value: warehouse["id"] as int,
                      child: Text(warehouse["name"] ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ctr.selectedFromWarehouse.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a warehouse";
                    }
                    return null;
                  },
                );
              }),
                      
              const SizedBox(height: 15),
          
              Text("To Warehouse".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
              SizedBox(height: 5,),
              Obx(() {
                if (warehouseCtr.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return DropdownButtonFormField<int>(
                  value: ctr.selectedToWarehouse.value,
                  decoration: const InputDecoration(
                    hintText: "Select Warehouse",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: warehouseCtr.warehouseList.map((warehouse) {
                    return DropdownMenuItem<int>(
                      value: warehouse["id"] as int,
                      child: Text(warehouse["name"] ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ctr.selectedToWarehouse.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a warehouse";
                    }
                    return null;
                  },
                );
              }),

              const SizedBox(height: 15),
              Text("Product".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
              SizedBox(height: 5,),
              Obx(() {
                if (productCtr.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return DropdownButtonFormField<int>(
                  value: ctr.selectedProduct.value,
                  decoration: const InputDecoration(
                    hintText: "Select Product",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: productCtr.products.map((warehouse) {
                    return DropdownMenuItem<int>(
                      value: warehouse["id"] as int,
                      child: Text(warehouse["name"] ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ctr.selectedProduct.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a product";
                    }
                    return null;
                  },
                );
              }),

              const SizedBox(height: 15),

              Text("Reference Number".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
              SizedBox(height: 5,),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: ctr.productTransferRefController,
                decoration: InputDecoration(
                  hintText: "Enter Reference Number".tr,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),

              const SizedBox(height: 15),

              Text("Quantity".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
              SizedBox(height: 5,),
              TextFormField(
                controller: ctr.quantityController,
                keyboardType: TextInputType.number,
                onChanged: (value){
                   ctr.quantity.value = int.tryParse(value);
                },
                decoration: InputDecoration(
                  hintText: "Enter Quantity".tr,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
  

              const SizedBox(height: 10),
              Text("Transfer Date".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              const SizedBox(height: 5),

              Obx(() => InkWell(
                    onTap: () => ctr.pickDate(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ctr.formattedDate,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )),
                      
              const SizedBox(height: 15),
          
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
                  ),
                  onPressed: () {
                    ctr.onUpdate(
                      context,
                      ctr.editingTransfer.value!,
                    );
                  },
                  child: Text("Update".tr, style: const TextStyle(fontSize: 18),),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }