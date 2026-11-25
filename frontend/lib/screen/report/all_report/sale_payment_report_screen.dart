import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screen/report/report_date_range_fields.dart';
import 'package:frontend/screen/report/report_visibility_checkbox.dart';
import 'package:frontend/screen/report/report_export_menu.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalePaymentReportScreen extends StatefulWidget {
  const SalePaymentReportScreen({super.key});

  @override
  State<SalePaymentReportScreen> createState() =>
      _SalePaymentReportScreenState();
}

class _SalePaymentReportScreenState extends State<SalePaymentReportScreen> {
  final SalePaymentService _service = SalePaymentService();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  DateTime _startDate = _monthStart();
  DateTime _endDate = _monthEnd();
  List<Map<String, dynamic>> _payments = [];
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
    _loadPayments();
  }

  DateTime? _paymentDate(Map<String, dynamic> payment) {
    final date = DateTime.tryParse(payment['payment_date']?.toString() ?? '');
    return date?.toLocal();
  }

  double? _paymentAmount(Map<String, dynamic> payment) {
    final amount = double.tryParse(payment['amount']?.toString() ?? '');
    return amount != null && amount.isFinite ? amount : null;
  }

  Future<void> _loadPayments() async {
    if (mounted) setState(() => _loading = true);
    try {
      final response = await _service.getPayments();
      if (response is! List) {
        throw const FormatException('Unexpected sale payment response.');
      }

      final rows = <Map<String, dynamic>>[];
      var invalidCount = 0;
      for (final item in response) {
        if (item is! Map) {
          invalidCount++;
          continue;
        }

        final payment = <String, dynamic>{
          for (final entry in item.entries)
            if (entry.key is String) entry.key as String: entry.value,
        };
        if (_paymentDate(payment) == null || _paymentAmount(payment) == null) {
          invalidCount++;
          continue;
        }
        rows.add(payment);
      }
      rows.sort((a, b) => _paymentDate(b)!.compareTo(_paymentDate(a)!));

      if (!mounted) return;
      setState(() => _payments = rows);
      if (invalidCount > 0) {
        ToastWidget.show(
          message:
              '$invalidCount invalid sale payment record(s) were excluded.',
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

  List<Map<String, dynamic>> get _filteredPayments {
    final start = DateUtils.dateOnly(_startDate);
    final end = DateUtils.dateOnly(_endDate);
    return _payments.where((payment) {
      final date = DateUtils.dateOnly(_paymentDate(payment)!);
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

  Widget _buildDateFilter() => ReportDateRangeFields(
    startDate: _startDate,
    endDate: _endDate,
    onChooseStart: () => _chooseDate(start: true),
    onChooseEnd: () => _chooseDate(start: false),
  );

  Widget _buildVisibilityOptions() => Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.sm,
    children: [
      ReportVisibilityCheckbox(
        label: 'Show Chart'.tr,
        value: _showChart,
        onChanged: (value) => setState(() => _showChart = value ?? true),
      ),
      ReportVisibilityCheckbox(
        label: 'Show Table'.tr,
        value: _showTable,
        onChanged: (value) => setState(() => _showTable = value ?? true),
      ),
    ],
  );

  Widget _buildChart() {
    final totalsByDate = <DateTime, double>{};
    for (final payment in _filteredPayments) {
      final date = DateUtils.dateOnly(_paymentDate(payment)!);
      totalsByDate.update(
        date,
        (total) => total + _paymentAmount(payment)!,
        ifAbsent: () => _paymentAmount(payment)!,
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
      title: 'Sale Payment Chart',
      child: spots.isEmpty
          ? const AppEmptyState(message: 'No payments found')
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

  Widget _buildTable() {
    final payments = _filteredPayments;
    if (payments.isEmpty) {
      return const AppEmptyState(message: 'No payments found');
    }
    return AppTable<Map<String, dynamic>>(
      rows: payments,
      columns: [
        AppTableColumn(
          title: 'Invoice',
          builder: (context, payment) => AppTableColumn.value(
            context,
            saleMap(payment['sale'])['invoice_no'],
          ),
        ),
        AppTableColumn(
          title: 'Customer',
          builder: (context, payment) => AppTableColumn.value(
            context,
            saleMap(saleMap(payment['sale'])['customer'])['name']?.toString(),
          ),
        ),
        AppTableColumn(
          title: 'Amount',
          builder: (context, payment) =>
              Text(formatSaleAmount(payment['amount'])),
        ),
        AppTableColumn(
          title: 'Method',
          builder: (context, payment) => AppTableColumn.value(
            context,
            payment['payment_method']?.toString(),
          ),
        ),
        AppTableColumn(
          title: 'Reference',
          builder: (context, payment) => AppTableColumn.value(
            context,
            payment['reference_no']?.toString(),
          ),
        ),
        AppTableColumn(
          title: 'Date',
          builder: (context, payment) => AppTableColumn.value(
            context,
            formatSaleDate(payment['payment_date']),
          ),
        ),
      ],
    );
  }

  ReportExportData _exportData() => ReportExportData(
    title:
        '${'Sale Payment Report'.tr} ${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
    headers: [
      'Invoice',
      'Customer',
      'Amount',
      'Method',
      'Reference',
      'Date',
    ].map((s) => s.tr).toList(),
    rows: [
      for (final payment in _filteredPayments)
        [
          saleMap(payment['sale'])['invoice_no'] ?? '',
          saleMap(saleMap(payment['sale'])['customer'])['name'] ?? '',
          _paymentAmount(payment),
          payment['payment_method'] ?? '',
          payment['reference_no'] ?? '',
          formatSaleDate(payment['payment_date']),
        ],
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Sale Payment Report',
      showRefresh: true,
      onRefresh: _loadPayments,
      onBack: () => Navigator.pop(context),
      actions: [ReportExportMenu(buildData: _exportData, enabled: !_loading)],
    ),
    body: AppPage(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                AppSectionCard(
                  title: 'Filter',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDateFilter(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildVisibilityOptions(),
                    ],
                  ),
                ),

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
