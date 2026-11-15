import 'package:flutter/widgets.dart';

/// Giữ trạng thái "ẩn số tiền" (nút con mắt).
///
/// InheritedWidget không tự đổi được, nên cần một StatefulWidget bọc ngoài:
/// toggle() gọi setState → tạo PrivacyScope mới → Flutter báo cho các widget
/// đã đăng ký phụ thuộc (mọi MoneyText).
class PrivacyController extends StatefulWidget {
  const PrivacyController({super.key, required this.child});

  final Widget child;

  @override
  State<PrivacyController> createState() => PrivacyControllerState();
}

class PrivacyControllerState extends State<PrivacyController> {
  bool _hidden = false;

  bool get hidden => _hidden;

  void toggle() => setState(() => _hidden = !_hidden);

  @override
  Widget build(BuildContext context) {
    // widget.child là cùng một object qua mỗi lần build → Flutter không build
    // lại cả app, chỉ báo cho widget nào gọi PrivacyScope.hiddenOf(context).
    return PrivacyScope(hidden: _hidden, controller: this, child: widget.child);
  }
}

/// Cách hoạt động giống Theme.of(context): widget nào cần thì tự lấy,
/// không ai phải truyền tham số "hidden" qua từng lớp.
class PrivacyScope extends InheritedWidget {
  const PrivacyScope({
    super.key,
    required this.hidden,
    required this.controller,
    required super.child,
  });

  final bool hidden;
  final PrivacyControllerState controller;

  /// ĐỌC + đăng ký theo dõi.
  static bool hiddenOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PrivacyScope>()!.hidden;

  /// Lấy controller để bật/tắt, không đăng ký theo dõi.
  static PrivacyControllerState controllerOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PrivacyScope>()!.controller;

  /// Chỉ báo khi giá trị thật sự đổi.
  @override
  bool updateShouldNotify(PrivacyScope oldWidget) => hidden != oldWidget.hidden;
}
