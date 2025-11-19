class Investment {
  final int? id;
  final int userId;
  final String name;
  final String type; // stocks, mutual_funds, crypto, gold, etc
  final double initialAmount;
  final double currentAmount;
  final double? returnPercentage;
  final DateTime purchaseDate;
  final DateTime? maturityDate;
  final String status; // active, sold, matured
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Investment({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.initialAmount,
    required this.currentAmount,
    this.returnPercentage,
    required this.purchaseDate,
    this.maturityDate,
    this.status = 'active',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'initial_amount': initialAmount,
      'current_amount': currentAmount,
      'return_percentage': returnPercentage,
      'purchase_date': purchaseDate.toIso8601String(),
      'maturity_date': maturityDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      initialAmount: (map['initial_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      returnPercentage: (map['return_percentage'] as num?)?.toDouble(),
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      maturityDate: map['maturity_date'] != null ? DateTime.parse(map['maturity_date'] as String) : null,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  double get profit => currentAmount - initialAmount;
  double get profitPercentage => ((currentAmount - initialAmount) / initialAmount * 100);
  bool get isProfit => currentAmount > initialAmount;

  Investment copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    double? initialAmount,
    double? currentAmount,
    double? returnPercentage,
    DateTime? purchaseDate,
    DateTime? maturityDate,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      initialAmount: initialAmount ?? this.initialAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      returnPercentage: returnPercentage ?? this.returnPercentage,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      maturityDate: maturityDate ?? this.maturityDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
