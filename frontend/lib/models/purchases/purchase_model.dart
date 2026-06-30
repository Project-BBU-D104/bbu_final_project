class PurchaseModel {
  final int? id;
  final int supplierId;
  final int userId;
  final String invoiceNo;
  final DateTime purchaseDate;

  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;

  final double paidAmount;
  final double dueAmount;

  final String paymentStatus; // unpaid, partial, paid
  final String status; // pending, completed, cancelled

  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PurchaseModel({
    this.id,
    required this.supplierId,
    required this.userId,
    required this.invoiceNo,
    required this.purchaseDate,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    this.dueAmount = 0,
    this.paymentStatus = 'unpaid',
    this.status = 'pending',
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as int?,
      supplierId: json['supplier_id'] as int,
      userId: json['user_id'] as int,
      invoiceNo: json['invoice_no'] as String,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),

      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num).toDouble(),

      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0,

      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      status: json['status'] as String? ?? 'pending',

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
      'supplier_id': supplierId,
      'user_id': userId,
      'invoice_no': invoiceNo,
      'purchase_date': purchaseDate.toIso8601String(),

      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,

      'paid_amount': paidAmount,
      'due_amount': dueAmount,

      'payment_status': paymentStatus,
      'status': status,

      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PurchaseModel copyWith({
    int? id,
    int? supplierId,
    int? userId,
    String? invoiceNo,
    DateTime? purchaseDate,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    double? dueAmount,
    String? paymentStatus,
    String? status,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      userId: userId ?? this.userId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PurchaseModel(id: $id, invoiceNo: $invoiceNo, totalAmount: $totalAmount, status: $status)';
  }
}