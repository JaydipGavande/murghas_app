enum ExpenseCategory {
  diesel('Diesel', 'डिझेल'),
  labour('Labour Charges', 'मजुरी खर्च'),
  tractor('Tractor Expenses', 'ट्रॅक्टर खर्च'),
  maintenance('Machine Maintenance', 'मशीन दुरुस्ती'),
  transportation('Transportation', 'वाहतूक खर्च'),
  foodAndOther('Food and Other Expenses', 'जेवण आणि इतर खर्च');

  final String labelEn;
  final String labelMr;
  const ExpenseCategory(this.labelEn, this.labelMr);

  String label(String lang) => lang == 'mr' ? labelMr : labelEn;

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value || e.labelEn == value,
      orElse: () => ExpenseCategory.foodAndOther,
    );
  }
}

class Expense {
  final String id;
  final DateTime expenseDate;
  final ExpenseCategory category;
  final double amount;
  final String description;
  final String? receiptPath;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.expenseDate,
    required this.category,
    required this.amount,
    this.description = '',
    this.receiptPath,
    required this.createdAt,
  });

  Expense copyWith({
    String? id,
    DateTime? expenseDate,
    ExpenseCategory? category,
    double? amount,
    String? description,
    String? receiptPath,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      expenseDate: expenseDate ?? this.expenseDate,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_date': expenseDate.toIso8601String(),
      'category': category.name,
      'amount': amount,
      'description': description,
      'receipt_path': receiptPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      category: ExpenseCategory.fromString(map['category'] as String),
      amount: (map['amount'] as num).toDouble(),
      description: (map['description'] as String?) ?? '',
      receiptPath: map['receipt_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
