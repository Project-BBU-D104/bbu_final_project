import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screen/report/report_export_menu.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/services/main_service/purchase/purchase_service.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  final PurchaseService _service = PurchaseService();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  DateTime _startDate = _monthStart();
  DateTime _endDate = _monthEnd();
  List<Map<String, dynamic>> _purchases = [];
  bool _loading = true;
  bool _showChart = true;
  bool _showTable = true;

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
    _loadPurchases();
  }

  DateTime? _purchaseDate(Map<String, dynamic> purchase) {
    final date = DateTime.tryParse(purchase['purchase_date']?.toString() ?? '');
    return date?.toLocal();
  }

  double? _purchaseTotal(Map<String, dynamic> purchase) {
    final amount = double.tryParse(purchase['total_amount']?.toString() ?? '');
    return amount != null && amount.isFinite ? amount : null;
  }

  Future<void> _loadPurchases() async {
    if (mounted) setState(() => _loading = true);
    try {
      final response = await _service.getPurchases();
      if (response is! List) {
        throw const FormatException('Unexpected purchase response.');
      }

      final rows = <Map<String, dynamic>>[];
      var invalidCount = 0;
      for (final item in response) {
        if (item is! Map) {
          invalidCount++;
          continue;
        }

        final purchase = <String, dynamic>{
          for (final entry in item.entries)
            if (entry.key is String) entry.key as String: entry.value,
        };
        if (_purchaseDate(purchase) == null ||
            _purchaseTotal(purchase) == null) {
          invalidCount++;
          continue;
        }
        rows.add(purchase);
      }
      rows.sort((a, b) => _purchaseDate(b)!.compareTo(_purchaseDate(a)!));

      if (!mounted) return;
      setState(() => _purchases = rows);
      if (invalidCount > 0) {
        ToastWidget.show(
          message: '$invalidCount invalid purchase record(s) were excluded.',
          type: ToastType.error,
        );
      }
    } catch (error) {
      if (mounted) {
        ToastWidget.show(message: error.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPurchases {
    final start = DateUtils.dateOnly(_startDate);
    final end = DateUtils.dateOnly(_endDate);
    return _purchases.where((purchase) {
      final date = DateUtils.dateOnly(_purchaseDate(purchase)!);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  Future<void> _chooseDate({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (start) {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) _endDate = picked;
      } else {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) _startDate = picked;
      }
    });
  }

  Widget _dateButton({
    required String label,
    required DateTime date,
    required VoidCallback onPressed,
    required IconData icon,
  }) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text('$label: ${_dateFormat.format(date)}'),
  );

  Widget _buildDateFilter() => AppSectionCard(
    title: 'Date Range Filter',
    child: Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _dateButton(
          label: 'Start date'.tr,
          date: _startDate,
          icon: Icons.calendar_today_outlined,
          onPressed: () => _chooseDate(start: true),
        ),
        _dateButton(
          label: 'End date'.tr,
          date: _endDate,
          icon: Icons.event_outlined,
          onPressed: () => _chooseDate(start: false),
        ),
      ],
    ),
  );

  Widget _buildVisibilityOptions() => AppSectionCard(
    title: 'Customize Report',
    child: Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text('Show Chart'.tr),
          value: _showChart,
          onChanged: (value) => setState(() => _showChart = value ?? true),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text('Show Table'.tr),
          value: _showTable,
          onChanged: (value) => setState(() => _showTable = value ?? true),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    ),
  );

  Widget _buildChart() {
    final totalsByDate = <DateTime, double>{};
    for (final purchase in _filteredPurchases) {
      final date = DateUtils.dateOnly(_purchaseDate(purchase)!);
      totalsByDate.update(
        date,
        (total) => total + _purchaseTotal(purchase)!,
        ifAbsent: () => _purchaseTotal(purchase)!,
      );
    }
    final dates = totalsByDate.keys.toList()..sort();
    final spots = [
      for (var index = 0; index < dates.length; index++)
        FlSpot(index.toDouble(), totalsByDate[dates[index]]!),
    ];
    final maxY = spots.fold<double>(
      0,
      (maxValue, spot) => spot.y > maxValue ? spot.y : maxValue,
    );
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return AppSectionCard(
      title: 'Purchase Chart',
      child: spots.isEmpty
          ? const AppEmptyState(message: 'No purchases found')
          : SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY == 0 ? 1 : maxY * 1.2,
                  minX: 0,
                  maxX: spots.length == 1 ? 1 : (spots.length - 1).toDouble(),
                  gridData: FlGridData(
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: theme.colorScheme.outlineVariant),
                  ),
                  borderData: FlBorderData(show: false),
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
                        interval: dates.length <= 6
                            ? 1
                            : (dates.length / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dates.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              DateFormat('dd/MM').format(dates[index]),
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        getTitlesWidget: (value, meta) => Text(
                          NumberFormat.compact().format(value),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: color,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _supplierName(Map<String, dynamic> purchase) {
    final supplier = purchase['supplier'];
    return supplier is Map ? supplier['name']?.toString() ?? '' : '';
  }

  Widget _buildTable() {
    final purchases = _filteredPurchases;
    if (purchases.isEmpty) {
      return const AppEmptyState(message: 'No purchases found');
    }
    return AppTable<Map<String, dynamic>>(
      rows: purchases,
      columns: [
        AppTableColumn(
          title: 'Invoice',
          builder: (context, purchase) =>
              AppTableColumn.value(context, purchase['invoice_no']?.toString()),
        ),
        AppTableColumn(
          title: 'Supplier',
          builder: (context, purchase) =>
              AppTableColumn.value(context, _supplierName(purchase)),
        ),
        AppTableColumn(
          title: 'Date',
          builder: (context, purchase) => AppTableColumn.value(
            context,
            formatSaleDate(purchase['purchase_date']),
          ),
        ),
        AppTableColumn(
          title: 'Status',
          builder: (context, purchase) => AppTableColumn.value(
            context,
            salePaymentStatusLabel(
              purchase['payment_status'] ?? purchase['status'],
            ),
          ),
        ),
        AppTableColumn(
          title: 'Total',
          builder: (context, purchase) =>
              Text(formatSaleAmount(purchase['total_amount'])),
        ),
        AppTableColumn(
          title: 'Paid',
          builder: (context, purchase) =>
              Text(formatSaleAmount(purchase['paid_amount'])),
        ),
        AppTableColumn(
          title: 'Due',
          builder: (context, purchase) =>
              Text(formatSaleAmount(purchase['due_amount'])),
        ),
      ],
    );
  }

  ReportExportData _exportData() => ReportExportData(
    title:
        '${'Purchase Report'.tr} ${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
    headers: [
      'Invoice',
      'Supplier',
      'Date',
      'Status',
      'Total',
      'Paid',
      'Due',
    ].map((s) => s.tr).toList(),
    rows: [
      for (final purchase in _filteredPurchases)
        [
          purchase['invoice_no'] ?? '',
          _supplierName(purchase),
          formatSaleDate(purchase['purchase_date']),
          salePaymentStatusLabel(
            purchase['payment_status'] ?? purchase['status'],
          ),
          _purchaseTotal(purchase),
          double.tryParse(purchase['paid_amount']?.toString() ?? '') ?? '',
          double.tryParse(purchase['due_amount']?.toString() ?? '') ?? '',
        ],
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Purchase Report',
      showRefresh: true,
      onRefresh: _loadPurchases,
      actions: [ReportExportMenu(buildData: _exportData, enabled: !_loading)],
    ),
    body: AppPage(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildDateFilter(),
                const SizedBox(height: AppSpacing.lg),
                _buildVisibilityOptions(),
                if (_showChart) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildChart(),
                ],
                if (_showTable) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildTable(),
                ],
              ],
            ),
    ),
  );
}
