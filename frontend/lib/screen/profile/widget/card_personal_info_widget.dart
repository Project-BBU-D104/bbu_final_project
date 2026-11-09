import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/widget/info_card_widget.dart';
import 'package:get/get.dart';

class CardPersonalInfoWidget extends StatelessWidget {
  CardPersonalInfoWidget({super.key});

  final ctr = Get.find<ProfileController>(); 
  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline_outlined),
                  SizedBox(width: 10,),
                  Text("Personal Info Widget".tr, style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Divider(),
              
              Text("Full Name".tr, style: TextStyle(fontWeight: FontWeight.w600),),
              SizedBox(height: 5,),
              Obx(() => InfoCardWidget(
                  title: ctr.username.value,
                ),
              ),
              SizedBox(height: 10,),

              Text("Email Address".tr, style: TextStyle(fontWeight: FontWeight.w600),),
              SizedBox(height: 5,),
              Obx(()=> InfoCardWidget(
                  title: ctr.email.value,
                ),
              ),
              
              Obx(
                () => ctr.phone.value.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10,),
                          Text("Phone Number".tr, style: TextStyle(fontWeight: FontWeight.w600),),
                          SizedBox(height: 5,),
                          InfoCardWidget(
                            title: ctr.phone.value,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
