import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LowStockWidget extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const LowStockWidget({super.key, required this.products});

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat money = NumberFormat('#,##0.00');

    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Padding(
              padding: EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
              ),
              child: Text(
                'Low Stock Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('No low stock products'),
              )
            else
              // DataTable
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: 30,
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade100,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Product',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          DataColumn(
                            label: Text(
                              'Stock',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: products.map((product) {
                          final stock = _toDouble(product['stock_quantity']);
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(product['id']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Text(product['product_name']?.toString() ?? '-'),
                              ),
                               
                              DataCell(
                                Text(
                                  stock.toStringAsFixed(0),
                                  style: TextStyle(
                                    color:
                                        stock < 10 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
