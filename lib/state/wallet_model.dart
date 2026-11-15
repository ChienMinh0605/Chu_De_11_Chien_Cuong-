import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../data/sample_data.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../utils/format.dart';

/// Dữ liệu ví: TRẠNG THÁI DÙNG CHUNG của cả app.
///
/// Lớp Dart thuần (không phải widget): giữ dữ liệu và logic nghiệp vụ
/// (số dư, đã chi, còn lại so với hạn mức). Sau mỗi thay đổi gọi
/// notifyListeners() để báo cho mọi widget đang theo dõi.
/// Vì không dính tới giao diện nên test được riêng (test/wallet_model_test.dart).
class WalletModel extends ChangeNotifier {
  WalletModel({List<Transaction>? transactions, this.monthlyBudget = sampleMonthlyBudget})
      : _transactions = transactions ?? sampleTransactions();

  final List<Transaction> _transactions;

  /// Hạn mức chi tiêu chung mỗi tháng.
  final int monthlyBudget;
  int _nextId = 1;

  // ---------------------------------------------------------------- ĐỌC
  // Số dư, đã chi, còn lại đều được TÍNH từ danh sách giao dịch, không lưu riêng.

  int get count => _transactions.length;

  /// Giao dịch trong tháng, mới nhất trước (cùng ngày: thêm sau đứng trước).
  List<Transaction> inMonth(DateTime month) {
    final indexed = [
      for (var i = 0; i < _transactions.length; i++)
        if (isSameMonth(_transactions[i].date, month)) (i, _transactions[i]),
    ];
    indexed.sort((a, b) {
      final byDate = b.$2.date.compareTo(a.$2.date);
      return byDate != 0 ? byDate : b.$1.compareTo(a.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  int incomeOf(DateTime month) => inMonth(month)
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int expenseOf(DateTime month) => inMonth(month)
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int balanceOf(DateTime month) => incomeOf(month) - expenseOf(month);

  /// Còn lại so với hạn mức; âm nghĩa là đã vượt.
  int budgetLeftOf(DateTime month) => monthlyBudget - expenseOf(month);

  // ---------------------------------------------------------------- GHI
  // Chỉ chủ sở hữu được sửa dữ liệu: nơi khác gọi các hàm dưới đây.

  Transaction add({
    required String title,
    required int amount,
    required Category category,
    required DateTime date,
  }) {
    final t = Transaction(
      id: 'new${_nextId++}',
      title: title,
      amount: amount,
      category: category,
      date: date,
    );
    _transactions.add(t);
    notifyListeners();
    return t;
  }

  void remove(Transaction transaction) {
    _transactions.removeWhere((t) => t.id == transaction.id);
    notifyListeners();
  }

  /// Hoàn tác xóa.
  void restore(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }
}
