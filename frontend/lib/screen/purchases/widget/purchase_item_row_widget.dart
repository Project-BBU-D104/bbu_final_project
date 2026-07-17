// import 'package:flutter/material.dart';
// import 'package:frontend/controllers/product_controller.dart';
// import 'package:frontend/screen/purchases/widget/purchase_item_form.dart';
// import 'package:get/get.dart';

// class PurchaseItemRowWidget extends StatelessWidget {
//   PurchaseItemRowWidget({
//     super.key,
//     required this.item,
//     required this.onRemove,
//     this.canRemove = true,
//   });

//   final PurchaseItemForm item;
//   final VoidCallback onRemove;
//   final bool canRemove;

//   final productCtr = Get.find<ProductController>();

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Obx(() {
//                     return DropdownButtonFormField<Map<String, dynamic>>(
//                       value: item.product.value,
//                       isExpanded: true,
//                       decoration: const InputDecoration(
//                         labelText: "Product",
//                         border: OutlineInputBorder(),
//                         isDense: true,
//                       ),
//                       items: productCtr.products.map((product) {
//                         return DropdownMenuItem<Map<String, dynamic>>(
//                           value: product,
//                           child: Text(product["name"]),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         item.product.value = value;

//                         // Optional: autofill cost price from product
//                         if (value != null) {
//                           item.costCtrl.text =
//                               (value["cost_price"] ?? 0).toString();
//                         }
//                       },
//                       validator: (value) {
//                         if (value == null) {
//                           return "Please select a product";
//                         }
//                         return null;
//                       },
//                     );
//                   }),
//                 ),
//                 if (canRemove)
//                   IconButton(
//                     icon: const Icon(
//                       Icons.delete_outline,
//                       color: Colors.red,
//                     ),
//                     onPressed: onRemove,
//                   ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: item.qtyCtrl,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: "Qty",
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 Expanded(
//                   child: TextFormField(
//                     controller: item.costCtrl,
//                     keyboardType:
//                         const TextInputType.numberWithOptions(decimal: true),
//                     decoration: const InputDecoration(
//                       labelText: "Cost Price",
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 Expanded(
//                   child: Obx(() {
//                     return Text(
//                       item.subtotal.toStringAsFixed(2),
//                       textAlign: TextAlign.end,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_form.dart';
import 'package:get/get.dart';

class PurchaseItemRowWidget extends StatelessWidget {
  PurchaseItemRowWidget({
    super.key,
    required this.item,
    required this.onRemove,
    this.canRemove = true,
  });

  final PurchaseItemForm item;
  final VoidCallback onRemove;
  final bool canRemove;

  final productCtr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [

            Row(
              children: [

                Expanded(
                  child: Obx(() {

                    return DropdownButtonFormField<int>(
                      value: item.product.value?["id"],

                      isExpanded: true,

                      decoration: const InputDecoration(
                        labelText: "Product",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),


                      items: productCtr.products.map((product) {

                        return DropdownMenuItem<int>(

                          value: product["id"],

                          child: Text(
                            product["name"] ?? "",
                          ),

                        );

                      }).toList(),


                      onChanged: (value) {

                        if (value == null) {
                          item.product.value = null;
                          return;
                        }


                        final product =
                            productCtr.products.firstWhere(
                          (p) => p["id"] == value,
                        );


                        item.product.value = product;


                        item.costCtrl.text =
                            (product["cost_price"] ?? 0)
                                .toString();

                      },


                      validator: (value) {

                        if (value == null) {
                          return "Please select a product";
                        }

                        return null;

                      },

                    );

                  }),
                ),


                if (canRemove)

                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),

                    onPressed: onRemove,
                  ),

              ],
            ),


            const SizedBox(height: 10),


            Row(
              children: [


                Expanded(
                  child: TextFormField(

                    controller: item.qtyCtrl,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(

                      labelText: "Qty",

                      border: OutlineInputBorder(),

                      isDense: true,

                    ),

                  ),
                ),



                const SizedBox(width: 8),



                Expanded(
                  child: TextFormField(

                    controller: item.costCtrl,

                    keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                    decoration: const InputDecoration(

                      labelText: "Cost Price",

                      border: OutlineInputBorder(),

                      isDense: true,

                    ),

                  ),
                ),



                const SizedBox(width: 8),



                Expanded(
                  child: Obx(() {

                    return Text(

                      item.subtotal.toStringAsFixed(2),

                      textAlign: TextAlign.end,

                      style: const TextStyle(

                        fontWeight: FontWeight.bold,

                        fontSize: 16,

                      ),

                    );

                  }),
                ),


              ],
            ),


          ],
        ),
      ),
    );
  }
}