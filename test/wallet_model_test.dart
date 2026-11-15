import 'package:chia_se_trang_thai/models/category.dart';
import 'package:chia_se_trang_thai/state/wallet_model.dart';
import 'package:chia_se_trang_thai/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final nov = DateTime(2026, 11);
  final oct = DateTime(2026, 10);

  test('Số liệu mẫu tháng 11 và tháng 10', () {
    final w = WalletModel();
    expect(w.incomeOf(nov), 8000000);
    expect(w.expenseOf(nov), 2980000);
    expect(w.balanceOf(nov), 5020000);
    expect(w.budgetLeftOf(nov), 20000);
    expect(w.balanceOf(oct), 6350000);
    expect(w.inMonth(oct), hasLength(3));
  });

  test('Thêm bữa trưa 45.000đ → vượt ngân sách 25.000đ; mới nhất đứng đầu', () {
    final w = WalletModel();
    var notified = 0;
    w.addListener(() => notified++);

    final t = w.add(
        title: 'Ăn trưa', amount: 45000, category: Category.food, date: DateTime(2026, 11, 14));

    expect(notified, 1);
    expect(w.budgetLeftOf(nov), -25000);
    expect(w.inMonth(nov).first, t);
    expect(w.balanceOf(nov), 4975000);
  });

  test('Xóa rồi hoàn tác: mỗi thay đổi notifyListeners một lần', () {
    final w = WalletModel();
    var notified = 0;
    w.addListener(() => notified++);
    final first = w.inMonth(nov).first;

    w.remove(first);
    expect(w.inMonth(nov), isNot(contains(first)));
    w.restore(first);
    expect(w.inMonth(nov), contains(first));
    expect(notified, 2);
  });

  test('Định dạng', () {
    expect(formatVnd(5020000), '5.020.000đ');
    expect(formatSigned(-45000), '−45.000đ');
    expect(formatSigned(8000000), '+8.000.000đ');
    expect(formatDay(DateTime(2026, 11, 13)), 'Thứ Sáu, 13/11');
    expect(formatMonth(nov), 'Tháng 11/2026');
  });
}
