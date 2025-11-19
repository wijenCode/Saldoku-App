# Saldoku Database Structure

## Overview
Database SQLite untuk aplikasi keuangan pribadi Saldoku dengan 11 tabel utama.

## Tables

### 1. users
Menyimpan data pengguna aplikasi
- id, name, email, password, phone, avatar
- timestamps: created_at, updated_at

### 2. wallets
Manajemen dompet (cash, bank, e-wallet, credit card)
- Mendukung multiple currency
- Balance tracking
- Soft delete (is_active)

### 3. categories
Kategori transaksi (income/expense)
- Default categories otomatis terinsert
- User dapat membuat kategori custom
- Icon dan color customization

### 4. transactions
Transaksi harian (pemasukan & pengeluaran)
- Link ke wallet dan category
- Support attachment/bukti transaksi
- Filter by date range, type, category

### 5. budgets
Anggaran bulanan per kategori
- Track spent vs amount
- Period-based (start/end date)
- Over-budget detection

### 6. bills
Tagihan dan langganan berulang
- Recurrence: once, monthly, yearly
- Status: pending, paid, overdue
- Auto-pay & reminder features

### 7. savings_goals
Target tabungan
- Progress tracking (current vs target)
- Deadline optional
- Status: active, completed, cancelled

### 8. investments
Pencatatan investasi
- Types: stocks, mutual_funds, crypto, gold, etc
- Profit/loss calculation
- Return percentage tracking

### 9. debts
Hutang/Piutang
- Type: debt (hutang), receivable (piutang)
- Payment tracking via debt_payments
- Status: unpaid, partially_paid, paid

### 10. debt_payments
History pembayaran hutang/piutang
- Auto-update debt remaining_amount
- Link to wallet

### 11. wallet_transfers
Transfer antar dompet
- Support transfer fee
- Link from/to wallet

## Usage

### Import
```dart
import 'package:saldoku_app/core/db/app_database.dart';
import 'package:saldoku_app/core/db/dao/dao.dart';
import 'package:saldoku_app/core/models/models.dart';
```

### Example: Create Transaction
```dart
final transactionDao = TransactionDao();
final transaction = Transaction(
  userId: 1,
  walletId: 1,
  categoryId: 1,
  type: 'expense',
  amount: 50000,
  description: 'Makan siang',
  date: DateTime.now(),
);

await transactionDao.insert(transaction);
```

### Example: Get Monthly Summary
```dart
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime(2024, 1, 31);
final summary = await transactionDao.getIncomeExpenseSummary(
  userId, 
  startDate, 
  endDate
);

print('Income: ${summary['income']}');
print('Expense: ${summary['expense']}');
print('Balance: ${summary['balance']}');
```

## Default Categories
### Income (5 categories)
- Gaji, Bonus, Investasi, Bisnis, Lainnya

### Expense (8 categories)
- Makanan, Transportasi, Belanja, Hiburan
- Kesehatan, Pendidikan, Tagihan, Lainnya

## Features
✅ Auto-increment IDs  
✅ Foreign key constraints  
✅ Cascade delete  
✅ Timestamps tracking  
✅ Default data seeding  
✅ Transaction statistics  
✅ Balance calculations  
✅ CRUD operations complete  

## DAO Features
Setiap DAO memiliki:
- CRUD operations (Create, Read, Update, Delete)
- Query methods (getById, getByUserId, dll)
- Filter methods (by type, status, date range)
- Statistics methods (totals, summaries)
- Soft delete support (where applicable)
