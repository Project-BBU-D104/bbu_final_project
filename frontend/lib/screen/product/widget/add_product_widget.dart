import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/widget/test_product_scanner_page.dart';

class AddProductWidget extends StatelessWidget {
  AddProductWidget({super.key});

  final ctr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: SizedBox(
            child: Card(
              color: titleColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Product".tr,
                          style: TextStyle(
                            fontSize: 20,
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
        
                    ImageUploadWidget(
                      onUploaded: (url) {
                        print("Image URL: $url");
              
                        // save to SQLite or form model
                        // productController.image.value = url;
                      },
                    ),
                      
                    const SizedBox(height: 10),
                    Text("Product Name".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                    const SizedBox(height: 5),
                     TextField(
                      decoration: InputDecoration(
                        hintText: "Enter Product Name".tr,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                      Text("Category".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
                   DropdownButtonFormField<String>(
                    value: ctr.selectedCategory.value,
                    decoration: InputDecoration(
                      hintText: "Select Category".tr,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "food",
                        child: Text("Food"),
                      ),
                      DropdownMenuItem(
                        value: "drink",
                        child: Text("Drink"),
                      ),
                      DropdownMenuItem(
                        value: "snack",
                        child: Text("Snack"),
                      ),
                    ],
                    onChanged: (value) {
                      ctr.selectedCategory.value = value ?? '';
                    },
                  ),
                    const SizedBox(height: 10),
          
                     Text("Supplier".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
          
                   DropdownButtonFormField<String>(
                    value: ctr.selectedSupplier.value,
                    decoration: InputDecoration(
                      hintText: "Select Supplier".tr,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Sabrey",
                        child: Text("sabrey"),
                      ),
                      DropdownMenuItem(
                        value: "test",
                        child: Text("Test"),
                      ),
                    ],
                    onChanged: (value) {
                      ctr.selectedSupplier.value = value ?? '';
                    },
                  ),
                      
                    const SizedBox(height: 10),
                       Text("Barcode".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
                
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter Barcode".tr,
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () async {
                            final code = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TestProductScannerPage(),
                              ),
                            );

                            if (code != null) {
                              print(code);

                              // Search your database
                              // searchProduct(code);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
          
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cost Price".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                            const SizedBox(height: 5),
                                  
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Enter Cost Price".tr,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        )),
                         const SizedBox(width: 10),
                         Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sale Price".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                            const SizedBox(height: 5),
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Enter Sale Price".tr,
                                border: OutlineInputBorder(),
                              ),
                            ),
                              ],
                            )),
                          ],
                    ),
                     
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Quantity".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                        
                            const SizedBox(height: 5),
                        
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Enter Quantity".tr,
                                border: OutlineInputBorder(),
                              ),
                            ),
                            ],
                          )
                        ),

                        const SizedBox(width: 10),

                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Unit".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),

                         const SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                        value: ctr.selectedUnit.value,
                        decoration: InputDecoration(
                          hintText: "Select Unit".tr,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "kg",
                            child: Text("Kg"),
                          ),
                          DropdownMenuItem(
                            value: "unit",
                            child: Text("Unit"),
                          ),
                        ],
                        onChanged: (value) {
                          ctr.selectedUnit.value = value ?? '';
                        },
                      ),
                          ],
                        )),
                          ],
                        ),
                
                    const SizedBox(height: 10),
                    Text("Description".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
                       TextField(
                        minLines: 3,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: "Enter Description".tr,
                          border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                        ),
                      ),
                      
                      
                    const SizedBox(height: 15),
                      
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successColor,
                          foregroundColor: titleColor
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Save".tr,
                          style: TextStyle(
                            fontSize: 18,
                            
                          ),
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}