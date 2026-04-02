import 'package:intl/intl.dart';

String formatCurrency(double amount, [String currencyCode = 'USD']) {
  final format = NumberFormat.simpleCurrency(name: currencyCode);
  return format.format(amount);
}
