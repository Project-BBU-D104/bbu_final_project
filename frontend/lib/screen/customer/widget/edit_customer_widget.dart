import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class EditCustomerWidget extends StatelessWidget {
  const EditCustomerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Edit Customer",
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

          Text("Customer Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: "Customer Name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: "Phone Number",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Address", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
           TextField(
              maxLines: 8,
              minLines: 3,
              decoration: InputDecoration(
                hintText: "Address",
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
                foregroundColor: titleColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(fontSize: 18),),
            ),
          ),
        ],
      ),
    );
  }
}