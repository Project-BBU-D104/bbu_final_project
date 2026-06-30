class PaymentModel {
  final int? id;
  final String saleId;
  final String userId;
  final String? amount;
  final String? paymentMethod;
  final String? referenceNo;
  final String? note;
  final DateTime? paymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentModel({
    this.id,
    required this.saleId,
    required this.userId,
    this.amount,
    this.paymentMethod,
    this.referenceNo,
    this.note,
    this.createdAt,
    this.paymentDate,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int?,
      saleId: json['sale_id'] as String,
      userId: json['user_id'] as String,
      amount: json['amount'] as String?,
      paymentMethod: json['payment_method'] as String?,
      referenceNo: json['reference_no'] as String?,
      note: json['note'] as String?,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_id': saleId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'note': note,
      'payment_date': paymentDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    int? id,
    String? saleId,
    String? userId,
    String? amount,
    String? paymentMethod,
    String? note,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, sale_id: $saleId, user_id: $userId, amount: $amount, payment_method: $paymentMethod, note: $note, created_at: $createdAt, updated_at: $updatedAt, payment_date: $paymentDate, reference_no: $referenceNo)';
  }
}