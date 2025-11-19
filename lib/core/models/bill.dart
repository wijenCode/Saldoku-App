class Bill {
  final int? id;
  final int userId;
  final int walletId;
  final int categoryId;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String recurrence; // once, monthly, yearly
  final String status; // pending, paid, overdue
  final bool reminderEnabled;
  final int? reminderDays;
  final bool autoPay;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    this.id,
    required this.userId,
    required this.walletId,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.recurrence,
    this.status = 'pending',
    this.reminderEnabled = true,
    this.reminderDays,
    this.autoPay = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'wallet_id': walletId,
      'category_id': categoryId,
      'name': name,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'recurrence': recurrence,
      'status': status,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_days': reminderDays,
      'auto_pay': autoPay ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      walletId: map['wallet_id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      recurrence: map['recurrence'] as String,
      status: map['status'] as String,
      reminderEnabled: (map['reminder_enabled'] as int) == 1,
      reminderDays: map['reminder_days'] as int?,
      autoPay: (map['auto_pay'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Bill copyWith({
    int? id,
    int? userId,
    int? walletId,
    int? categoryId,
    String? name,
    double? amount,
    DateTime? dueDate,
    String? recurrence,
    String? status,
    bool? reminderEnabled,
    int? reminderDays,
    bool? autoPay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      status: status ?? this.status,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
      autoPay: autoPay ?? this.autoPay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
