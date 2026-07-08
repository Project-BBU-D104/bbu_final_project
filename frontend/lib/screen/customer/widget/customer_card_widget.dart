import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class CustomerCardWidget extends StatelessWidget {

  final Map<String, dynamic> customer;
  CustomerCardWidget({super.key, required this.customer});

  final ctr = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: titleColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOP USER INFO
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                        customer['photo'] != null && customer['photo'].toString().isNotEmpty
                        ? customer['photo']
                        : "https://i.pravatar.cc/150?img=12",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                  
                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            customer['name'] ?? "Unknown Customer",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          StatusWidget(text: "Active", color: successColor,)
                          // StatusWidget(
                          //   text: customer.status == true
                          //       ? "Active"
                          //       : "Inactive",
                          // )
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            customer['phone'] ?? "Unknown Phone",
                            style: TextStyle(
                              
                              fontSize: 16,
                            ),
                          ),
                            PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              switch (value) {
                                case "edit":
                                  ctr.editCustomer(context, customer);
                                  break;

                                case "delete":
                                  ctr.onDeleteCustomer(customer["id"]);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: "edit",
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20),
                                    SizedBox(width: 10),
                                    Text("Edit".tr),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: "delete",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Delete".tr,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),
            // ADDRESS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    customer['address'] ?? "Unknown Address",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            // ADDRESS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.date_range_outlined,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    customer['created_at'] ?? "Unknown Date",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}