import 'package:equatable/equatable.dart';

class ExpenseCategory {
  static const rent = 'Sewa';
  static const utilities = 'Utilitas';
  static const supplies = 'Perlengkapan';
  static const salaries = 'Gaji';
  static const marketing = 'Pemasaran';
  static const maintenance = 'Perawatan';
  static const other = 'Lainnya';

  static const predefined = [
    rent,
    utilities,
    supplies,
    salaries,
    marketing,
    maintenance,
    other,
  ];
}

class Expense extends Equatable {
  const Expense({
    this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.paymentMethod = 'cash',
    this.receiptImagePath,
    this.userId,
    this.createdAt,
  });

  final int? id;
  final String category;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String paymentMethod;
  final String? receiptImagePath;
  final int? userId;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, category, amount, expenseDate];
}
