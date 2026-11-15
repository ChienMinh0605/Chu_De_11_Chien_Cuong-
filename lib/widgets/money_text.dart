import 'package:flutter/material.dart';

import '../state/privacy_scope.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Hiển thị một số tiền, hoặc "••••••" khi người dùng bấm nút con mắt.
///
/// MoneyText không nhận tham số "hidden": nó tự hỏi PrivacyScope qua context.
/// Vì vậy mọi chỗ hiện tiền trong app (ở bất kỳ tab, bất kỳ trang nào) đều
/// đổi theo, mà các widget cha không phải biết gì về chế độ ẩn.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.signed = false,
    this.style,
    this.textAlign,
  });

  final int amount;

  /// true: hiện dấu "+" (màu xanh) hoặc "−".
  final bool signed;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final hidden = PrivacyScope.hiddenOf(context);
    final text = hidden
        ? '••••••'
        : signed
            ? formatSigned(amount)
            : formatVnd(amount);
    final color = signed && amount > 0 && !hidden ? incomeColor : null;
    return Text(
      text,
      textAlign: textAlign,
      style: (style ?? const TextStyle()).copyWith(color: color),
    );
  }
}
