import 'package:flutter/material.dart';

class RecentStockOutWidget extends StatelessWidget {
  const RecentStockOutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          Text("Recent Stock Out",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 10,),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: const [
                    DataRow(
                      cells: [
                        DataCell(Text('Coffee')),
                        DataCell(Text('2')),
                        DataCell(Text('\$4.00')),
                        DataCell(Text('7/1/2026')),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('Tea')),
                        DataCell(Text('1')),
                        DataCell(Text('\$2.50')),
                        DataCell(Text('7/1/2023')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}