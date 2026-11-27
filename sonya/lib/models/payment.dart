enum PaymentMethod {
  cash('Cash', 'रोख'),
  upi('UPI', 'यूपीआय'),
  bankTransfer('Bank Transfer', 'बँक ट्रान्सफर');

  final String labelEn;
  final String labelMr;
  const PaymentMethod(this.labelEn, this.labelMr);

  String label(String lang) => lang == 'mr' ? labelMr : labelEn;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value || e.labelEn == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

class Payment {
  final String id;
  final String customerId;
  final String customerName;
  final String? workEntryId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod method;
  final String notes;
  final bool isAdvance;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.workEntryId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.notes = '',
    this.isAdvance = false,
    required this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? workEntryId,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? method,
    String? notes,
    bool? isAdvance,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      workEntryId: workEntryId ?? this.workEntryId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      isAdvance: isAdvance ?? this.isAdvance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'work_entry_id': workEntryId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'method': method.name,
      'notes': notes,
      'is_advance': isAdvance ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      customerName: map['customer_name'] as String,
      workEntryId: map['work_entry_id'] as String?,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['payment_date'] as String),
      method: PaymentMethod.fromString(map['method'] as String),
      notes: (map['notes'] as String?) ?? '',
      isAdvance: (map['is_advance'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
