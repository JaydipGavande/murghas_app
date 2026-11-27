class WorkEntry {
  final String id;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String village;
  final DateTime workDate;
  final String machineName;
  final double quantityTons;
  final double ratePerTon;
  final double additionalCharges;
  final double discount;
  final double totalAmount;
  final double receivedAmount;
  final double remainingBalance;
  final String notes;
  final DateTime createdAt;

  const WorkEntry({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.village,
    required this.workDate,
    required this.machineName,
    required this.quantityTons,
    required this.ratePerTon,
    this.additionalCharges = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    this.receivedAmount = 0.0,
    required this.remainingBalance,
    this.notes = '',
    required this.createdAt,
  });

  static double calculateTotal({
    required double quantityTons,
    required double ratePerTon,
    double additionalCharges = 0.0,
    double discount = 0.0,
  }) {
    final total = (quantityTons * ratePerTon) + additionalCharges - discount;
    return total < 0 ? 0 : total;
  }

  static double calculateRemaining({
    required double totalAmount,
    required double receivedAmount,
  }) {
    final remaining = totalAmount - receivedAmount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isPaid => remainingBalance <= 0.01;

  WorkEntry copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerMobile,
    String? village,
    DateTime? workDate,
    String? machineName,
    double? quantityTons,
    double? ratePerTon,
    double? additionalCharges,
    double? discount,
    double? totalAmount,
    double? receivedAmount,
    double? remainingBalance,
    String? notes,
    DateTime? createdAt,
  }) {
    return WorkEntry(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      village: village ?? this.village,
      workDate: workDate ?? this.workDate,
      machineName: machineName ?? this.machineName,
      quantityTons: quantityTons ?? this.quantityTons,
      ratePerTon: ratePerTon ?? this.ratePerTon,
      additionalCharges: additionalCharges ?? this.additionalCharges,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'village': village,
      'work_date': workDate.toIso8601String(),
      'machine_name': machineName,
      'quantity_tons': quantityTons,
      'rate_per_ton': ratePerTon,
      'additional_charges': additionalCharges,
      'discount': discount,
      'total_amount': totalAmount,
      'received_amount': receivedAmount,
      'remaining_balance': remainingBalance,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkEntry.fromMap(Map<String, dynamic> map) {
    return WorkEntry(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      customerName: map['customer_name'] as String,
      customerMobile: map['customer_mobile'] as String,
      village: map['village'] as String,
      workDate: DateTime.parse(map['work_date'] as String),
      machineName: map['machine_name'] as String,
      quantityTons: (map['quantity_tons'] as num).toDouble(),
      ratePerTon: (map['rate_per_ton'] as num).toDouble(),
      additionalCharges: (map['additional_charges'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num).toDouble(),
      receivedAmount: (map['received_amount'] as num?)?.toDouble() ?? 0.0,
      remainingBalance: (map['remaining_balance'] as num).toDouble(),
      notes: (map['notes'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
