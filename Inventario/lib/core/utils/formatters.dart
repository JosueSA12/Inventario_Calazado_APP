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

  static String abreviarUnidad(String unidad) {
    if (unidad.isEmpty) return '';

    final unidadLower = unidad.toLowerCase().trim();

    switch (unidadLower) {
      case 'metros':
      case 'metro':
        return 'm';
      case 'centimetros':
      case 'centimetro':
        return 'cm';
      case 'litros':
      case 'litro':
        return 'L';
      case 'mililitros':
      case 'mililitro':
        return 'ml';
      case 'kilogramos':
      case 'kilogramo':
      case 'kilos':
      case 'kilo':
        return 'kg';
      case 'gramos':
      case 'gramo':
        return 'g';
      case 'pares':
      case 'par':
        return 'pares';
      case 'unidades':
      case 'unidad':
        return 'und';
      case 'bobinas':
      case 'bobina':
        return 'bob';
      case 'rollos':
      case 'rollo':
        return 'rol';
      case 'tubos':
      case 'tubo':
        return 'tub';
      case 'cajas':
      case 'caja':
        return 'cj';
      case 'galones':
      case 'galon':
        return 'gal';
      default:
        return unidad;
    }
  }

  static String formatCantidadConUnidad(dynamic cantidad, String unidad) {
    final double cantidadDouble = cantidad is num ? cantidad.toDouble() : 0.0;
    final cantidadStr = cantidadDouble.toStringAsFixed(1);
    final unidadAbr = abreviarUnidad(unidad);
    return '$cantidadStr $unidadAbr';
  }

  static String formatCantidad(dynamic cantidad) {
    final double cantidadDouble = cantidad is num ? cantidad.toDouble() : 0.0;
    if (cantidadDouble == cantidadDouble.truncate()) {
      return cantidadDouble.toInt().toString();
    }
    return cantidadDouble.toStringAsFixed(1);
  }
}
