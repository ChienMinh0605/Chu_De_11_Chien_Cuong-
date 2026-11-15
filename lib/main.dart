import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_shell.dart';
import 'state/privacy_scope.dart';
import 'state/wallet_model.dart';
import 'state/wallet_scope.dart';
import 'theme.dart';

void main() => runApp(const AppRoot());

/// Gốc ứng dụng: nơi đặt các trạng thái dùng chung toàn app.
///
/// WalletScope và PrivacyController được đặt TRÊN MaterialApp. Lý do: màn
/// chính và trang "Thêm khoản chi" là hai route anh em dưới Navigator, mà
/// Navigator nằm trong MaterialApp. Tổ tiên chung thấp nhất của chúng vì vậy
/// phải ở trên MaterialApp. Trạng thái sống lâu bằng app.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final WalletModel _wallet = WalletModel();

  @override
  void dispose() {
    _wallet.dispose(); // ai tạo thì người đó giải phóng
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrivacyController(
      child: WalletScope(
        wallet: _wallet,
        child: const WalletApp(),
      ),
    );
  }
}

/// Phần MaterialApp: giao diện, ngôn ngữ, màn hình đầu tiên.
class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ví của tôi',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeShell(),
    );
  }
}
