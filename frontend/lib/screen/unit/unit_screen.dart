import 'package:flutter/material.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/screen/unit/widget/unit_card_widget.dart';
import 'package:frontend/screen/unit/widget/unit_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class UnitScreen extends StatelessWidget {
  UnitScreen({super.key});

  final ctr = Get.put(UnitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Unit"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(height: 4),
              SearchWidget(title: "Search Unit"),

              SizedBox(height: 16),

              Obx(() {
                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (ctr.unitList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text("No Unit Found".tr)),
                  );
                }

                if (ctr.searchUnitList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text("Search Not Found".tr)),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 700) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ctr.searchUnitList.length,
                        padding: const EdgeInsets.only(bottom: 50),
                        itemBuilder: (context, index) {
                          return UnitCardWidget(
                            units: ctr.searchUnitList[index],
                          );
                        },
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          const _UnitTableHeader(),
                          ...ctr.searchUnitList.map(
                            (unit) => UnitTableWidget(units: unit),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ctr.addUnit(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _UnitTableHeader extends StatelessWidget {
  const _UnitTableHeader();

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('UNIT', style: headerStyle)),
          Expanded(flex: 2, child: Text('STATUS', style: headerStyle)),
          Expanded(flex: 2, child: Text('CREATED', style: headerStyle)),
          Expanded(flex: 2, child: Text('UPDATED', style: headerStyle)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
