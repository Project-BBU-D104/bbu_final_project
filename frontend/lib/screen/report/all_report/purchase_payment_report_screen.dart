import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screen/report/report_export_menu.dart';
import 'package:frontend/screen/purchase_payment/payment_format.dart';
import 'package:frontend/services/main_service/purchase/purchase_payment_service.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchasePaymentReportScreen extends StatefulWidget {
  const PurchasePaymentReportScreen({super.key});

  @override
  State<PurchasePaymentReportScreen> createState() =>
      _PurchasePaymentReportScreenState();
}

class _PurchasePaymentReportScreenState
    extends State<PurchasePaymentReportScreen> {
  final PurchasePaymentService _service = PurchasePaymentService();
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

  DateTime? _date(Map<String, dynamic> payment) =>
      DateTime.tryParse(payment['payment_date']?.toString() ?? '')?.toLocal();

  double? _amount(Map<String, dynamic> payment) {
    final value = double.tryParse(payment['amount']?.toString() ?? '');
    return value != null && value.isFinite ? value : null;
  }

  Future<void> _loadPayments() async {
    if (mounted) setState(() => _loading = true);
    try {
      final response = await _service.getPurchasePayments();
      if (response is! List) {
        throw const FormatException('Unexpected purchase payment response.');
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
        if (_date(payment) == null || _amount(payment) == null) {
          invalidCount++;
          continue;
        }
        rows.add(payment);
      }
      rows.sort((a, b) => _date(b)!.compareTo(_date(a)!));

      if (!mounted) return;
      setState(() => _payments = rows);
      if (invalidCount > 0) {
        ToastWidget.show(
          message:
              '$invalidCount invalid purchase payment record(s) were excluded.',
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
      final date = DateUtils.dateOnly(_date(payment)!);
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

  String _currencyLabel(Map<String, dynamic> payment) {
    final currency = payment['currency'];
    if (currency is! Map) return 'Unknown currency'.tr;
    final symbol = currency['symbol']?.toString().trim() ?? '';
    final name = currency['name']?.toString().trim() ?? '';
    return symbol.isNotEmpty ? '$symbol $name'.trim() : name;
  }

  Widget _buildChart() {
    final totals = <String, Map<DateTime, double>>{};
    for (final payment in _filteredPayments) {
      if ((payment['status'] ?? '').toString().toLowerCase() != 'completed') {
        continue;
      }
      final currency = _currencyLabel(payment);
      final date = DateUtils.dateOnly(_date(payment)!);
      totals
          .putIfAbsent(currency, () => <DateTime, double>{})
          .update(
            date,
            (value) => value + _amount(payment)!,
            ifAbsent: () => _amount(payment)!,
          );
    }

    final dates = totals.values.expand((values) => values.keys).toSet().toList()
      ..sort();
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.onSurfaceVariant,
    ];
    final currencies = totals.keys.toList()..sort();
    final lines = [
      for (
        var currencyIndex = 0;
        currencyIndex < currencies.length;
        currencyIndex++
      )
        LineChartBarData(
          spots: [
            for (var dateIndex = 0; dateIndex < dates.length; dateIndex++)
              FlSpot(
                dateIndex.toDouble(),
                totals[currencies[currencyIndex]]![dates[dateIndex]] ?? 0,
              ),
          ],
          isCurved: true,
          barWidth: 3,
          color: colors[currencyIndex % colors.length],
          dotData: const FlDotData(show: true),
        ),
    ];
    final maxY = lines.fold<double>(
      0,
      (maximum, line) => line.spots.fold<double>(
        maximum,
        (current, spot) => spot.y > current ? spot.y : current,
      ),
    );

    return AppSectionCard(
      title: 'Purchase Payment Chart',
      child: lines.isEmpty
          ? const AppEmptyState(message: 'No completed payments found')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (var index = 0; index < currencies.length; index++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: AppSpacing.sm,
                            color: colors[index % colors.length],
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(currencies[index]),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY == 0 ? 1 : maxY * 1.2,
                      minX: 0,
                      maxX: dates.length == 1
                          ? 1
                          : (dates.length - 1).toDouble(),
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
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
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
                      lineBarsData: lines,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _relationValue(Object? relation, String key) {
    if (relation is! Map) return '';
    return relation[key]?.toString() ?? '';
  }

  Widget _buildTable() {
    final payments = _filteredPayments;
    if (payments.isEmpty) {
      return const AppEmptyState(message: 'No purchase payments found');
    }
    return AppTable<Map<String, dynamic>>(
      rows: payments,
      columns: [
        AppTableColumn(
          title: 'Payment No',
          builder: (context, payment) =>
              AppTableColumn.value(context, payment['payment_no']?.toString()),
        ),
        AppTableColumn(
          title: 'Supplier',
          builder: (context, payment) => AppTableColumn.value(
            context,
            _relationValue(payment['supplier'], 'name'),
          ),
        ),
        AppTableColumn(
          title: 'Invoice',
          builder: (context, payment) => AppTableColumn.value(
            context,
            _relationValue(payment['purchase'], 'invoice_no'),
          ),
        ),
        AppTableColumn(
          title: 'Payment Type',
          builder: (context, payment) => AppTableColumn.value(
            context,
            _relationValue(payment['payment_type'], 'name'),
          ),
        ),
        AppTableColumn(
          title: 'Date',
          builder: (context, payment) => AppTableColumn.value(
            context,
            paymentDateText(payment['payment_date']),
          ),
        ),
        AppTableColumn(
          title: 'Amount',
          builder: (context, payment) =>
              AppTableColumn.value(context, paymentAmountText(payment)),
        ),
        AppTableColumn(
          title: 'Status',
          builder: (context, payment) => AppTableColumn.value(
            context,
            paymentStatusLabel(payment['status']?.toString()),
          ),
        ),
      ],
    );
  }

  ReportExportData _exportData() => ReportExportData(
    title:
        '${'Purchase Payment Report'.tr} ${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
    headers: [
      'Payment No',
      'Supplier',
      'Invoice',
      'Payment Type',
      'Date',
      'Amount',
      'Currency',
      'Status',
    ].map((s) => s.tr).toList(),
    rows: [
      for (final payment in _filteredPayments)
        [
          payment['payment_no'] ?? '',
          _relationValue(payment['supplier'], 'name'),
          _relationValue(payment['purchase'], 'invoice_no'),
          _relationValue(payment['payment_type'], 'name'),
          paymentDateText(payment['payment_date']),
          _amount(payment),
          _currencyLabel(payment),
          paymentStatusLabel(payment['status']?.toString()),
        ],
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Purchase Payment Report',
      showRefresh: true,
      onRefresh: _loadPayments,
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
