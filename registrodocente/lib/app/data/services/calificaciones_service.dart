import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'calificaciones_supabase_service.dart';

class CalificacionesService {
  static final CalificacionesService _instance = CalificacionesService._internal();
  factory CalificacionesService() => _instance;
  CalificacionesService._internal();

  final _supabaseService = CalificacionesSupabaseService();

  // Obtener claves para SharedPreferences
  String _getKeyCalificaciones(String curso, String seccion) {
    return 'calificaciones_finales_${curso}_$seccion';
  }

  String _getKeyFecha(String curso, String seccion) {
    return 'calificaciones_fecha_${curso}_$seccion';
  }

  // Guardar calificaciones finales de un curso
  Future<void> guardarCalificacionesFinales(String curso, String seccion, List<String> calificaciones) async {
    final prefs = await SharedPreferences.getInstance();
    final keyCalif = _getKeyCalificaciones(curso, seccion);
    final keyFecha = _getKeyFecha(curso, seccion);

    await prefs.setString(keyCalif, json.encode(calificaciones));

    // Guardar la fecha solo si no existe (primera vez que se guardan)
    if (!prefs.containsKey(keyFecha)) {
      await prefs.setString(keyFecha, DateTime.now().toIso8601String());
    }
  }

  // Obtener calificaciones finales de un curso (versión sync para compatibilidad)
  List<String> obtenerCalificacionesFinales(String curso, String seccion) {
    // Esta es una versión simplificada que devuelve vacío
    // TODO: Refactorizar las pantallas para usar la versión async
    return List.generate(40, (_) => '');
  }

  // Obtener calificaciones finales de un curso (versión async)
  Future<List<String>> obtenerCalificacionesFinalesAsync(String curso, String seccion) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKeyCalificaciones(curso, seccion);
    final calificacionesJson = prefs.getString(key);

    if (calificacionesJson != null) {
      final List<dynamic> decoded = json.decode(calificacionesJson);
      return decoded.map((e) => e.toString()).toList();
    }

    return List.generate(40, (_) => '');
  }

  // Obtener fecha de carga
  DateTime? obtenerFechaCarga(String curso, String seccion) {
    // Versión sync simplificada
    return null;
  }

  // Obtener fecha de carga (versión async)
  Future<DateTime?> obtenerFechaCargaAsync(String curso, String seccion) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKeyFecha(curso, seccion);
    final fechaStr = prefs.getString(key);

    if (fechaStr != null) {
      return DateTime.parse(fechaStr);
    }

    return null;
  }

  // Verificar si han pasado 3 días desde la carga
  bool hanPasado3Dias(String curso, String seccion) {
    final fechaCarga = obtenerFechaCarga(curso, seccion);
    if (fechaCarga == null) return false;

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaCarga);
    return diferencia.inDays >= 3;
  }

  // Verificar si han pasado 5 días desde la carga
  bool hanPasado5Dias(String curso, String seccion) {
    final fechaCarga = obtenerFechaCarga(curso, seccion);
    if (fechaCarga == null) return false;

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaCarga);
    return diferencia.inDays >= 5;
  }

  // Verificar si han pasado 35 días desde la carga
  bool hanPasado35Dias(String curso, String seccion) {
    final fechaCarga = obtenerFechaCarga(curso, seccion);
    if (fechaCarga == null) return false;

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaCarga);
    return diferencia.inDays >= 35;
  }

  // Limpiar calificaciones
  Future<void> limpiarCalificaciones(String curso, String seccion) async {
    final prefs = await SharedPreferences.getInstance();
    final keyCalif = _getKeyCalificaciones(curso, seccion);
    final keyFecha = _getKeyFecha(curso, seccion);
    await prefs.remove(keyCalif);
    await prefs.remove(keyFecha);
  }

  // Guardar todas las notas individuales de los 4 grupos
  Future<void> guardarNotasGrupos({
    required String curso,
    required String seccion,
    required List<List<String>> notasGrupo1,
    required List<List<String>> notasGrupo2,
    required List<List<String>> notasGrupo3,
    required List<List<String>> notasGrupo4,
  }) async {
    // Guardar en Supabase
    await _supabaseService.guardarNotasGrupos(
      curso: curso,
      seccion: seccion,
      notasGrupo1: notasGrupo1,
      notasGrupo2: notasGrupo2,
      notasGrupo3: notasGrupo3,
      notasGrupo4: notasGrupo4,
    );
  }

  // Obtener todas las notas individuales de los 4 grupos
  Future<Map<String, dynamic>?> obtenerNotasGrupos({
    required String curso,
    required String seccion,
  }) async {
    // Obtener desde Supabase
    return await _supabaseService.obtenerNotasGrupos(
      curso: curso,
      seccion: seccion,
    );
  }

  // Guardar datos de promoción del grado
  Future<void> guardarPromocionGrado({
    required String curso,
    required String seccion,
    required List<List<String>> datosPromocion,
    required String asignatura,
    required String grado,
    required String docente,
  }) async {
    // Guardar en Supabase (usar curso como cursoId, seccion ya no se usa)
    await _supabaseService.guardarPromocionGradoMatricial(
      cursoId: curso,
      datosPromocion: datosPromocion,
      asignatura: asignatura,
      grado: grado,
      docente: docente,
    );
  }

  // Obtener datos de promoción del grado
  Future<Map<String, dynamic>?> obtenerPromocionGrado({
    required String curso,
    required String seccion,
  }) async {
    // Obtener desde Supabase (usar curso como cursoId)
    return await _supabaseService.obtenerPromocionGradoMatricial(curso);
  }

  // Guardar nombres personalizados de los grupos
  Future<void> guardarNombresGrupos({
    required String curso,
    required String seccion,
    required String nombreGrupo1,
    required String nombreGrupo2,
    required String nombreGrupo3,
    required String nombreGrupo4,
  }) async {
    await _supabaseService.guardarNombresGrupos(
      curso: curso,
      seccion: seccion,
      nombreGrupo1: nombreGrupo1,
      nombreGrupo2: nombreGrupo2,
      nombreGrupo3: nombreGrupo3,
      nombreGrupo4: nombreGrupo4,
    );
  }

  // Obtener nombres personalizados de los grupos
  Future<Map<String, String>?> obtenerNombresGrupos({
    required String curso,
    required String seccion,
  }) async {
    return await _supabaseService.obtenerNombresGrupos(
      curso: curso,
      seccion: seccion,
    );
  }
}
