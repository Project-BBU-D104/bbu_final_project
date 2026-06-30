import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:get/get.dart';

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
                        const Text(
                          "Add Product",
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
                    Text("Product Name", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                    const SizedBox(height: 5),
                     const TextField(
                      decoration: InputDecoration(
                        hintText: "Product Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                      Text("Category", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
                   DropdownButtonFormField<String>(
                    value: ctr.selectedCategory.value,
                    decoration: const InputDecoration(
                      hintText: "Category",
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
          
                     Text("Supplier", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
          
                   DropdownButtonFormField<String>(
                    value: ctr.selectedSupplier.value,
                    decoration: const InputDecoration(
                      hintText: "Supplier",
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
                       Text("Bar Code", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
                
                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Bar Code",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
          

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cost Price", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                            const SizedBox(height: 5),
                                  
                            const TextField(
                              decoration: InputDecoration(
                                hintText: "Cost Price",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        )),
                         const SizedBox(width: 10),
                         Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sale Price", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                            const SizedBox(height: 5),
                            const TextField(
                              decoration: InputDecoration(
                                hintText: "Sale Price",
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
                            Text("Quantity", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                        
                            const SizedBox(height: 5),
                        
                            const TextField(
                              decoration: InputDecoration(
                                hintText: "Quantity",
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
                        Text("Unit", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),

                         const SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                        value: ctr.selectedUnit.value,
                        decoration: const InputDecoration(
                          hintText: "Unit",
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
                    Text("Description", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
                       TextField(
                        minLines: 3,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: "Description",
                          border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                        ),
                      ),
                      
                      
                    const SizedBox(height: 15),
                      
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successColor,
                          foregroundColor: titleColor
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
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