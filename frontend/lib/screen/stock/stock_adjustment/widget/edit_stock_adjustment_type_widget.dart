import 'package:flutter/material.dart';

class EditStockAdjustmentTypeWidget extends StatelessWidget {
  
  String? selectedProduct;
  String? selectedWarehouse;
  String? selectedAdjustmentType;

  EditStockAdjustmentTypeWidget({super.key, this.selectedAdjustmentType, this.selectedProduct, this.selectedWarehouse});

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
                const Text(
                  "Add Stock Adjustment",
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
            Text("Product", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
                      value: selectedProduct,
                      decoration: const InputDecoration(
                        hintText: "Product",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "apple",
                          child: Text("Apple"),
                        ),
                        DropdownMenuItem(
                          value: "orange",
                          child: Text("Orange"),
                        ),
                        DropdownMenuItem(
                          value: "snack",
                          child: Text("Snack"),
                        ),
                      ],
                      onChanged: (value) {
                        selectedProduct = value;
                      },
                    ),
                     const SizedBox(height: 10),
                      Text("Warehouse", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
                      value: selectedWarehouse,
                      decoration: const InputDecoration(
                        hintText: "Warehouse",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "warehouse1",
                          child: Text("Warehouse 1"),
                        ),
                        DropdownMenuItem(
                          value: "warehouse2",
                          child: Text("Warehouse 2"),
                        ),
                        DropdownMenuItem(
                          value: "warehouse3",
                          child: Text("Warehouse 3"),
                        ),
                      ],
                      onChanged: (value) {
                        selectedWarehouse = value;
                      },
                    ),
        
            const SizedBox(height: 10),
             Text("Adjustment Type", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
                      value: selectedAdjustmentType,
                      decoration: const InputDecoration(
                        hintText: "Adjustment Type",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "increase",
                          child: Text("Increase"),
                        ),
                        DropdownMenuItem(
                          value: "decrease",
                          child: Text("Decrease"),
                        ),
                      ],
                      onChanged: (value) {
                        selectedAdjustmentType = value;
                      },
                    ),
        
            const SizedBox(height: 10),
         Text("Reference Number", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            const TextField(
              decoration: InputDecoration(
                hintText: "Reference Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
             Text("Quantity", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            const TextField(
              decoration: InputDecoration(
                hintText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),
        
            const SizedBox(height: 10),
         Text("Previous Stock", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            const TextField(
              decoration: InputDecoration(
                hintText: "Previous Stock",
                border: OutlineInputBorder(),
              ),
            ),
        
            const SizedBox(height: 10),
         Text("New Quantity", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            const TextField(
              decoration: InputDecoration(
                hintText: "New Quantity",
                border: OutlineInputBorder(),
              ),
            ),
        
            const SizedBox(height: 10),
           Text("Reason", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            SizedBox(
              height: 120,
              child: const TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: "Reason",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
        
            const SizedBox(height: 15),
        
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}