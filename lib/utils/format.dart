/// 35000 → "35.000đ"
String formatVnd(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '$bufferđ';
}

/// 45000 → "+45.000đ", -45000 → "−45.000đ"
String formatSigned(int value) =>
    value >= 0 ? '+${formatVnd(value)}' : '−${formatVnd(-value)}';

String _two(int n) => n.toString().padLeft(2, '0');

const _weekdays = [
  'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ nhật',
];

/// "Thứ Sáu, 13/11"
String formatDay(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${_two(d.day)}/${_two(d.month)}';

/// "13/11"
String formatShortDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

/// "Tháng 11/2026"
String formatMonth(DateTime m) => 'Tháng ${m.month}/${m.year}';

DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

bool isSameDay(DateTime a, DateTime b) =>
    isSameMonth(a, b) && a.day == b.day;
