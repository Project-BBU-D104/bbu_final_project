import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';

class CardProfileWidget extends StatelessWidget {
  const CardProfileWidget({super.key});

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
                Text("Lim Sabrey",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,   
                  ),
                ),
                Text("Admin", style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,   
                  ),),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (){},
                    label: Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 68, 238, 193),
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    icon: Icon(Icons.edit)
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}