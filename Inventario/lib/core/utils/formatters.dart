class FormatterUtils {
  static String getNumericValue(dynamic value) {
    if (value == null) return "0";
    if (value is List) {
      return value.isNotEmpty ? value[0].toString() : "0";
    }
    if (value is num) {
      return value.toString();
    }
    return value.toString();
  }
}
