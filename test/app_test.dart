import 'package:chia_se_trang_thai/main.dart';
import 'package:chia_se_trang_thai/state/privacy_scope.dart';
import 'package:chia_se_trang_thai/state/wallet_model.dart';
import 'package:chia_se_trang_thai/state/wallet_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ví "hay quên": khi [silent] = true thì sửa dữ liệu nhưng không báo ai.
/// Dùng để mô phỏng lỗi xóa mất dòng notifyListeners() trong WalletModel.
class ForgetfulWallet extends WalletModel {
  bool silent = false;

  @override
  void notifyListeners() {
    if (!silent) super.notifyListeners();
  }
}

Future<WalletModel> _pumpApp(WidgetTester tester, {WalletModel? wallet}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final w = wallet ?? WalletModel();
  await tester.pumpWidget(PrivacyController(
    child: WalletScope(wallet: w, child: const WalletApp()),
  ));
  return w;
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

String _text(WidgetTester tester, String key) => tester
    .widget<Text>(find
        .descendant(of: find.byKey(Key(key)), matching: find.byType(Text), matchRoot: true)
        .first)
    .data!;

Future<void> _fillLunch(WidgetTester tester) async {
  await _tap(tester, 'fab_add');
  await tester.enterText(find.byKey(const Key('field_title')), 'Ăn trưa');
  await tester.enterText(find.byKey(const Key('field_amount')), '45000');
  await tester.pumpAndSettle();
}

/// Các widget của app được theo dõi khi đo phạm vi build lại.
const _tracked = {
  'HomeShell', 'OverviewTab', 'TransactionsTab', 'BalanceCard', 'BudgetCard',
  'RecentList', 'TransactionList', 'TransactionTile', 'MonthSwitcher', 'MoneyText',
};

/// Đếm widget build lại trong lúc [action] chạy, dùng hook có sẵn của Flutter
/// (debugOnRebuildDirtyWidget) nên không phải thêm code đo vào app.
Future<Map<String, int>> _rebuilt(
    WidgetTester tester, String label, Future<void> Function() action) async {
  final counts = <String, int>{};
  // Chỉ đếm widget đã có trên màn hình trước thao tác (widget mới gắn vào
  // cây, như một dòng giao dịch mới, là "build lần đầu" chứ không phải build lại).
  final existing = tester.allElements.toSet();
  debugOnRebuildDirtyWidget = (element, _) {
    if (!existing.contains(element)) return;
    final name = element.widget.runtimeType.toString();
    if (_tracked.contains(name)) counts[name] = (counts[name] ?? 0) + 1;
  };
  try {
    await action();
  } finally {
    debugOnRebuildDirtyWidget = null;
  }
  // ignore: avoid_print
  print('$label → ${counts.entries.map((e) => '${e.key} ×${e.value}').join(', ')}');
  return counts;
}

void main() {
  testWidgets('Mở app: tháng 11, số dư 5.020.000đ, còn 20.000đ ngân sách', (tester) async {
    await _pumpApp(tester);
    expect(_text(tester, 'month_label'), 'Tháng 11/2026');
    expect(_text(tester, 'balance_amount'), '5.020.000đ');
    expect(find.text('Còn lại '), findsOneWidget);
  });

  testWidgets('Thêm khoản chi: 2 tab cùng cập nhật, màn chính và tab không build lại',
      (tester) async {
    await _pumpApp(tester);
    await _fillLunch(tester);
    final r = await _rebuilt(tester, 'Lưu "Ăn trưa 45.000đ"', () => _tap(tester, 'btn_save'));

    expect(r.keys, containsAll(['BalanceCard', 'BudgetCard', 'RecentList', 'TransactionList']));
    expect(r.keys, isNot(contains('HomeShell')));
    expect(r.keys, isNot(contains('OverviewTab')));
    expect(r.keys, isNot(contains('TransactionsTab')));
    expect(_text(tester, 'balance_amount'), '4.975.000đ');
    expect(find.text('Đã vượt '), findsOneWidget);

    await _tab(tester, 'Giao dịch');
    expect(find.text('Thứ Bảy, 14/11'), findsOneWidget);
  });

  testWidgets('Trang Thêm: nút Lưu mờ khi chưa nhập đủ; gợi ý ngân sách đọc từ ví',
      (tester) async {
    await _pumpApp(tester);
    await _tap(tester, 'fab_add');
    final save = find.byKey(const Key('btn_save'));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    expect(find.byKey(const Key('save_hint')), findsOneWidget);
    expect(find.text('Ngân sách tháng này còn '), findsOneWidget);
    expect(find.text('20.000đ'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('field_title')), 'Ăn trưa');
    await tester.enterText(find.byKey(const Key('field_amount')), '45000');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    expect(find.byKey(const Key('save_hint')), findsNothing);
    expect(find.text('Khoản này sẽ vượt ngân sách. Chỉ còn '), findsOneWidget);

    // Rời trang giữa chừng: form mất, ví không đổi.
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(_text(tester, 'balance_amount'), '5.020.000đ');
    await _tap(tester, 'fab_add');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
  });

  testWidgets('Ẩn số tiền: chỉ MoneyText build lại, ở mọi tab và cả trang Thêm', (tester) async {
    await _pumpApp(tester);
    final r = await _rebuilt(tester, 'Bấm ẩn số tiền', () => _tap(tester, 'btn_privacy'));

    expect(r.keys, {'MoneyText'});
    expect(_text(tester, 'balance_amount'), '••••••');
    await _tab(tester, 'Giao dịch');
    expect(find.text('••••••'), findsWidgets);
    await _tap(tester, 'fab_add');
    expect(
        find.descendant(of: find.byKey(const Key('budget_hint')), matching: find.text('••••••')),
        findsOneWidget);
  });

  testWidgets('Đổi tháng: chỉ phần trong ValueListenableBuilder build lại', (tester) async {
    await _pumpApp(tester);
    final r = await _rebuilt(tester, 'Đổi sang tháng 10', () => _tap(tester, 'month_prev'));

    expect(r.keys, containsAll(['BalanceCard', 'BudgetCard', 'RecentList', 'TransactionList']));
    expect(r.keys, isNot(contains('OverviewTab')));
    expect(r.keys, isNot(contains('TransactionsTab')));
    expect(r.keys, isNot(contains('HomeShell')));
    expect(_text(tester, 'month_label'), 'Tháng 10/2026');
    expect(_text(tester, 'balance_amount'), '6.350.000đ');

    await _tap(tester, 'month_next');
    expect(tester.widget<IconButton>(find.byKey(const Key('month_next'))).onPressed, isNull);
  });

  testWidgets('Lọc danh mục (trạng thái cục bộ): chỉ tab Giao dịch build lại', (tester) async {
    await _pumpApp(tester);
    await _tab(tester, 'Giao dịch');
    final r = await _rebuilt(tester, 'Lọc "Đi lại"', () => _tap(tester, 'filter_transport'));

    expect(r.keys, containsAll(['TransactionsTab', 'TransactionList']));
    expect(r.keys, isNot(contains('BalanceCard')));
    expect(r.keys, isNot(contains('HomeShell')));
    expect(find.text('Đổ xăng'), findsNWidgets(2));
    expect(find.text('Đi chợ'), findsNothing);
  });

  testWidgets('"Xem tất cả" báo lên màn chính để chuyển tab', (tester) async {
    await _pumpApp(tester);
    await _tap(tester, 'see_all');
    expect(find.byKey(const Key('filter_all')).hitTestable(), findsOneWidget);
  });

  testWidgets('Vuốt xóa → callback lên tab → ví xóa; Hoàn tác khôi phục', (tester) async {
    await _pumpApp(tester);
    await _tab(tester, 'Giao dịch');
    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Đã xóa "Bún bò"'), findsOneWidget);
    await _tab(tester, 'Tổng quan');
    expect(_text(tester, 'balance_amount'), '5.060.000đ');

    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    expect(_text(tester, 'balance_amount'), '5.020.000đ');
  });

  testWidgets('Thí nghiệm quên notifyListeners(): dữ liệu đổi, màn hình đứng yên',
      (tester) async {
    final wallet = ForgetfulWallet();
    await _pumpApp(tester, wallet: wallet);
    wallet.silent = true;
    await _fillLunch(tester);
    await _tap(tester, 'btn_save');

    expect(wallet.balanceOf(DateTime(2026, 11)), 4975000); // dữ liệu đã đổi
    expect(_text(tester, 'balance_amount'), '5.020.000đ'); // màn hình vẫn số cũ
    expect(find.text('Còn lại '), findsOneWidget);

    // Lần build sau (ví dụ đổi tháng qua lại) làm lộ thay đổi bị "giấu".
    wallet.silent = false;
    await _tap(tester, 'month_prev');
    await _tap(tester, 'month_next');
    expect(_text(tester, 'balance_amount'), '4.975.000đ');
    expect(find.text('Đã vượt '), findsOneWidget);
  });
}
