import 'package:intl/intl.dart';

class PriceFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }
}
