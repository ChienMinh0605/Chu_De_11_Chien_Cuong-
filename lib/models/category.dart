import 'package:flutter/material.dart';

/// Danh mục giao dịch. Đây là DỮ LIỆU CỐ ĐỊNH, không phải trạng thái.
enum Category {
  food('Ăn uống', Icons.restaurant, Color(0xFFEF6C00)),
  transport('Đi lại', Icons.two_wheeler, Color(0xFF1E88E5)),
  shopping('Mua sắm', Icons.shopping_bag, Color(0xFF8E24AA)),
  entertainment('Giải trí', Icons.movie, Color(0xFFD81B60)),
  study('Học tập', Icons.menu_book, Color(0xFF00897B)),
  income('Thu nhập', Icons.payments, Color(0xFF2E7D32));

  const Category(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  bool get isIncome => this == Category.income;

  /// Các danh mục chi (có hạn mức ngân sách).
  static List<Category> get expenses =>
      values.where((c) => !c.isIncome).toList();
}
