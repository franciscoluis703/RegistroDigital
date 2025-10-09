import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'curso_context_service.dart';
import 'estudiantes_supabase_service.dart';

class EstudiantesService {
  final CursoContextService _cursoContext = CursoContextService();
  final EstudiantesSupabaseService _supabaseService = EstudiantesSupabaseService();

  // Generar clave única para cada curso
  Future<String> _getKeyEstudiantes() async {
    final cursoId = await _cursoContext.obtenerCursoActual();
    if (cursoId == null) {
      return 'estudiantes_lista_default'; // Fallback
    }
    return 'estudiantes_lista_$cursoId';
  }

  // Obtener lista de estudiantes del curso actual
  Future<List<Map<String, dynamic>>> obtenerEstudiantes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKeyEstudiantes();
    final estudiantesJson = prefs.getString(key);

    if (estudiantesJson != null) {
      final List<dynamic> decoded = json.decode(estudiantesJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  // Guardar estudiantes del curso actual
  Future<void> guardarEstudiantes(List<Map<String, dynamic>> estudiantes) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKeyEstudiantes();
    await prefs.setString(key, json.encode(estudiantes));
  }

  // Agregar estudiante
  Future<void> agregarEstudiante(Map<String, dynamic> estudiante) async {
    final estudiantes = await obtenerEstudiantes();
    estudiantes.add(estudiante);
    await guardarEstudiantes(estudiantes);
  }

  // Actualizar estudiante por índice
  Future<void> actualizarEstudiante(int index, Map<String, dynamic> estudiante) async {
    final estudiantes = await obtenerEstudiantes();
    if (index >= 0 && index < estudiantes.length) {
      estudiantes[index] = estudiante;
      await guardarEstudiantes(estudiantes);
    }
  }

  // Eliminar estudiante
  Future<void> eliminarEstudiante(int index) async {
    final estudiantes = await obtenerEstudiantes();
    if (index >= 0 && index < estudiantes.length) {
      estudiantes.removeAt(index);
      await guardarEstudiantes(estudiantes);
    }
  }

  // Obtener solo los nombres (para mostrar en listas)
  Future<List<String>> obtenerNombresEstudiantes() async {
    // Primero intentar obtener desde datos_generales
    final datosGenerales = await obtenerDatosGenerales();
    if (datosGenerales != null) {
      final nombres = datosGenerales['nombres'] as List<String>;
      return List.generate(40, (index) {
        if (index < nombres.length && nombres[index].isNotEmpty) {
          return nombres[index];
        }
        return '';
      });
    }

    // Fallback: usar la lista antigua de estudiantes
    final estudiantes = await obtenerEstudiantes();
    return estudiantes
        .map((e) => (e['nombre'] as String?) ?? 'Estudiante ${estudiantes.indexOf(e) + 1}')
        .toList();
  }

  // Obtener cantidad de estudiantes
  Future<int> obtenerCantidadEstudiantes() async {
    final estudiantes = await obtenerEstudiantes();
    return estudiantes.length;
  }

  // Guardar datos generales completos (para general_student_screen)
  Future<void> guardarDatosGenerales({
    required List<String> nombres,
    required List<Map<String, String>> camposAdicionales,
  }) async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';

    // Guardar en Supabase
    await _supabaseService.guardarDatosGenerales(
      cursoId: cursoId,
      nombres: nombres,
      camposAdicionales: camposAdicionales,
    );
  }

  // Obtener datos generales completos
  Future<Map<String, dynamic>?> obtenerDatosGenerales() async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';

    // Obtener desde Supabase
    return await _supabaseService.obtenerDatosGenerales(cursoId);
  }
}
