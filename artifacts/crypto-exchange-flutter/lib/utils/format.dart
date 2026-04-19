import 'package:intl/intl.dart';

class Fmt {
  static String num2(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return NumberFormat('#,##0.00', 'en_US').format(v);
    if (v >= 1) return v.toStringAsFixed(2);
    if (v >= 0.01) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }

  static String price(num v, {String prefix = '\$'}) => '$prefix${num2(v)}';

  static String pct(num v, {int digits = 2}) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(digits)}%';

  static String money(num v, {String currency = '\$'}) {
    final s = NumberFormat.currency(symbol: currency, decimalDigits: 2).format(v);
    return s;
  }

  static String compact(num v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    return v.toStringAsFixed(2);
  }

  static double parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
