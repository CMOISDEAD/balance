import 'package:currency_textfield/currency_textfield.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  static const String currencySymbol = "COP";
  static const String decimalSymbol = ".";
  static const String thousandSymbol = ",";
  static const String locale = "es-US";

  /// Crea un controlador para input de moneda
  static CurrencyTextFieldController createController() {
    return CurrencyTextFieldController(
      currencySymbol: currencySymbol,
      decimalSymbol: decimalSymbol,
      thousandSymbol: thousandSymbol,
    );
  }

  /// Formatea un número como moneda
  static String formatCurrency(double? amount) {
    if (amount == null) return formatCurrency(0);

    return NumberFormat.simpleCurrency(
      locale: locale,
      decimalDigits: 2,
    ).format(amount);
  }

  /// Formatea sin símbolo de moneda
  static String formatNumber(double? amount) {
    if (amount == null) return "0,00";

    return NumberFormat.currency(
      locale: locale,
      symbol: "",
      decimalDigits: 2,
    ).format(amount).trim();
  }
}
