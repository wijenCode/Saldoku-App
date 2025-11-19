class DebtPayment {
  final int? id;
  final int debtId;
  final int walletId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;

  DebtPayment({
    this.id,
    required this.debtId,
    required this.walletId,
    required this.amount,
    DateTime? paymentDate,
    this.notes,
    DateTime? createdAt,
  })  : paymentDate = paymentDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debt_id': debtId,
      'wallet_id': walletId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id'] as int?,
      debtId: map['debt_id'] as int,
      walletId: map['wallet_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['payment_date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  DebtPayment copyWith({
    int? id,
    int? debtId,
    int? walletId,
    double? amount,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return DebtPayment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      walletId: walletId ?? this.walletId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
