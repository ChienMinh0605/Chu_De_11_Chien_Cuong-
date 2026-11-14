import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/category.dart';
import '../state/wallet_scope.dart';
import '../utils/format.dart';
import '../widgets/form_fields.dart';
import '../widgets/money_text.dart';

/// Trang "Thêm khoản chi" (một route riêng, mở bằng nút +).
///
/// Dữ liệu của form (nội dung, số tiền, danh mục) là TRẠNG THÁI CỤC BỘ của
/// trang này: chỉ form cần, chỉ đi xuống 1 lớp (AmountField, CategoryPicker,
/// BudgetHint), nên constructor + callback là đủ. Rời trang là form mất.
/// Chỉ khi bấm Lưu, dữ liệu mới được ghi vào ví dùng chung.
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int _amount = 0;
  Category _category = Category.food;
  final TextEditingController _title = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {})); // để nút Lưu sáng/mờ theo nội dung
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _canSave => _amount > 0 && _title.text.trim().isNotEmpty;

  void _save() {
    // Chỉ GHI vào ví (read), không cần theo dõi.
    WalletScope.read(context).add(
      title: _title.text.trim(),
      amount: _amount,
      category: _category,
      date: today,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm khoản chi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          TextField(
            key: const Key('field_title'),
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nội dung',
              hintText: 'Ví dụ: Ăn trưa',
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),
          const SizedBox(height: 16),
          AmountField(onChanged: (v) => setState(() => _amount = v)),
          const SizedBox(height: 12),
          BudgetHint(adding: _amount),
          const SizedBox(height: 24),
          Text('Danh mục', style: theme.textTheme.titleSmall),
          const SizedBox(height: 10),
          CategoryPicker(
            options: Category.expenses,
            selected: _category,
            onChanged: (c) => setState(() => _category = c),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nói rõ vì sao nút Lưu đang mờ.
              if (!_canSave)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Nhập nội dung và số tiền để lưu',
                    key: const Key('save_hint'),
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              FilledButton(
                key: const Key('btn_save'),
                // Chưa nhập đủ thì nút bị vô hiệu hóa.
                onPressed: _canSave ? _save : null,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gợi ý ngay trong form: "Ngân sách tháng này còn 20.000đ".
///
/// Trang này là một ROUTE KHÁC với màn chính, nhưng vẫn đọc được ví bằng
/// WalletScope.watch(context), vì WalletScope được đặt trên MaterialApp.
class BudgetHint extends StatelessWidget {
  const BudgetHint({super.key, required this.adding});

  /// Số tiền đang nhập.
  final int adding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final left = WalletScope.watch(context).budgetLeftOf(monthOf(today));
    final warn = adding > left;
    final fg = warn ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSecondaryContainer;
    final bg = warn ? theme.colorScheme.errorContainer : theme.colorScheme.secondaryContainer;

    final String label;
    if (left < 0) {
      label = 'Tháng này đã vượt ngân sách ';
    } else if (warn) {
      label = 'Khoản này sẽ vượt ngân sách. Chỉ còn ';
    } else {
      label = 'Ngân sách tháng này còn ';
    }

    return Container(
      key: const Key('budget_hint'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(warn ? Icons.warning_amber_rounded : Icons.savings_outlined, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(label, style: TextStyle(color: fg)),
                MoneyText(left.abs(), style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
