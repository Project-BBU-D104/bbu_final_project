import 'package:flutter/material.dart';
import 'package:frontend/screen/unit/widget/unit_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';

class UnitScreen extends StatelessWidget {
  const UnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Unit"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Role"),
          
              UnitCardWidget(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // ctr.addRole(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}