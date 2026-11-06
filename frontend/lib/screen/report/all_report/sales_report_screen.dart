import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/report_export_controller.dart';
import 'package:frontend/screen/report/pdf_preview_screen.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/utils/sales_report_utils.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime startDate = _monthStart();
  DateTime endDate = _monthEnd();

  bool showKpi = true;
  bool showChart = true;
  bool showTable = true;
  bool loading = true;

  String searchText = '';
  final TextEditingController searchController = TextEditingController();

  final dateFormat = DateFormat('dd MMM yyyy');
  final currencyFormat = NumberFormat('#,##0.00');

  final SaleService service = SaleService();
  final ReportExportController exportCtr = ReportExportController();
  List<Map<String, dynamic>> sales = [];

  /// Invoice keys whose product breakdown is currently expanded.
  final Set<String> _expandedInvoices = <String>{};

  static DateTime _monthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  static DateTime _monthEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// ponytail: filters the whole sales list client-side; move to
  /// GET /sale?start_date=&end_date= once the list is too big to fetch.
  Future<void> loadSales() async {
    if (mounted) setState(() => loading = true);
    try {
      final resp = await service.getSales();
      final rows = <Map<String, dynamic>>[];
      var invalidSaleCount = 0;

      if (resp is List) {
        for (final item in resp) {
          if (item is! Map) {
            invalidSaleCount++;
            continue;
          }
          final sale = Map<String, dynamic>.from(item);

          // Soft-deleted and cancelled sales are not sales.
          if (sale['deleted_at'] != null) continue;
          if ((sale['status'] ?? '').toString().toLowerCase() == 'cancelled') {
            continue;
          }

          final row = saleReportRow(sale);
          if (row == null) {
            invalidSaleCount++;
            continue;
          }

          rows.add(row);
        }
      }

      if (!mounted) return;
      setState(() => sales = rows);
      if (invalidSaleCount > 0) {
        ToastWidget.show(
          message:
              '$invalidSaleCount invalid sale record(s) were excluded.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastWidget.show(message: e.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> get filteredSales {
    final query = searchText.trim().toLowerCase();
    return sales.where((sale) {
      final DateTime date = sale['date'];

      final bool inDateRange =
          !date.isBefore(DateUtils.dateOnly(startDate)) &&
          !date.isAfter(DateUtils.dateOnly(endDate));

      return inDateRange && saleMatchesSearch(sale, query);
    }).toList();
  }

  double get totalSales {
    return filteredSales.fold<double>(
      0,
      (sum, sale) => sum + (sale['total'] as num).toDouble(),
    );
  }

  int get totalOrders => filteredSales.length;

  double get averageOrderValue {
    if (totalOrders == 0) return 0;
    return totalSales / totalOrders;
  }

  Future<void> chooseDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = picked;

        if (startDate.isAfter(endDate)) {
          endDate = startDate;
        }
      } else {
        endDate = picked;

        if (endDate.isBefore(startDate)) {
          startDate = endDate;
        }
      }
    });
  }

  Widget sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget dateButton({
    required String label,
    required DateTime date,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        '$label: ${dateFormat.format(date)}',
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget buildDateFilter() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Date Range Filter', Icons.date_range),
            const SizedBox(height: 16),

            // Keep both date filters in the same section.
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 450;

                final fromButton = dateButton(
                  label: 'From',
                  date: startDate,
                  icon: Icons.calendar_today,
                  onPressed: () => chooseDate(true),
                );

                final toButton = dateButton(
                  label: 'To',
                  date: endDate,
                  icon: Icons.event,
                  onPressed: () => chooseDate(false),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: fromButton),
                      const SizedBox(width: 12),
                      Expanded(child: toButton),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [fromButton, const SizedBox(height: 8), toButton],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildKpiCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildKpiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Sales Overview', Icons.dashboard),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 500
                ? 3
                : 1;

            final double itemWidth =
                (constraints.maxWidth - (columns - 1) * 12) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: buildKpiCard(
                    title: 'Total Sales',
                    value: '\$${currencyFormat.format(totalSales)}',

                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: buildKpiCard(
                    title: 'Total Orders',
                    value: '$totalOrders',

                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: buildKpiCard(
                    title: 'Average Order',
                    value: '\$${currencyFormat.format(averageOrderValue)}',
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildChartSection() {
    final int days = endDate.difference(startDate).inDays + 1;
    final totalsByDay = <int, double>{};
    for (final sale in filteredSales) {
      final dayIndex = DateUtils.dateOnly(
        sale['date'],
      ).difference(DateUtils.dateOnly(startDate)).inDays;
      totalsByDay.update(
        dayIndex,
        (total) => total + (sale['total'] as num).toDouble(),
        ifAbsent: () => (sale['total'] as num).toDouble(),
      );
    }
    final spots = List<FlSpot>.generate(
      days,
      (index) => FlSpot(index.toDouble(), totalsByDay[index] ?? 0),
    );

    final double maxY = spots.fold<double>(
      0,
      (maximum, spot) => spot.y > maximum ? spot.y : maximum,
    );

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Sales Chart', Icons.show_chart),
            const SizedBox(height: 24),

            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY == 0 ? 100 : maxY * 1.2,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (days / 7).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();

                          if (index < 0 || index >= days) {
                            return const SizedBox.shrink();
                          }

                          final DateTime day = startDate.add(
                            Duration(days: index),
                          );

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(day),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.blue,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleInvoice(String key) {
    setState(() {
      if (!_expandedInvoices.remove(key)) {
        _expandedInvoices.add(key);
      }
    });
  }

  String get _exportTitle =>
      'Sales Report ${dateFormat.format(startDate)} - '
      '${dateFormat.format(endDate)}';

  Future<PdfPageFormat?> _askPdfOrientation() {
    return showDialog<PdfPageFormat>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('PDF Orientation'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, PdfPageFormat.a4),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.crop_portrait),
              title: Text('Portrait'),
              subtitle: Text('A4 portrait'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(context, PdfPageFormat.a4.landscape),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.crop_landscape),
              title: Text('Landscape'),
              subtitle: Text('A4 landscape'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportAction(String action) async {
    if (filteredSales.isEmpty) {
      ToastWidget.show(
        message: 'No sales data to export.',
        type: ToastType.error,
      );
      return;
    }

    final title = _exportTitle;
    final headers = salesExportHeaders;
    final rows = saleExportRows(filteredSales);

    if (action == 'excel') {
      final path = await exportCtr.exportExcel(
        title: title,
        headers: headers,
        rows: rows,
      );
      if (mounted && path != null) {
        ToastWidget.show(
          message: 'Excel saved to:\n$path',
          type: ToastType.success,
        );
      }
    } else if (action == 'pdf') {
      final pageFormat = await _askPdfOrientation();
      if (pageFormat == null || !mounted) return;

      final path = await exportCtr.exportPdf(
        title: title,
        headers: headers,
        rows: rows,
        pageFormat: pageFormat,
        summaryTotal: totalSales,
      );
      if (mounted && path != null) {
        ToastWidget.show(
          message: 'PDF saved to:\n$path',
          type: ToastType.success,
        );
      }
    } else if (action == 'preview') {
      Get.to(
        () => PdfPreviewScreen(
          title: title,
          headers: headers,
          rows: rows,
          summaryTotal: totalSales,
        ),
      );
    }
  }

  Widget buildTableSection() {
    final sales = filteredSales;
    final dataRows = <DataRow>[];

    for (var index = 0; index < sales.length; index++) {
      final sale = sales[index];
      // Duplicate lines of the same product in one invoice are collapsed
      // into a single row with the summed quantity.
      final items = mergeSaleItems((sale['items'] as List?) ?? const []);
      final invoice = sale['invoice'].toString();
      // Invoice numbers are unique, but fall back to the row index so the
      // expand state still works for records without one.
      final key = invoice.isNotEmpty ? invoice : 'row_$index';
      final isExpanded = _expandedInvoices.contains(key);
      final isPaid = sale['status'] == 'Paid';

      dataRows.add(
        DataRow(
          color: WidgetStatePropertyAll<Color?>(
            isExpanded ? Colors.blue.withValues(alpha: 0.06) : null,
          ),
          cells: [
            DataCell(
              InkWell(
                onTap: () => _toggleInvoice(key),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(invoice),
                    ],
                  ),
                ),
              ),
            ),
            DataCell(Text(sale['customer'].toString())),
            DataCell(Text(dateFormat.format(sale['date'] as DateTime))),
            DataCell(
              Text('${items.length} item${items.length == 1 ? '' : 's'}'),
            ),
            const DataCell(Text('')),
            const DataCell(Text('')),
            DataCell(
              Text(
                '\$${currencyFormat.format(sale['total'])}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataCell(
              Text(
                sale['status'].toString(),
                style: TextStyle(
                  color: isPaid ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (!isExpanded) continue;

      if (items.isEmpty) {
        dataRows.add(
          DataRow(
            cells: const [
              DataCell(Text('')),
              DataCell(Text('')),
              DataCell(Text('')),
              DataCell(
                Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Text('No items recorded'),
                ),
              ),
              DataCell(Text('-')),
              DataCell(Text('-')),
              DataCell(Text('-')),
              DataCell(Text('')),
            ],
          ),
        );
        continue;
      }

      for (final item in items) {
        final data = item;
        final qty = data['qty'].toString();
        final unit = data['unit'].toString().trim();

        dataRows.add(
          DataRow(
            color: WidgetStatePropertyAll<Color?>(
              Colors.blue.withValues(alpha: 0.025),
            ),
            cells: [
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              DataCell(
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(data['product'].toString()),
                ),
              ),
              DataCell(Text(unit.isEmpty ? qty : '$qty $unit')),
              DataCell(Text('\$${currencyFormat.format(data['price'])}')),
              DataCell(Text('\$${currencyFormat.format(data['amount'])}')),
              const DataCell(Text('')),
            ],
          ),
        );
      }
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Sales Details', Icons.receipt_long),

            
            // Give the table at least the available width so it fills the
            // card, while still allowing horizontal scrolling when the
            // columns need more room than the screen has.
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Invoice')),
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Qty'), numeric: true),
                        DataColumn(label: Text('Price'), numeric: true),
                        DataColumn(label: Text('Amount'), numeric: true),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: dataRows,
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

  Widget visibilityCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget buildCustomizeReport() {
    return Card(
      elevation: 1,
      child: ExpansionTile(
        leading: const Icon(Icons.tune),
        title: const Text(
          'Customize Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          visibilityCheckbox(
            title: 'Show KPI Cards',
            value: showKpi,
            onChanged: (value) {
              setState(() => showKpi = value ?? true);
            },
          ),
          visibilityCheckbox(
            title: 'Show Sales Chart',
            value: showChart,
            onChanged: (value) {
              setState(() => showChart = value ?? true);
            },
          ),
          visibilityCheckbox(
            title: 'Show Sales Table',
            value: showTable,
            onChanged: (value) {
              setState(() => showTable = value ?? true);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Sales Report",
        centerTitle: false,
        showRefresh: true,
        onRefresh: loadSales,
        actions: [
          Obx(() {
            if (exportCtr.isExporting.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            return PopupMenuButton<String>(
              tooltip: 'Export / Print',
              icon: Icon(Icons.print_outlined, color: darkColor),
              onSelected: _handleExportAction,
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 12),
                      Text('Print Preview'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 20),
                      SizedBox(width: 12),
                      Text('Export PDF'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, size: 20),
                      SizedBox(width: 12),
                      Text('Export Excel'),
                    ],
                  ),
                ),
              ],
            );
          }),
          IconButton(
            tooltip: 'Reset filters',
            icon: Icon(Icons.filter_alt_off_outlined, color: darkColor),
            onPressed: () {
              setState(() {
                startDate = _monthStart();
                endDate = _monthEnd();
                searchText = '';
              });
              searchController.clear();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double contentWidth = constraints.maxWidth > 1200
                ? 1200
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // The two date filters stay grouped.
                          buildDateFilter(),

                          const SizedBox(height: 16),

                          buildCustomizeReport(),

                          if (showKpi) ...[
                            const SizedBox(height: 16),
                            buildKpiSection(),
                          ],

                          if (showChart) ...[
                            const SizedBox(height: 16),
                            buildChartSection(),
                          ],

                          if (showTable) ...[
                            const SizedBox(height: 16),
                            buildTableSection(),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
