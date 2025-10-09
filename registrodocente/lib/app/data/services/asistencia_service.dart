import 'package:shared_preferences/shared_preferences.dart';
import 'asistencia_supabase_service.dart';

class AsistenciaService {
  static final AsistenciaService _instance = AsistenciaService._internal();
  factory AsistenciaService() => _instance;
  AsistenciaService._internal();

  final _supabaseService = AsistenciaSupabaseService();

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

    // Guardar en Supabase
    await _supabaseService.guardarRegistrosMeses(
      curso: curso,
      seccion: seccion,
      registros: meses,
    );

    return meses;
  }

  // Guardar registros en SharedPreferences
  Future<void> _guardarRegistros(String curso, String seccion, List<Map<String, dynamic>> registros) async {
    // Ahora usa Supabase
    await _supabaseService.guardarRegistrosMeses(
      curso: curso,
      seccion: seccion,
      registros: registros,
    );
  }

  // Obtener registros de un curso y sección
  Future<List<Map<String, dynamic>>> obtenerRegistros(String curso, String seccion) async {
    // Obtener desde Supabase
    final registros = await _supabaseService.obtenerRegistrosMeses(
      curso: curso,
      seccion: seccion,
    );

    return registros ?? [];
  }

  // Verificar si ya existen registros
  Future<bool> existenRegistros(String curso, String seccion) async {
    final registros = await obtenerRegistros(curso, seccion);
    return registros.isNotEmpty;
  }

  // Limpiar registros de un curso y sección
  Future<void> limpiarRegistros(String curso, String seccion) async {
    // Nota: Podríamos implementar un método de eliminación en Supabase si es necesario
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
    // Guardar en Supabase
    await _supabaseService.guardarDatosAsistenciaMes(
      curso: curso,
      seccion: seccion,
      mes: mes,
      asistencia: asistencia,
      feriados: feriados,
      diasMes: diasMes,
    );
  }

  // Obtener datos completos de asistencia para un mes específico
  Future<Map<String, dynamic>?> obtenerDatosAsistencia({
    required String curso,
    required String seccion,
    required String mes,
  }) async {
    // Obtener desde Supabase
    return await _supabaseService.obtenerDatosAsistenciaMes(
      curso: curso,
      seccion: seccion,
      mes: mes,
    );
  }
}
