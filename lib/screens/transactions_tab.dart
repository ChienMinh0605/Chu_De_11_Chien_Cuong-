import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../state/wallet_scope.dart';
import '../utils/format.dart';
import '../widgets/transaction_tile.dart';

/// Tab "Giao dịch": lọc theo danh mục, vuốt để xóa, có Hoàn tác.
class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key, required this.month});

  /// Tháng đang xem, do màn chính sở hữu.
  final ValueNotifier<DateTime> month;

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  // TRẠNG THÁI CỤC BỘ: chỉ danh sách của tab này cần biết đang lọc gì,
  // nên để ngay ở đây, không đưa lên màn chính, không chia sẻ.
  Category? _filter; // null = Tất cả

  /// Nhận sự kiện "vuốt xóa" từ TransactionTile và nhờ chủ sở hữu (ví) xóa.
  void _delete(Transaction t) {
    final wallet = WalletScope.read(context);
    wallet.remove(t);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Đã xóa "${t.title}"'),
        action: SnackBarAction(label: 'Hoàn tác', onPressed: () => wallet.restore(t)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            children: [
              for (final c in <Category?>[null, ...Category.values])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: Key('filter_${c?.name ?? 'all'}'),
                    label: Text(c?.label ?? 'Tất cả'),
                    selected: _filter == c,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _filter = c),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<DateTime>(
            valueListenable: widget.month,
            builder: (context, month, _) =>
                TransactionList(month: month, filter: _filter, onDelete: _delete),
          ),
        ),
      ],
    );
  }
}

/// Danh sách giao dịch nhóm theo ngày.
class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.month,
    required this.filter,
    required this.onDelete,
  });

  final DateTime month;
  final Category? filter;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = WalletScope.watch(context)
        .inMonth(month)
        .where((t) => filter == null || t.category == filter)
        .toList();

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text('Không có giao dịch nào',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final children = <Widget>[];
    DateTime? day;
    for (final t in items) {
      if (day == null || !isSameDay(day, t.date)) {
        day = t.date;
        children.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 2),
          child: Text(formatDay(t.date),
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ));
      }
      children.add(TransactionTile(transaction: t, onDelete: () => onDelete(t)));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: children,
    );
  }
}
