// Chụp ảnh màn hình app để đưa vào slide (không chạy khi `flutter test` thường).
//
//   flutter test --update-goldens --dart-define=CAPTURE=true test/capture
//
// Ảnh được lưu ở test/capture/screenshots/. Phông chữ lấy từ máy (Inter)
// để chữ tiếng Việt hiển thị thật thay vì ô vuông.
import 'dart:io';

import 'package:chia_se_trang_thai/main.dart';
import 'package:chia_se_trang_thai/state/privacy_scope.dart';
import 'package:chia_se_trang_thai/state/wallet_model.dart';
import 'package:chia_se_trang_thai/state/wallet_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _capture = bool.fromEnvironment('CAPTURE');

/// Mô phỏng lỗi xóa mất notifyListeners() (cho ảnh thí nghiệm).
class _ForgetfulWallet extends WalletModel {
  bool silent = false;

  @override
  void notifyListeners() {
    if (!silent) super.notifyListeners();
  }
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    if (!_capture) return;
    const inter = '/usr/share/fonts/opentype/inter';
    await _loadFont('Roboto', [
      '$inter/Inter-Regular.otf',
      '$inter/Inter-Medium.otf',
      '$inter/Inter-SemiBold.otf',
      '$inter/Inter-Bold.otf',
      '$inter/Inter-ExtraBold.otf',
    ]);
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    await _loadFont('MaterialIcons',
        ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });

  testWidgets('Chụp màn hình cho slide', skip: !_capture, (tester) async {
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(840, 1780);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    var n = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      n++;
      await expectLater(find.byType(PrivacyController),
          matchesGoldenFile('screenshots/${n.toString().padLeft(2, '0')}_$name.png'));
    }

    Future<void> tap(String key) async {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }

    Future<void> tab(String label) async {
      await tester.tap(find.descendant(
          of: find.byType(NavigationBar), matching: find.text(label)));
      await tester.pumpAndSettle();
    }

    Future<void> fillLunch() async {
      await tap('fab_add');
      await tester.enterText(find.byKey(const Key('field_title')), 'Ăn trưa');
      await tester.enterText(find.byKey(const Key('field_amount')), '45000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    final wallet = _ForgetfulWallet();
    await tester.pumpWidget(PrivacyController(
      child: WalletScope(wallet: wallet, child: const WalletApp()),
    ));

    await shot('tong_quan');
    await tab('Giao dịch');
    await shot('giao_dich');
    await tab('Tổng quan');

    // Thêm "Ăn trưa 45.000đ" → vượt ngân sách.
    await fillLunch();
    await shot('them_khoan_chi');
    await tap('btn_save');
    await shot('sau_khi_them');
    await tab('Giao dịch');
    await shot('sau_khi_them_giao_dich');

    // Lọc danh mục (trạng thái cục bộ).
    await tap('filter_food');
    await shot('loc_an_uong');
    await tap('filter_all');

    // Vuốt xóa → SnackBar Hoàn tác.
    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await shot('vuot_xoa');
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    await tab('Tổng quan');

    // Ẩn số tiền: cả màn chính và trang Thêm.
    await tap('btn_privacy');
    await shot('an_so_tien');
    await tap('fab_add');
    await shot('an_so_tien_trang_them');
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    await tap('btn_privacy');

    // Đổi tháng.
    await tap('month_prev');
    await shot('doi_thang');
    await tap('month_next');

    // Thí nghiệm quên notifyListeners(): ví mới, thêm "Ăn trưa" khi "im lặng".
    final forgetful = _ForgetfulWallet();
    await tester.pumpWidget(PrivacyController(
      child: WalletScope(wallet: forgetful, child: const WalletApp()),
    ));
    await tester.pumpAndSettle();
    forgetful.silent = true;
    await fillLunch();
    await tap('btn_save');
    await shot('thi_nghiem_quen_notify');
    forgetful.silent = false;
    await tap('month_prev');
    await tap('month_next');
    await shot('thi_nghiem_lo_ra');

    // Chế độ tối.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await shot('che_do_toi');

    debugDisableShadows = true; // trả lại mặc định của môi trường test
  });
}
