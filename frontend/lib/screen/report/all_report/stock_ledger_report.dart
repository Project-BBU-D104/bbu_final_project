import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screen/report/report_date_range_fields.dart';
import 'package:frontend/screen/report/report_visibility_checkbox.dart';
import 'package:frontend/screen/report/report_export_menu.dart';
import 'package:frontend/services/main_service/product_transfer_service.dart';
import 'package:frontend/services/main_service/purchase/purchase_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/services/main_service/stock_adjustment_service.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StockLedgerReport extends StatefulWidget {
  const StockLedgerReport({super.key});

  @override
  State<StockLedgerReport> createState() => _StockLedgerReportState();
}

class _StockLedgerReportState extends State<StockLedgerReport> {
  final PurchaseService _purchaseService = PurchaseService();
  final SaleService _saleService = SaleService();
  final StockAdjustmentService _adjustmentService = StockAdjustmentService();
  final ProductTransferService _transferService = ProductTransferService();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _quantityFormat = NumberFormat('#,##0.###');
  DateTime _startDate = _monthStart();
  DateTime _endDate = _monthEnd();
  List<Map<String, dynamic>> _entries = [];
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

  static DateTime? _date(Object? value) =>
      DateTime.tryParse(value?.toString() ?? '')?.toLocal();

  static double? _quantity(Object? value) {
    final quantity = double.tryParse(value?.toString() ?? '');
    return quantity != null && quantity.isFinite && quantity > 0
        ? quantity
        : null;
  }

  static String _relationName(Object? value, String key) {
    if (value is! Map) return '';
    return value[key]?.toString() ?? '';
  }

