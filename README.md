# Chủ đề 11 — Chia sẻ trạng thái giữa các widget

Ứng dụng Flutter demo cho môn Lập trình đa nền tảng: **Ví của tôi** (quản lý chi tiêu, bản gọn).

Hai tab **Tổng quan** (số dư, ngân sách tháng, giao dịch gần đây) và **Giao dịch** (lọc theo danh mục, vuốt để xóa, Hoàn tác). Nút **Thêm khoản chi** mở trang nhập. Nút 👁 ẩn mọi số tiền, ‹ › đổi tháng. Giao diện Material 3, có chế độ tối. App không hiện chữ lý thuyết nào: phần giải thích do nhóm nói khi thuyết trình.

## Thao tác → lý thuyết

| Thao tác | Lý thuyết |
|---|---|
| Thêm / vuốt xóa / Hoàn tác → cả 2 tab đổi theo | `ChangeNotifier` (`WalletModel`) + `InheritedNotifier` (`WalletScope`), đặt trên `MaterialApp` |
| Bấm 👁 | `InheritedWidget` (`PrivacyScope`), giống `Theme.of` |
| Bấm ‹ › đổi tháng | `ValueNotifier` + `ValueListenableBuilder` |
| Form Thêm khoản chi, "Xem tất cả", vuốt xóa | Constructor + callback, nâng trạng thái lên cha gần |
| Lọc danh mục | Trạng thái cục bộ (`TransactionsTab`) |

`test/app_test.dart` đo phạm vi build lại của từng thao tác bằng hook có sẵn của Flutter (`debugOnRebuildDirtyWidget`), không cần thêm code đo vào app.

## Cấu trúc mã nguồn

```
lib/
├── main.dart                   # AppRoot: PrivacyController + WalletScope bọc WalletApp (MaterialApp)
├── theme.dart                  # Material 3 từ một màu gốc, sáng + tối
├── models/                     # Category, Transaction
├── data/sample_data.dart       # 15 giao dịch tháng 10–11/2026, hạn mức 3.000.000đ
├── utils/format.dart
├── state/
│   ├── wallet_model.dart       # ChangeNotifier: dữ liệu + logic của ví
│   ├── wallet_scope.dart       # InheritedNotifier: watch / read
│   └── privacy_scope.dart      # InheritedWidget + StatefulWidget bọc ngoài
├── widgets/
│   ├── money_text.dart         # tự đọc PrivacyScope
│   ├── transaction_tile.dart   # constructor + callback onDelete
│   └── form_fields.dart        # AmountField, CategoryPicker
└── screens/
    ├── home_shell.dart         # màn chính, ValueNotifier tháng, nút con mắt
    ├── overview_tab.dart       # BalanceCard, BudgetCard, RecentList
    ├── transactions_tab.dart
    └── add_transaction_page.dart
```

## Cài đặt và chạy

Yêu cầu: Flutter SDK stable (đã thử với Flutter 3.47.7). Không dùng gói ngoài (`flutter_localizations` có sẵn trong SDK).

```bash
flutter pub get
flutter run -d linux       # cần: sudo apt install clang libgtk-3-dev
```

Kiểm tra và chụp ảnh cho slide:

```bash
flutter analyze
flutter test
flutter test --update-goldens --dart-define=CAPTURE=true test/capture
```
