class Customer {
  final String id;
  final String name;
  final String mobile;
  final String village;
  final String address;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.village,
    this.address = '',
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? mobile,
    String? village,
    String? address,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      village: village ?? this.village,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'village': village,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String,
      village: map['village'] as String,
      address: (map['address'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
