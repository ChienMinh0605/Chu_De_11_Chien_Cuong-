import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/category.dart';

/// Ô nhập số tiền.
///
/// Không giữ số tiền: mỗi lần gõ thì báo lên trang cha qua [onChanged].
/// Trang cha giữ giá trị (nâng trạng thái lên cha gần nhất cần nó).
class AmountField extends StatelessWidget {
  const AmountField({super.key, required this.onChanged});

  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('field_amount'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      decoration: const InputDecoration(
        labelText: 'Số tiền',
        prefixIcon: Icon(Icons.payments_outlined),
        suffixText: 'đ',
      ),
      onChanged: (text) => onChanged(int.tryParse(text) ?? 0),
    );
  }
}

/// Chọn danh mục.
///
/// [selected] đi xuống qua constructor, lựa chọn mới đi lên qua [onChanged].
/// Widget này không biết danh mục được chọn sẽ dùng vào việc gì.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<Category> options;
  final Category selected;
  final ValueChanged<Category> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in options)
          ChoiceChip(
            key: Key('cat_${c.name}'),
            avatar: Icon(c.icon, size: 18, color: c.color),
            label: Text(c.label),
            selected: c == selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(c),
          ),
      ],
    );
  }
}
