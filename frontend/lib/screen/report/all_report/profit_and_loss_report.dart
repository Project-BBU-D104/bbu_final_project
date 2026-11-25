import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screen/report/report_date_range_fields.dart';
import 'package:frontend/screen/report/report_visibility_checkbox.dart';
import 'package:frontend/screen/report/report_export_menu.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfitAndLossReport extends StatefulWidget {
  const ProfitAndLossReport({super.key});

  @override
  State<ProfitAndLossReport> createState() => _ProfitAndLossReportState();
}

class _ProfitLossRow {
  const _ProfitLossRow({
    required this.date,
    required this.invoice,
    required this.revenue,
    required this.costOfGoods,
    required this.status,
  });

  final DateTime date;
  final String invoice;
  final double revenue;
  final double? costOfGoods;
  final String status;

  double? get grossProfit =>
      costOfGoods == null ? null : revenue - costOfGoods!;
}

class _ProfitAndLossReportState extends State<ProfitAndLossReport> {
  final SaleService _saleService = SaleService();
  final ProductService _productService = ProductService();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  DateTime _startDate = _monthStart();
  DateTime _endDate = _monthEnd();
  List<_ProfitLossRow> _rows = [];
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

  static double? _amount(Object? value) {
    final amount = double.tryParse(value?.toString() ?? '');
    return amount != null && amount.isFinite ? amount : null;
  }

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    if (mounted) setState(() => _loading = true);
    try {
      final responses = await Future.wait([
        _saleService.getSales(),
        _productService.getProducts(),
      ]);
      final sales = responses[0];
      final products = responses[1];
      if (sales is! List || products is! List) {
        throw const FormatException('Unexpected profit and loss response.');
      }

      final costs = <int, double>{};
      for (final product in products) {
        if (product is! Map) continue;
        final id = int.tryParse(product['id']?.toString() ?? '');
        final cost = _amount(product['cost_price']);
        if (id != null && cost != null && cost >= 0) costs[id] = cost;
      }

      final rows = <_ProfitLossRow>[];
      var invalidCount = 0;
      for (final sale in sales) {
        if (sale is! Map ||
            sale['deleted_at'] != null ||
            (sale['status'] ?? '').toString().toLowerCase() != 'completed') {
          continue;
        }

        final date = DateTime.tryParse(
          sale['sale_date']?.toString() ?? '',
        )?.toLocal();
        final subtotal = _amount(sale['subtotal']);
        final discount = _amount(sale['discount_amount']);
        if (date == null || subtotal == null || discount == null) {
          invalidCount++;
          continue;
        }

        var costOfGoods = 0.0;
        var costsComplete = true;
        final items = sale['sale_items'];
        if (items is! List || items.isEmpty) costsComplete = false;
        if (items is List) {
          for (final item in items) {
            if (item is! Map || item['product'] is! Map) {
              costsComplete = false;
              continue;
            }
            final productId = int.tryParse(
              item['product']['id']?.toString() ?? '',
            );
            final quantity = _amount(item['qty']);
            final productCost = productId == null ? null : costs[productId];
            if (quantity == null || productCost == null) {
              costsComplete = false;
              continue;
            }
            costOfGoods += quantity * productCost;
          }
        }

        rows.add(
          _ProfitLossRow(
            date: date,
            invoice: sale['invoice_no']?.toString() ?? '',
            revenue: subtotal - discount,
            costOfGoods: costsComplete ? costOfGoods : null,
            status: sale['payment_status']?.toString() ?? '',
          ),
        );
      }
      rows.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() => _rows = rows);
      if (invalidCount > 0) {
        ToastWidget.show(
          message: '$invalidCount invalid sale record(s) were excluded.',
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

  List<_ProfitLossRow> get _filteredRows {
    final start = DateUtils.dateOnly(_startDate);
    final end = DateUtils.dateOnly(_endDate);
    return _rows.where((row) {
      final date = DateUtils.dateOnly(row.date);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  bool get _hasCompleteCosts =>
      _filteredRows.every((row) => row.costOfGoods != null);

  double get _totalRevenue =>
      _filteredRows.fold(0, (total, row) => total + row.revenue);

  double get _totalCostOfGoods =>
      _filteredRows.fold(0, (total, row) => total + (row.costOfGoods ?? 0));

  double get _grossProfit => _totalRevenue - _totalCostOfGoods;

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

  Widget _summaryCard(String title, String value, Color color) =>
      AppSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _buildSummary() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= AppTokens.bpTable ? 3 : 1;
            final width =
                (constraints.maxWidth - (columns - 1) * AppSpacing.md) /
                columns;
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                SizedBox(
                  width: width,
                  child: _summaryCard(
                    'Net Sales',
                    formatSaleAmount(_totalRevenue),
                    colors.primary,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _summaryCard(
                    'Estimated Cost of Goods Sold',
                    _hasCompleteCosts
                        ? formatSaleAmount(_totalCostOfGoods)
                        : 'Incomplete'.tr,
                    colors.tertiary,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _summaryCard(
                    'Estimated Gross Profit',
                    _hasCompleteCosts
                        ? formatSaleAmount(_grossProfit)
                        : 'Unavailable'.tr,
                    _hasCompleteCosts ? colors.primary : colors.error,
                  ),
                ),
              ],
            );
          },
        ),
        if (!_hasCompleteCosts) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Gross profit is unavailable because one or more sale items have '
                    'no current product cost.'
                .tr,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildChart() {
    final rows = _filteredRows;
    final daily = <DateTime, List<double>>{};
    for (final row in rows) {
      final date = DateUtils.dateOnly(row.date);
      final totals = daily.putIfAbsent(date, () => [0, 0, 0]);
      totals[0] += row.revenue;
      if (row.costOfGoods != null) {
        totals[1] += row.costOfGoods!;
        totals[2] += row.grossProfit!;
      }
    }
    final dates = daily.keys.toList()..sort();
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      theme.colorScheme.secondary,
    ];
    List<FlSpot> spotsFor(int series) => [
      for (var index = 0; index < dates.length; index++)
        FlSpot(index.toDouble(), daily[dates[index]]![series]),
    ];

    final lines = <LineChartBarData>[
      _line(spotsFor(0), colors[0]),
      if (_hasCompleteCosts) ...[
        _line(spotsFor(1), colors[1]),
        _line(spotsFor(2), colors[2]),
      ],
    ];
    final allValues = lines.expand((line) => line.spots).map((spot) => spot.y);
    final minValue = allValues.fold<double>(
      0,
      (minimum, value) => math.min(minimum, value),
    );
    final maxValue = allValues.fold<double>(
      0,
      (maximum, value) => math.max(maximum, value),
    );

    return AppSectionCard(
      title: 'Profit And Loss Chart',
      child: rows.isEmpty
          ? const AppEmptyState(message: 'No completed sales found')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _legend('Net Sales', colors[0]),
                    if (_hasCompleteCosts) ...[
                      _legend('Estimated Cost of Goods Sold', colors[1]),
                      _legend('Estimated Gross Profit', colors[2]),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      minY: minValue < 0 ? minValue * 1.2 : 0,
                      maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
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
                if (!_hasCompleteCosts) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Cost and gross profit lines are hidden because some '
                            'sale items have no current product cost.'
                        .tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _legend(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: AppSpacing.sm, color: color),
      const SizedBox(width: AppSpacing.xs),
      Text(label.tr),
    ],
  );

  LineChartBarData _line(List<FlSpot> spots, Color color) => LineChartBarData(
    spots: spots,
    isCurved: true,
    barWidth: 3,
    color: color,
    dotData: const FlDotData(show: true),
  );

  Widget _buildTable() {
    final rows = _filteredRows;
    if (rows.isEmpty) {
      return const AppEmptyState(message: 'No completed sales found');
    }
    return AppTable<_ProfitLossRow>(
      rows: rows,
      columns: [
        AppTableColumn(
          title: 'Invoice',
          builder: (context, row) => AppTableColumn.value(context, row.invoice),
        ),
        AppTableColumn(
          title: 'Date',
          builder: (context, row) =>
              AppTableColumn.value(context, _dateFormat.format(row.date)),
        ),
        AppTableColumn(
          title: 'Net Sales',
          builder: (context, row) => Text(formatSaleAmount(row.revenue)),
        ),
        AppTableColumn(
          title: 'Estimated Cost of Goods Sold',
          builder: (context, row) => AppTableColumn.value(
            context,
            row.costOfGoods == null
                ? 'Unavailable'.tr
                : formatSaleAmount(row.costOfGoods),
          ),
        ),
        AppTableColumn(
          title: 'Estimated Gross Profit',
          builder: (context, row) => AppTableColumn.value(
            context,
            row.grossProfit == null
                ? 'Unavailable'.tr
                : formatSaleAmount(row.grossProfit),
          ),
        ),
        AppTableColumn(
          title: 'Status',
          builder: (context, row) =>
              AppTableColumn.value(context, salePaymentStatusLabel(row.status)),
        ),
      ],
    );
  }

  ReportExportData _exportData() {
    final filtered = _filteredRows;
    return ReportExportData(
      title:
          '${'Profit and Loss Report'.tr} ${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
      headers: [
        'Invoice',
        'Date',
        'Net Sales',
        'Estimated Cost of Goods Sold',
        'Estimated Gross Profit',
        'Status',
      ].map((s) => s.tr).toList(),
      notes: [
        'Gross profit is an estimate based on current product cost prices. Operating expenses, historical cost prices, and currency conversion are not included.'
            .tr,
        if (!_hasCompleteCosts)
          'Gross profit is unavailable because one or more sale items have no current product cost.'
              .tr,
      ],
      rows: [
        for (final row in filtered)
          [
            row.invoice,
            _dateFormat.format(row.date),
            row.revenue,
            row.costOfGoods ?? 'Unavailable'.tr,
            row.grossProfit ?? 'Unavailable'.tr,
            salePaymentStatusLabel(row.status),
          ],
        if (filtered.isNotEmpty)
          [
            'Total'.tr,
            '',
            _totalRevenue,
            _hasCompleteCosts ? _totalCostOfGoods : 'Incomplete'.tr,
            _hasCompleteCosts ? _grossProfit : 'Unavailable'.tr,
            '',
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Profit and Loss Report',
      showRefresh: true,
      onRefresh: _loadReport,
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
                const SizedBox(height: AppSpacing.lg),
                AppSectionCard(
                  child: Text(
                    'Gross profit is an estimate based on current product cost '
                            'prices. Operating expenses, historical cost prices, and '
                            'currency conversion are not included.'
                        .tr,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSummary(),

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
