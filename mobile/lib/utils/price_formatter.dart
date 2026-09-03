import 'package:intl/intl.dart';

class PriceFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _numberFormat = NumberFormat.decimalPattern('en_IN');

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatNumber(double amount) {
    return _numberFormat.format(amount);
  }
}
