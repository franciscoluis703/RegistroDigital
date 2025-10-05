import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AsistenciaService {
  static final AsistenciaService _instance = AsistenciaService._internal();
  factory AsistenciaService() => _instance;
  AsistenciaService._internal();

  // Lista de todos los meses
  static const List<String> mesesDelAnio = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  // Obtener clave para SharedPreferences
  String _getKey(String curso, String seccion) {
    return 'asistencia_registros_${curso}_$seccion';
  }

  // Crear 10 meses consecutivos desde el mes inicial
  Future<List<Map<String, dynamic>>> crear10Meses(String mesInicial, String curso, String seccion) async {
    int mesIndex = mesesDelAnio.indexOf(mesInicial);
    if (mesIndex == -1) return [];

    List<Map<String, dynamic>> meses = [];
    for (int i = 0; i < 10; i++) {
      int indexActual = (mesIndex + i) % 12;
      meses.add({
        'mes': mesesDelAnio[indexActual],
        'materia': curso,
        'seccion': seccion,
      });
    }

    // Guardar en SharedPreferences
    await _guardarRegistros(curso, seccion, meses);

    return meses;
  }

  // Guardar registros en SharedPreferences
  Future<void> _guardarRegistros(String curso, String seccion, List<Map<String, dynamic>> registros) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(curso, seccion);
    await prefs.setString(key, json.encode(registros));
  }

  // Obtener registros de un curso y sección
  Future<List<Map<String, dynamic>>> obtenerRegistros(String curso, String seccion) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(curso, seccion);
    final registrosJson = prefs.getString(key);

    if (registrosJson != null) {
      final List<dynamic> decoded = json.decode(registrosJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  // Verificar si ya existen registros
  Future<bool> existenRegistros(String curso, String seccion) async {
    final registros = await obtenerRegistros(curso, seccion);
    return registros.isNotEmpty;
  }

  // Limpiar registros de un curso y sección
  Future<void> limpiarRegistros(String curso, String seccion) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(curso, seccion);
    await prefs.remove(key);
  }

  // Guardar datos completos de asistencia para un mes específico
  Future<void> guardarDatosAsistencia({
    required String curso,
    required String seccion,
    required String mes,
    required List<List<String>> asistencia,
    required Map<int, String> feriados,
    required List<String> diasMes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'asistencia_datos_${curso}_${seccion}_$mes';

    final datos = {
      'asistencia': asistencia,
      'feriados': feriados.map((k, v) => MapEntry(k.toString(), v)),
      'diasMes': diasMes,
      'ultimaActualizacion': DateTime.now().toIso8601String(),
    };

    await prefs.setString(key, json.encode(datos));
  }

  // Obtener datos completos de asistencia para un mes específico
  Future<Map<String, dynamic>?> obtenerDatosAsistencia({
    required String curso,
    required String seccion,
    required String mes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'asistencia_datos_${curso}_${seccion}_$mes';
    final datosJson = prefs.getString(key);

    if (datosJson != null) {
      final decoded = json.decode(datosJson);
      return {
        'asistencia': (decoded['asistencia'] as List<dynamic>)
            .map((row) => (row as List<dynamic>).map((e) => e.toString()).toList())
            .toList(),
        'feriados': (decoded['feriados'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(int.parse(k), v.toString())),
        'diasMes': (decoded['diasMes'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        'ultimaActualizacion': decoded['ultimaActualizacion'],
      };
    }

    return null;
  }
}
