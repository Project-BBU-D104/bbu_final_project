import 'package:flutter/material.dart';

class CardProfileWidget extends StatelessWidget {
  const CardProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(  
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRu3-_TbUInL975rAfMjR83kQAjePhVRRJFfw&s',
                    ),
                ),
                Text("Sabrey"),
                Text("Admin"),
                ElevatedButton.icon(
                  onPressed: (){},
                  label: Text("Edit Profile"),
                  icon: Icon(Icons.edit)
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}