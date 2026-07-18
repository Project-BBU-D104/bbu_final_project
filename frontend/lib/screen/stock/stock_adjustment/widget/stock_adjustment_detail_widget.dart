import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class StockAdjustmentDetailWidget extends StatelessWidget {
  StockAdjustmentDetailWidget({super.key});

  final ctr = Get.find<StockAdjustmentController>();

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> data =
    Get.arguments as Map<String, dynamic>;
    
    final product = data["product"];
    final warehouse = data["warehouse"];

    return Scaffold(
      appBar: CustomAppBar(
        title: "Stock Adjustment Detail".tr,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            _buildHeader(data),
            const SizedBox(height: 16),
            /// PRODUCT
            _sectionTitle("Product"),
            _buildProductCard(product),
            const SizedBox(height: 16),
            /// WAREHOUSE
            _sectionTitle("Warehouse"),
            _buildWarehouseCard(warehouse),
            const SizedBox(height: 16),
            /// STOCK CHANGE
            _sectionTitle("Stock Change"),
            _buildStockCard(data),
            const SizedBox(height: 16),
            /// REASON
            _sectionTitle("Reason"),
            _buildReasonCard(data), 
          ],
        ),
      ),
      bottomNavigationBar: _bottomActions(context, data),
    );
  }

  Widget _buildHeader(Map data){
    bool increase = data["adjustment_type"] == "increase";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: increase
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: increase
                ? Colors.green
                : Colors.red,
            child: Icon(
              increase
                  ? Icons.add
                  : Icons.remove,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["adjustment_type"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "Ref: ${data["reference_no"]}",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductCard(Map product){
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product["photo"],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_,__,___){
                  return Container(
                    width:70,
                    height:70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Barcode: ${product["barcode"]}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height:5),
                  Row(
                    children: [
                      _chip(
                        Icons.category,
                        product["category"]["name"],
                      ),
                      const SizedBox(width:8),
                      _chip(
                        Icons.local_shipping,
                        product["supplier"]["name"],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseCard(Map warehouse){
    return Card(
      elevation:0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(
              warehouse["name"],
              style: const TextStyle(
                fontSize:18,
                fontWeight:FontWeight.bold,
              ),
            ),

            const SizedBox(height:8),

            _infoRow(
              Icons.location_on,
              warehouse["location"],
            ),

            _infoRow(
              Icons.confirmation_number,
              warehouse["reference_no"],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(Map data){
    return Card(
      elevation:0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding:const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:MainAxisAlignment.spaceAround,
          children:[
            _qtyBox(
              "Previous",
              data["previous_qty"],
            ),

            const Icon(
              Icons.arrow_forward,
              size:30,
            ),

            _qtyBox(
              "New",
              data["new_qty"],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonCard(Map data){
    return SizedBox(
      width:double.infinity,
      child: Card(
        elevation:0,
        child: Padding(
          padding:const EdgeInsets.all(16),
          child:Text(
            data["reason"] ?? "-",
            style:const TextStyle(
              fontSize:15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _qtyBox(String title,int qty){
    return Column(
      children:[
        Text(
          title,
          style:TextStyle(
            color:Colors.grey.shade600,
          ),
        ),
        const SizedBox(height:5),
        Text(
          qty.toString(),
          style:const TextStyle(
            fontSize:26,
            fontWeight:FontWeight.bold,
          ),
        )
      ],
    );
  }

  Widget _chip(IconData icon,String text){
    return Container(
      padding:const EdgeInsets.symmetric(
        horizontal:8,
        vertical:5,
      ),
      decoration:BoxDecoration(
        color:Colors.grey.shade100,
        borderRadius:BorderRadius.circular(20),
      ),
      child:Row(
        mainAxisSize:MainAxisSize.min,
        children:[
          Icon(
            icon,
            size:14,
          ),
          const SizedBox(width:4),
          Text(
            text,
            style:const TextStyle(
              fontSize:12,
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon,String text){
    return Padding(
      padding:const EdgeInsets.only(bottom:8),
      child:Row(
        children:[
          Icon(
            icon,
            size:18,
            color:Colors.grey,
          ),
          const SizedBox(width:8),
          Text(text)
        ],
      ),
    );
  }

  Widget _sectionTitle(String text){
    return Padding(
      padding:const EdgeInsets.only(bottom:8),
      child:Text(
        text,
        style:const TextStyle(
          fontSize:18,
          fontWeight:FontWeight.bold,
        ),
      ),
    );
  }

  Widget _bottomActions(BuildContext context, Map data){
    return SafeArea(
      child:Container(
        padding:const EdgeInsets.all(16),
        child:Row(
          children:[
            Expanded(
              child:OutlinedButton.icon(
                onPressed:(){
                  ctr.onDeleteStockAdjustment(
                    data["id"],
                    context,
                  );
                },
                icon:const Icon(Icons.delete_outline),
                label:Text("Delete".tr),
                style:OutlinedButton.styleFrom(
                  foregroundColor:Colors.red,
                  minimumSize:
                  const Size.fromHeight(52),
                  shape:RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(width:12),

            Expanded(
              child:ElevatedButton.icon(
                onPressed:(){
                  ctr.editStockAdjustment(
                    context,
                    data["id"],
                  );
                },
                icon:
                const Icon(Icons.edit_outlined),
                label:
                Text("Edit".tr),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff1DB584),
                  foregroundColor:
                  Colors.white,
                  minimumSize:
                  const Size.fromHeight(52),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}