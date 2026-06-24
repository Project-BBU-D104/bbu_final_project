import 'package:flutter/material.dart';

class ButtonChangeTableOrCardWidget extends StatelessWidget {
  const ButtonChangeTableOrCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.table_rows_rounded),
          SizedBox(width: 50,),
        ],
      )
    );
  }
}