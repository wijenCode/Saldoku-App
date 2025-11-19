class Debt {
  final int? id;
  final int userId;
  final String type; // debt (hutang), receivable (piutang)
  final String personName;
  final double amount;
  final double remainingAmount;
  final String? description;
  final DateTime? dueDate;
  final String status; // unpaid, partially_paid, paid
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    this.id,
    required this.userId,
    required this.type,
    required this.personName,
    required this.amount,
    double? remainingAmount,
    this.description,
    this.dueDate,
    this.status = 'unpaid',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : remainingAmount = remainingAmount ?? amount,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'person_name': personName,
      'amount': amount,
      'remaining_amount': remainingAmount,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      type: map['type'] as String,
      personName: map['person_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      remainingAmount: (map['remaining_amount'] as num).toDouble(),
      description: map['description'] as String?,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  double get paidAmount => amount - remainingAmount;
  double get percentage => (paidAmount / amount * 100).clamp(0, 100);
  bool get isPaid => remainingAmount <= 0;

  Debt copyWith({
    int? id,
    int? userId,
    String? type,
    String? personName,
    double? amount,
    double? remainingAmount,
    String? description,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