  static String _productUnit(Object? product) {
    if (product is! Map || product['unit'] is! Map) return '';
    final unit = product['unit'];
    return (unit['short_name'] ?? unit['name'] ?? '').toString();
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  bool _appendEntry(
    List<Map<String, dynamic>> entries, {
    required Object? rawDate,
    required Object? rawProduct,
    required String warehouse,
    required String type,
    required String reference,
    required Object? rawQuantity,
    required bool isIncoming,
    String note = '',
  }) {
    final date = _date(rawDate);
    final quantity = _quantity(rawQuantity);
    final product = _relationName(rawProduct, 'name');
    if (date == null || quantity == null || product.isEmpty) return false;
    entries.add({
      'date': date,
      'product': product,
      'unit': _productUnit(rawProduct),
      'warehouse': warehouse,
      'type': type,
      'reference': reference,
      'incoming': isIncoming ? quantity : 0.0,
      'outgoing': isIncoming ? 0.0 : quantity,
      'note': note,
    });
    return true;
  }

  Future<void> _loadEntries() async {
    if (mounted) setState(() => _loading = true);
    try {
      final responses = await Future.wait([
        _purchaseService.getPurchases(),
        _saleService.getSales(),
        _adjustmentService.getStockAdjustments(),
        _transferService.getProductTransfers(),
      ]);
      if (responses.any((response) => response is! List)) {
        throw const FormatException('Unexpected stock movement response.');
      }

      final entries = <Map<String, dynamic>>[];
      var invalidCount = 0;
      void addLines(
        Object? rawLines,
        bool Function(Map<dynamic, dynamic> line) addLine,
      ) {
        if (rawLines is! List) {
          invalidCount++;
          return;
        }
        for (final line in rawLines) {
          if (line is Map) {
            if (!addLine(line)) invalidCount++;
          } else {
            invalidCount++;
          }
        }
      }

      for (final raw in responses[0] as List) {
        if (raw is! Map) {
          invalidCount++;
          continue;
        }
        if ((raw['status'] ?? '').toString().toLowerCase() == 'cancelled') {
          continue;
        }
        addLines(raw['purchase_items'], (item) {
          return _appendEntry(
            entries,
            rawDate: raw['purchase_date'],
            rawProduct: item['product'],
            warehouse: _relationName(raw['warehouse'], 'name'),
            type: 'Purchase',
            reference: raw['invoice_no']?.toString() ?? '',
            rawQuantity: item['qty'],
            isIncoming: true,
          );
        });
      }

      for (final raw in responses[1] as List) {
        if (raw is! Map) {
          invalidCount++;
          continue;
        }
        if (raw['deleted_at'] != null ||
            (raw['status'] ?? '').toString().toLowerCase() == 'cancelled') {
          continue;
        }
        addLines(raw['sale_items'], (item) {
          return _appendEntry(
            entries,
            rawDate: raw['sale_date'],
            rawProduct: item['product'],
            warehouse: '',
            type: 'Sale',
            reference: raw['invoice_no']?.toString() ?? '',
            rawQuantity: item['qty'],
            isIncoming: false,
          );
        });
      }

      for (final raw in responses[2] as List) {
        if (raw is! Map) {
          invalidCount++;
          continue;
        }
        final type = (raw['adjustment_type'] ?? '').toString().toLowerCase();
        if (type != 'increase' && type != 'decrease') {
          invalidCount++;
          continue;
        }
        if (!_appendEntry(
          entries,
          rawDate: raw['created_at'],
          rawProduct: raw['product'],
          warehouse: _relationName(raw['warehouse'], 'name'),
          type: type == 'increase' ? 'Adjustment In' : 'Adjustment Out',
          reference: raw['reference_no']?.toString() ?? '',
          rawQuantity: raw['qty'],
          isIncoming: type == 'increase',
          note: raw['reason']?.toString() ?? '',
        )) {
          invalidCount++;
        }
      }

      for (final raw in responses[3] as List) {
        if (raw is! Map) {
          invalidCount++;
          continue;
        }
        addLines(raw['product_transfer_items'], (item) {
          final from = _relationName(raw['from_warehouse'], 'name');
          final to = _relationName(raw['to_warehouse'], 'name');
          final reference = raw['reference_no']?.toString() ?? '';
          final addedOut = _appendEntry(
            entries,
            rawDate: raw['transfer_date'],
            rawProduct: item['product'],
            warehouse: from,
            type: 'Transfer Out',
            reference: reference,
            rawQuantity: item['qty'],
            isIncoming: false,
          );
          final addedIn = _appendEntry(
            entries,
            rawDate: raw['transfer_date'],
            rawProduct: item['product'],
            warehouse: to,
            type: 'Transfer In',
            reference: reference,
            rawQuantity: item['qty'],
            isIncoming: true,
          );
          return addedOut && addedIn;
        });
      }

      entries.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );
      if (!mounted) return;
      setState(() => _entries = entries);
      if (invalidCount > 0) {
        ToastWidget.show(
          message:
              '$invalidCount invalid stock movement record(s) were excluded.',
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

  List<Map<String, dynamic>> get _filteredEntries {
    final start = DateUtils.dateOnly(_startDate);
    final end = DateUtils.dateOnly(_endDate);
    return _entries.where((entry) {
      final date = DateUtils.dateOnly(entry['date'] as DateTime);
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
    final entries = _filteredEntries;
    final totals = <DateTime, List<double>>{};
    for (final entry in entries) {
      final date = DateUtils.dateOnly(entry['date'] as DateTime);
      final values = totals.putIfAbsent(date, () => [0, 0]);
      if ((entry['incoming'] as double) > 0) {
        values[0] += 1;
      } else if ((entry['outgoing'] as double) > 0) {
        values[1] += 1;
      }
    }
    final dates = totals.keys.toList()..sort();
    final incoming = [
      for (var index = 0; index < dates.length; index++)
        FlSpot(index.toDouble(), totals[dates[index]]![0]),
    ];
    final outgoing = [
      for (var index = 0; index < dates.length; index++)
        FlSpot(index.toDouble(), totals[dates[index]]![1]),
    ];
    final theme = Theme.of(context);
    final inColor = theme.colorScheme.primary;
    final outColor = theme.colorScheme.error;

    return AppSectionCard(
      title: 'Stock Movement Chart',
      child: entries.isEmpty
          ? const AppEmptyState(message: 'No stock movements found')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.lg,
                  children: [
                    _legend('Stock In Entries', inColor),
                    _legend('Stock Out Entries', outColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Chart shows movement entries because product units vary.'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
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
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        _line(incoming, inColor),
                        _line(outgoing, outColor),
                      ],
                    ),
                  ),
                ),
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

  String _quantityText(double value, String unit) {
    final formatted = _quantityFormat.format(value);
    return unit.isEmpty ? formatted : '$formatted $unit';
  }

  Widget _buildTable() {
    final entries = _filteredEntries;
    if (entries.isEmpty) {
      return const AppEmptyState(message: 'No stock movements found');
    }
    return AppTable<Map<String, dynamic>>(
      rows: entries,
      columns: [
        AppTableColumn(
          title: 'Date',
          builder: (context, entry) => AppTableColumn.value(
            context,
            _dateFormat.format(entry['date'] as DateTime),
          ),
        ),
        AppTableColumn(
          title: 'Product',
          builder: (context, entry) =>
              AppTableColumn.value(context, entry['product']?.toString()),
        ),
        AppTableColumn(
          title: 'Warehouse',
          builder: (context, entry) =>
              AppTableColumn.value(context, entry['warehouse']?.toString()),
        ),
        AppTableColumn(
          title: 'Type',
          builder: (context, entry) =>
              AppTableColumn.value(context, (entry['type'] as String).tr),
        ),
        AppTableColumn(
          title: 'Reference',
          builder: (context, entry) =>
              AppTableColumn.value(context, entry['reference']?.toString()),
        ),
        AppTableColumn(
          title: 'In',
          builder: (context, entry) => AppTableColumn.value(
            context,
            (entry['incoming'] as double) > 0
                ? _quantityText(
                    entry['incoming'] as double,
                    entry['unit'] as String,
                  )
                : '',
          ),
        ),
        AppTableColumn(
          title: 'Out',
          builder: (context, entry) => AppTableColumn.value(
            context,
            (entry['outgoing'] as double) > 0
                ? _quantityText(
                    entry['outgoing'] as double,
                    entry['unit'] as String,
                  )
                : '',
          ),
        ),
        AppTableColumn(
          title: 'Note',
          builder: (context, entry) =>
              AppTableColumn.value(context, entry['note']?.toString()),
        ),
      ],
    );
  }

  ReportExportData _exportData() => ReportExportData(
    title:
        '${'Stock Ledger Report'.tr} ${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
    headers: [
      'Date',
      'Product',
      'Warehouse',
      'Type',
      'Reference',
      'In',
      'Out',
      'Unit',
      'Note',
    ].map((s) => s.tr).toList(),
    notes: [
      'Sales movement warehouse is unavailable from the API; transfer entries are shown as separate warehouse out/in movements. No running balance is shown.'
          .tr,
    ],
    rows: [
      for (final entry in _filteredEntries)
        [
          _dateFormat.format(entry['date'] as DateTime),
          entry['product'],
          entry['warehouse'],
          (entry['type'] as String).tr,
          entry['reference'],
          entry['incoming'],
          entry['outgoing'],
          entry['unit'],
          entry['note'],
        ],
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Stock Ledger Report',
      showRefresh: true,
      onRefresh: _loadEntries,
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
                    'Sales movement warehouse is unavailable from the API; '
                            'transfer entries are shown as separate warehouse out/in '
                            'movements. No running balance is shown.'
                        .tr,
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
