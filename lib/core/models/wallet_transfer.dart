class WalletTransfer {
  final int? id;
  final int userId;
  final int fromWalletId;
  final int toWalletId;
  final double amount;
  final double fee;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  WalletTransfer({
    this.id,
    required this.userId,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    this.fee = 0,
    this.description,
    DateTime? date,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'from_wallet_id': fromWalletId,
      'to_wallet_id': toWalletId,
      'amount': amount,
      'fee': fee,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WalletTransfer.fromMap(Map<String, dynamic> map) {
    return WalletTransfer(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      fromWalletId: map['from_wallet_id'] as int,
      toWalletId: map['to_wallet_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      fee: (map['fee'] as num).toDouble(),
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  double get totalAmount => amount + fee;

  WalletTransfer copyWith({
    int? id,
    int? userId,
    int? fromWalletId,
    int? toWalletId,
    double? amount,
    double? fee,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return WalletTransfer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
