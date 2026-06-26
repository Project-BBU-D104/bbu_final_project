import 'package:flutter/material.dart';

class AddProductWidget extends StatelessWidget {
  String? selectedCategory;
  String? selectedSupplier;
  String? selectedUnit;

  bool isChecked = false;

  AddProductWidget({super.key, this.selectedCategory, this.selectedSupplier, this.selectedUnit});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: SingleChildScrollView(
          child: SizedBox(
            child: Card(
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
                    value: selectedCategory,
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
                      selectedCategory = value;
                    },
                  ),
                    const SizedBox(height: 10),
          
                     Text("Supplier", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
          
                   DropdownButtonFormField<String>(
                    value: selectedSupplier,
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
                      selectedCategory = value;
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
          
                      Text("Cost Price", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
          
                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Cost Price",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text("Sale Price", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),

                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Sale Price",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text("Quantity", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),

                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Quantity",
                        border: OutlineInputBorder(),
                      ),
                    ),
                
                
                    const SizedBox(height: 10),
                    Text("Unit", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                    const SizedBox(height: 5),
                     DropdownButtonFormField<String>(
                    value: selectedUnit,
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
                      selectedCategory = value;
                    },
                  ),
                
                    const SizedBox(height: 10),
                    Text("Description", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      const SizedBox(height: 5),
                    SizedBox(
                      height: 120,
                      child: const TextField(
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: "Description",
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
            ),
          ),
        ),
      ),
    );
  }
}