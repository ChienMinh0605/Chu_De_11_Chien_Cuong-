import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../utils/format.dart';
import 'money_text.dart';

/// Một dòng giao dịch.
///
/// DỮ LIỆU ĐI XUỐNG qua constructor ([transaction]); SỰ KIỆN ĐI LÊN qua
/// callback ([onDelete]). Dòng giao dịch không tự xóa dữ liệu: nó chỉ báo
/// "người dùng vừa vuốt xóa", nơi tạo ra nó quyết định làm gì.
/// [onDelete] là null thì không vuốt được (dùng ở mục "Gần đây").
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onDelete});

  final Transaction transaction;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = transaction;
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.category.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(t.category.icon, color: t.category.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${t.category.label} · ${formatShortDate(t.date)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          MoneyText(
            t.signedAmount,
            signed: true,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: ValueKey('txn_${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete!(),
      child: tile,
    );
  }
}
