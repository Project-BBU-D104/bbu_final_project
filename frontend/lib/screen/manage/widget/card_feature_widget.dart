import 'package:flutter/material.dart';

class CardFeatureWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  Function onTap;
  
  CardFeatureWidget(
    {
      super.key,
      required this.title,
      required this.icon,
      required this.subtitle,
      required this.onTap
    }
  );

  @override
  Widget build(BuildContext context) {
    return Card (
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon)),
              const SizedBox(height: 10,),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              Text(subtitle, style: const TextStyle(color: Colors.grey),),
            ],
          ),
        ),
      )
    );
  }
}