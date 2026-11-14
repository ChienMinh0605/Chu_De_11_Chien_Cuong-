import '../models/category.dart';
import '../models/transaction.dart';

/// "Hôm nay" của app. Cố định để ảnh chụp và test luôn ra cùng kết quả.
final DateTime today = DateTime(2026, 11, 14);

/// Hạn mức chi tiêu chung cho mỗi tháng.
const int sampleMonthlyBudget = 3000000;

Transaction _t(String id, int month, int day, String title, int amount,
        Category category) =>
    Transaction(
      id: id,
      title: title,
      amount: amount,
      category: category,
      date: DateTime(2026, month, day),
    );

/// Dữ liệu mẫu tháng 10 và 11/2026.
///
/// Tháng 11: thu 8.000.000đ, chi 2.980.000đ, chỉ còn 20.000đ là chạm hạn mức
/// 3.000.000đ (thêm một bữa trưa là vượt).
List<Transaction> sampleTransactions() => [
      _t('t01', 11, 1, 'Lương tháng 11', 8000000, Category.income),
      _t('t02', 11, 2, 'Đi chợ', 700000, Category.food),
      _t('t03', 11, 3, 'Đổ xăng', 80000, Category.transport),
      _t('t04', 11, 5, 'Sách Flutter', 185000, Category.study),
      _t('t05', 11, 6, 'Áo khoác', 450000, Category.shopping),
      _t('t06', 11, 7, 'Lẩu cùng lớp', 280000, Category.food),
      _t('t07', 11, 8, 'Tai nghe', 390000, Category.shopping),
      _t('t08', 11, 9, 'Đi chợ', 620000, Category.food),
      _t('t09', 11, 10, 'Xem phim', 110000, Category.entertainment),
      _t('t10', 11, 12, 'Cơm tấm', 45000, Category.food),
      _t('t11', 11, 13, 'Đổ xăng', 80000, Category.transport),
      _t('t12', 11, 13, 'Bún bò', 40000, Category.food),
      _t('t13', 10, 1, 'Lương tháng 10', 8000000, Category.income),
      _t('t14', 10, 5, 'Đi chợ', 1200000, Category.food),
      _t('t15', 10, 20, 'Học phí tiếng Anh', 450000, Category.study),
    ];
