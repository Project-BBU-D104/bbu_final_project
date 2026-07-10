import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:get/get.dart';

class CardProfileWidget extends StatelessWidget {

  CardProfileWidget({super.key});
    final ctr = Get.find<ProfileController>(); 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(  
        color: titleColor,
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRu3-_TbUInL975rAfMjR83kQAjePhVRRJFfw&s',
                  ),
                ),
                const SizedBox(height: 5,),
                Obx(()=> Text(
                    ctr.username.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,   
                    ),
                  ),
                ),
                Text("Admin", style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,   
                  ),),
              ],
            ),
          ),
        )
      ),
    );
  }
}