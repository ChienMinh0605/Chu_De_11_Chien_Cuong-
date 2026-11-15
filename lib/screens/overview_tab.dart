import 'dart:math';

import 'package:flutter/material.dart';

import '../state/wallet_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/money_text.dart';
import '../widgets/transaction_tile.dart';

/// Tab "Tổng quan".
///
/// Bản thân tab không đọc ví, nên không build lại khi ví đổi. Mỗi thẻ bên
/// trong (BalanceCard, BudgetCard, RecentList) tự đọc ví bằng
/// WalletScope.watch, nên chỉ các thẻ đó build lại.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.month, required this.onSeeAll});

  /// Tháng đang xem, do màn chính sở hữu.
  final ValueNotifier<DateTime> month;

  /// Bấm "Xem tất cả": báo lên màn chính để chuyển tab.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    // Đổi tháng: chỉ phần builder chạy lại, OverviewTab không build lại.
    return ValueListenableBuilder<DateTime>(
      valueListenable: month,
      builder: (context, m, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          BalanceCard(month: m),
          const SizedBox(height: 16),
          BudgetCard(month: m),
          const SizedBox(height: 16),
          RecentList(month: m, onSeeAll: onSeeAll),
        ],
      ),
    );
  }
}

/// Thẻ số dư nổi bật ở đầu trang.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = WalletScope.watch(context);
    const onCard = Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Màu cố định (không lấy từ scheme) để chữ trắng luôn đủ tương phản,
          // cả ở chế độ sáng lẫn tối.
          colors: [brandSeed, Color.lerp(brandSeed, Colors.black, 0.45)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số dư ${formatMonth(month).toLowerCase()}',
              style: theme.textTheme.bodyMedium?.copyWith(color: onCard.withValues(alpha: 0.85))),
          const SizedBox(height: 6),
          MoneyText(
            wallet.balanceOf(month),
            key: const Key('balance_amount'),
            style: theme.textTheme.headlineLarge
                ?.copyWith(color: onCard, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Flow(
                  icon: Icons.south_west,
                  label: 'Thu vào',
                  amount: MoneyText(wallet.incomeOf(month),
                      key: const Key('income_amount'),
                      style: const TextStyle(color: onCard, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Flow(
                  icon: Icons.north_east,
                  label: 'Chi ra',
                  amount: MoneyText(wallet.expenseOf(month),
                      key: const Key('expense_amount'),
                      style: const TextStyle(color: onCard, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Flow extends StatelessWidget {
  const _Flow({required this.icon, required this.label, required this.amount});

  final IconData icon;
  final String label;
  final Widget amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                FittedBox(fit: BoxFit.scaleDown, child: amount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ ngân sách tháng: đã chi / hạn mức, thanh tiến độ đổi màu khi vượt.
class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key, required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wallet = WalletScope.watch(context);
    final spent = wallet.expenseOf(month);
    final left = wallet.budgetLeftOf(month);
    final over = left < 0;
    final barColor = over ? scheme.error : scheme.primary;

    return Card(
      key: const Key('budget_card'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Ngân sách tháng', style: theme.textTheme.titleMedium)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${(spent * 100 / wallet.monthlyBudget).round()}%',
                      style: TextStyle(color: barColor, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                MoneyText(spent,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                Text('  /  ', style: TextStyle(color: scheme.onSurfaceVariant)),
                MoneyText(wallet.monthlyBudget,
                    style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: min(1, spent / wallet.monthlyBudget),
              minHeight: 12,
              color: barColor,
              backgroundColor: barColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 10),
            Row(
              key: const Key('budget_status'),
              children: [
                Icon(over ? Icons.error_outline : Icons.check_circle_outline,
                    size: 18, color: over ? scheme.error : scheme.primary),
                const SizedBox(width: 6),
                Text(over ? 'Đã vượt ' : 'Còn lại ',
                    style: TextStyle(color: over ? scheme.error : scheme.onSurfaceVariant)),
                MoneyText(left.abs(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: over ? scheme.error : null)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 3 giao dịch gần nhất của tháng.
class RecentList extends StatelessWidget {
  const RecentList({super.key, required this.month, required this.onSeeAll});

  final DateTime month;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = WalletScope.watch(context).inMonth(month).take(3).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Gần đây', style: theme.textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  key: const Key('see_all'),
                  onPressed: onSeeAll,
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Chưa có giao dịch trong tháng này',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ),
            for (final t in recent)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TransactionTile(transaction: t),
              ),
          ],
        ),
      ),
    );
  }
}
