import 'category.dart';

/// Một khoản thu hoặc chi. Bất biến: muốn đổi thì tạo Transaction mới.
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final String title;

  /// Luôn dương. Thu hay chi do [category] quyết định.
  final int amount;
  final Category category;
  final DateTime date;

  bool get isIncome => category.isIncome;

  /// Số tiền có dấu: thu dương, chi âm.
  int get signedAmount => isIncome ? amount : -amount;
}
