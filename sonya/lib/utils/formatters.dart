import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrDecimalFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  static String currency(double amount, {bool showDecimals = false}) {
    if (showDecimals && amount % 1 != 0) {
      return _inrDecimalFormat.format(amount);
    }
    return _inrFormat.format(amount);
  }

  static String date(DateTime dt) => _dateFormat.format(dt);

  static String monthYear(DateTime dt) => _monthYearFormat.format(dt);

  static String dayMonth(DateTime dt) => _dayMonthFormat.format(dt);

  static String tons(double tons) {
    if (tons % 1 == 0) {
      return '${tons.toInt()} टन';
    }
    return '${tons.toStringAsFixed(2)} टन';
  }

  static String tonsFull(double tons) {
    if (tons % 1 == 0) {
      return '${tons.toInt()} टन';
    }
    return '${tons.toStringAsFixed(2)} टन';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
