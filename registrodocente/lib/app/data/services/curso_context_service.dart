import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Servicio para manejar el contexto del curso actual
/// Permite cambiar entre diferentes cursos y mantener datos separados
class CursoContextService {
  static const String _keyCursoActual = 'curso_actual_id';

  // Obtener el ID del curso actual seleccionado
  Future<String?> obtenerCursoActual() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCursoActual);
  }

  // Establecer el curso actual
  Future<void> establecerCursoActual(String cursoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCursoActual, cursoId);
  }

  // Generar ID único para un curso (grado + sección + asignatura)
  String generarIdCurso(String grado, String seccion, String asignatura) {
    return '${grado.toLowerCase().replaceAll(' ', '_')}_${seccion.toLowerCase()}_${asignatura.toLowerCase().replaceAll(' ', '_')}';
  }

  // Obtener el nombre legible del curso desde su ID
  String obtenerNombreCurso(String cursoId) {
    final partes = cursoId.split('_');
    if (partes.length >= 3) {
      final grado = partes[0].replaceAll('_', ' ');
      final seccion = partes[1].toUpperCase();
      final asignatura = partes.sublist(2).join(' ').replaceAll('_', ' ');
      return '$grado $seccion - $asignatura';
    }
    return cursoId;
  }

  // Verificar si hay un curso seleccionado
  Future<bool> tieneCursoSeleccionado() async {
    final cursoActual = await obtenerCursoActual();
    return cursoActual != null && cursoActual.isNotEmpty;
  }

  // Limpiar el curso actual (útil al cerrar sesión)
  Future<void> limpiarCursoActual() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCursoActual);
  }

  // Obtener el nombre completo del curso actual
  Future<String> obtenerNombreCursoActual() async {
    final prefs = await SharedPreferences.getInstance();
    final cursoId = await obtenerCursoActual();

    if (cursoId == null) {
      return 'Curso';
    }

    // Buscar el curso en la lista de cursos guardados
    final cursosJson = prefs.getString('cursos');
    if (cursosJson != null) {
      final List<String> cursos = List<String>.from(json.decode(cursosJson));
      for (final curso in cursos) {
        final id = curso.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');
        if (id == cursoId) {
          return curso;
        }
      }
    }

    return 'Curso';
  }

  // Obtener solo la asignatura del curso actual
  Future<String> obtenerAsignaturaActual() async {
    final nombreCurso = await obtenerNombreCursoActual();

    // El formato es: "Nombre - Asignatura"
    if (nombreCurso.contains(' - ')) {
      final partes = nombreCurso.split(' - ');
      if (partes.length >= 2) {
        return partes[1].trim();
      }
    }

    return 'Asignatura';
  }
}
