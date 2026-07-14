import 'package:intl/intl.dart';

/// Utilidades para formateo de fechas en español
class FormatoFechas {
  // ==========================================
  // DÍAS DE LA SEMANA
  // ==========================================
  static const Map<int, String> _diasSemana = {
    1: 'Lun',
    2: 'Mar',
    3: 'Mié',
    4: 'Jue',
    5: 'Vie',
    6: 'Sáb',
    7: 'Dom',
  };

  // ==========================================
  // MESES
  // ==========================================
  static const Map<int, String> _meses = {
    1: 'Ene',
    2: 'Feb',
    3: 'Mar',
    4: 'Abr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Ago',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dic',
  };

  // ==========================================
  // MESES COMPLETOS EN
  // ==========================================
  static const Map<int, String> _mesesCompletos = {
    1: 'Enero',
    2: 'Febrero',
    3: 'Marzo',
    4: 'Abril',
    5: 'Mayo',
    6: 'Junio',
    7: 'Julio',
    8: 'Agosto',
    9: 'Septiembre',
    10: 'Octubre',
    11: 'Noviembre',
    12: 'Diciembre',
  };

  // ==========================================
  // OBTENER DÍA DE LA SEMANA EN ESPAÑOL
  // ==========================================
  static String diaSemana(int weekday) {
    return _diasSemana[weekday] ?? '';
  }

  // ==========================================
  // OBTENER MES ABREVIADO EN ESPAÑOL
  // ==========================================
  static String mesAbreviado(int month) {
    return _meses[month] ?? '';
  }

  // ==========================================
  // OBTENER MES COMPLETO EN ESPAÑOL
  // ==========================================
  static String mesCompleto(int month) {
    return _mesesCompletos[month] ?? '';
  }

  // ==========================================
  // FORMATEAR SEGÚN TIPO DE FILTRO
  // ==========================================
  static String formatearPorFiltro(DateTime fecha, String? tipoFiltro) {
    final tipo = tipoFiltro ?? 'RANGO';

    switch (tipo) {
      case 'DIA':
        return DateFormat('dd/MM').format(fecha);
      case 'SEMANA':
        return '${diaSemana(fecha.weekday)} ${DateFormat('dd').format(fecha)}';
      case 'MES':
        return DateFormat('dd/MM').format(fecha);
      case 'ANIO':
        return mesAbreviado(fecha.month);
      default: // RANGO
        return DateFormat('dd/MM').format(fecha);
    }
  }

  // ==========================================
  // OBTENER TÍTULO DEL FILTRO EN ESPAÑOL
  // ==========================================
  static String tituloFiltro(String? tipoFiltro) {
    switch (tipoFiltro) {
      case 'DIA':
        return 'Hoy';
      case 'SEMANA':
        return 'Semana';
      case 'MES':
        return 'Mes';
      case 'ANIO':
        return 'Año';
      default:
        return 'Rango';
    }
  }

  // ==========================================
  // OBTENER TÍTULO DINÁMICO DEL GRÁFICO
  // ==========================================
  static String tituloGrafico(String baseTitulo, String? tipoFiltro) {
    switch (tipoFiltro) {
      case 'DIA':
        return '$baseTitulo (Hoy)';
      case 'SEMANA':
        return '$baseTitulo por Día (Semana)';
      case 'MES':
        return '$baseTitulo por Día (Mes)';
      case 'ANIO':
        return '$baseTitulo por Mes (Año)';
      default:
        return '$baseTitulo por Día (Rango)';
    }
  }

  // ==========================================
  // FORMATEAR FECHA COMPLETA EN ESPAÑOL
  // ==========================================
  static String fechaCompleta(DateTime fecha) {
    return '${diaSemana(fecha.weekday)} ${fecha.day} de ${mesCompleto(fecha.month)} de ${fecha.year}';
  }

  // ==========================================
  // FORMATEAR FECHA CORTA EN ESPAÑOL
  // ==========================================
  static String fechaCorta(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  // ==========================================
  // FORMATEAR HORA EN ESPAÑOL
  // ==========================================
  static String hora(DateTime fecha) {
    return DateFormat('HH:mm').format(fecha);
  }

  // ==========================================
  // FORMATEAR FECHA Y HORA EN ESPAÑOL
  // ==========================================
  static String fechaHora(DateTime fecha) {
    return '${fechaCorta(fecha)} ${hora(fecha)}';
  }
}
