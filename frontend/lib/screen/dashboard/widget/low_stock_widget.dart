import 'package:flutter/material.dart';

class LowStockWidget extends StatelessWidget {
  LowStockWidget({super.key});

  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Laptop ASUS',
      'price': 850.00,
      'stock': 12,
    },
    {
      'id': 2,
      'name': 'Keyboard',
      'price': 35.00,
      'stock': 25,
    },
    {
      'id': 3,
      'name': 'Mouse',
      'price': 20.00,
      'stock': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
              ),
              child: const Text(
                'Low Stock Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

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
                            'Price',
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
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(product['id'].toString()),
                            ),
                            DataCell(
                              Text(product['name']),
                            ),
                            DataCell(
                              Text(
                                '\$${product['price'].toStringAsFixed(2)}',
                              ),
                            ),
                            DataCell(
                              Text(
                                product['stock'].toString(),
                                style: TextStyle(
                                  color: product['stock'] < 10
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
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