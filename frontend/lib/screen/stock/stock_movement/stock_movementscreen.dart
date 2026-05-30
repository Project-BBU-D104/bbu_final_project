import 'package:flutter/material.dart';

class StockMovementscreen extends StatelessWidget {
  const StockMovementscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1323),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1323),
        elevation: 0,
        title: const Text(
          "Stock Movement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tabs
            Row(
              children: [
                _tabButton("All Records", true),
                const SizedBox(width: 10),
                _tabButton("Stock In", false),
                const SizedBox(width: 10),
                _tabButton("Stock Out", false),
              ],
            ),

            const SizedBox(height: 16),

            // Date Filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18233B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white70,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Oct 24 - Oct 31, 2023",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _iconButton(Icons.filter_alt_outlined),
                const SizedBox(width: 10),
                _iconButton(Icons.download_outlined),
              ],
            ),

            const SizedBox(height: 20),

            // Total Inbound
            _summaryCard(
              title: "Total Inbound",
              value: "1,240",
              color: Colors.greenAccent,
              subtitle: "+ 15% from last week",
            ),

            const SizedBox(height: 15),

            // Total Outbound
            _summaryCard(
              title: "Total Outbound",
              value: "842",
              color: Colors.redAccent,
              subtitle: "- 5% from last week",
            ),

            const SizedBox(height: 15),

            // Most Active Location
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18233B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Most Active Location",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.greenAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "North Warehouse - Sector A",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Movement Log
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18233B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        "Movement Log",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  _movementItem(
                    "Industrial Ball Bearings - SKF 6205",
                    "Inbound Shipment",
                    "+250",
                    Colors.greenAccent,
                  ),

                  const Divider(color: Colors.white24),

                  _movementItem(
                    "Steel Pipes",
                    "Outbound Shipment",
                    "-120",
                    Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D1323),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "Stock",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "Alerts",
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? Colors.greenAccent.withOpacity(0.2)
            : const Color(0xFF18233B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: active ? Colors.greenAccent : Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF18233B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18233B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _movementItem(String title, String type, String qty, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.inventory, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(type, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        Text(
          qty,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
