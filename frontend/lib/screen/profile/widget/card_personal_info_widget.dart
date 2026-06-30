import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class CardPersonalInfoWidget extends StatelessWidget {
  const CardPersonalInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: titleColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline_outlined),
                  SizedBox(width: 10,),
                  Text("Personal Info Widget", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Divider(),
              
              Text("Full Name", style: TextStyle(fontWeight: FontWeight.w600),),
              SizedBox(height: 5,),
              cardInfo(
                title: "Lim Sabrey",
              ),
              SizedBox(height: 10,),

              Text("Email Address", style: TextStyle(fontWeight: FontWeight.w600),),
              SizedBox(height: 5,),
              cardInfo(
                title: "2A2kW@example.com",
              ),

              SizedBox(height: 10,),
              Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w600),),
              SizedBox(height: 5,),
              cardInfo(
                title: "+60123456789",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget cardInfo({
  required String title,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC), // soft background
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}