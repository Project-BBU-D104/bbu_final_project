class SaleModel {
  final int? id;
  final int? customerId;
  final int userId;

  final String invoiceNo;
  final DateTime saleDate;

  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;

  final double paidAmount;
  final double dueAmount;

  final String paymentStatus; // unpaid, partial, paid
  final String status; // pending, completed, cancelled

  final String? paymentMethod;

  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SaleModel({
    this.id,
    this.customerId,
    required this.userId,
    required this.invoiceNo,
    required this.saleDate,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    this.dueAmount = 0,
    this.paymentStatus = 'unpaid',
    this.status = 'pending',
    this.paymentMethod,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      userId: json['user_id'] as int,
      invoiceNo: json['invoice_no'] as String,
      saleDate: DateTime.parse(json['sale_date'] as String),

      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num).toDouble(),

      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0,

      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,

      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'user_id': userId,
      'invoice_no': invoiceNo,
      'sale_date': saleDate.toIso8601String(),

      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,

      'paid_amount': paidAmount,
      'due_amount': dueAmount,

      'payment_status': paymentStatus,
      'status': status,

      'payment_method': paymentMethod,

      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SaleModel copyWith({
    int? id,
    int? customerId,
    int? userId,
    String? invoiceNo,
    DateTime? saleDate,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    double? dueAmount,
    String? paymentStatus,
    String? status,
    String? paymentMethod,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      userId: userId ?? this.userId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      saleDate: saleDate ?? this.saleDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SaleModel(id: $id, invoiceNo: $invoiceNo, totalAmount: $totalAmount, status: $status)';
  }
}