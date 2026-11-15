import 'package:flutter/widgets.dart';

import 'wallet_model.dart';

/// Đưa WalletModel xuống toàn bộ cây widget bên dưới.
///
/// InheritedNotifier là một InheritedWidget tự báo cho các widget phụ thuộc
/// mỗi khi model gọi notifyListeners(). Đây chính là cách gói `provider`
/// hoạt động (ChangeNotifierProvider, context.watch, context.read).
class WalletScope extends InheritedNotifier<WalletModel> {
  const WalletScope({super.key, required WalletModel wallet, required super.child})
      : super(notifier: wallet);

  /// ĐỌC: lấy dữ liệu VÀ đăng ký theo dõi → widget gọi hàm này build lại
  /// mỗi khi ví thay đổi.
  static WalletModel watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WalletScope>()!.notifier!;

  /// GHI: chỉ lấy model để gọi hàm (add, remove…), KHÔNG đăng ký theo dõi.
  static WalletModel read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<WalletScope>()!.notifier!;
}
