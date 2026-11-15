import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../state/privacy_scope.dart';
import '../utils/format.dart';
import 'add_transaction_page.dart';
import 'overview_tab.dart';
import 'transactions_tab.dart';

/// Màn chính: thanh chọn tháng, 2 tab, nút thêm khoản chi.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Tháng đang xem: cả 2 tab cùng cần → màn chính sở hữu, đặt trong một
  // ValueNotifier. Chỉ các ValueListenableBuilder build lại khi đổi tháng.
  final ValueNotifier<DateTime> _month = ValueNotifier(monthOf(today));

  // Trạng thái cục bộ của màn chính: tab đang chọn.
  int _tab = 0;

  // Tạo một lần: setState của màn chính (đổi tab) không làm các tab
  // build lại, vì Flutter thấy vẫn là cùng một widget.
  late final List<Widget> _tabs = [
    OverviewTab(month: _month, onSeeAll: () => _selectTab(1)),
    TransactionsTab(month: _month),
  ];

  @override
  void dispose() {
    _month.dispose(); // ai tạo thì người đó giải phóng
    super.dispose();
  }

  void _selectTab(int i) => setState(() => _tab = i);

  void _openAdd() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const AddTransactionPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
        actions: const [_PrivacyButton(), SizedBox(width: 8)],
        bottom: MonthSwitcher(month: _month),
      ),
      body: IndexedStack(index: _tab, children: _tabs),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_add'),
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Thêm khoản chi'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
        ],
      ),
    );
  }
}

/// Nút con mắt: ẩn/hiện mọi số tiền trong app.
class _PrivacyButton extends StatelessWidget {
  const _PrivacyButton();

  @override
  Widget build(BuildContext context) {
    final hidden = PrivacyScope.hiddenOf(context);
    return IconButton.filledTonal(
      key: const Key('btn_privacy'),
      tooltip: hidden ? 'Hiện số tiền' : 'Ẩn số tiền',
      icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
      onPressed: () => PrivacyScope.controllerOf(context).toggle(),
    );
  }
}

/// Thanh "‹ Tháng 11/2026 ›" dưới tiêu đề.
class MonthSwitcher extends StatelessWidget implements PreferredSizeWidget {
  const MonthSwitcher({super.key, required this.month});

  final ValueNotifier<DateTime> month;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  void _shift(int delta) {
    final m = month.value;
    month.value = DateTime(m.year, m.month + delta); // gán giá trị mới → báo người nghe
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(22),
        ),
        child: ValueListenableBuilder<DateTime>(
          valueListenable: month,
          builder: (context, m, _) => Row(
            children: [
              IconButton(
                key: const Key('month_prev'),
                tooltip: 'Tháng trước',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shift(-1),
              ),
              Expanded(
                child: Text(
                  formatMonth(m),
                  key: const Key('month_label'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                key: const Key('month_next'),
                tooltip: 'Tháng sau',
                icon: const Icon(Icons.chevron_right),
                // Không xem trước tương lai.
                onPressed: isSameMonth(m, today) ? null : () => _shift(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
