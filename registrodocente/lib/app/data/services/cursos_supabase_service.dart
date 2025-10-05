import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class CursosSupabaseService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Obtener todos los cursos del usuario actual
  Future<List<Map<String, dynamic>>> obtenerCursos() async {
    try {
      if (_supabase == null) return [];
      final userId = _supabase!.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase!
          .from('cursos')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener cursos: $e');
      return [];
    }
  }

  /// Crear un nuevo curso
  Future<Map<String, dynamic>?> crearCurso({
    required String nombre,
    required String asignatura,
    List<String> secciones = const ['A'],
    bool oculto = false,
  }) async {
    try {
      if (_supabase == null) return null;
      final userId = _supabase!.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase!.from('cursos').insert({
        'user_id': userId,
        'nombre': nombre,
        'asignatura': asignatura,
        'secciones': jsonEncode(secciones),
        'oculto': oculto,
      }).select().single();

      return response;
    } catch (e) {
      print('Error al crear curso: $e');
      return null;
    }
  }

  /// Actualizar un curso
  Future<bool> actualizarCurso(String cursoId, Map<String, dynamic> datos) async {
    try {
      if (_supabase == null) return false;
      await _supabase!.from('cursos').update(datos).eq('id', cursoId);
      return true;
    } catch (e) {
      print('Error al actualizar curso: $e');
      return false;
    }
  }

  /// Eliminar un curso
  Future<bool> eliminarCurso(String cursoId) async {
    try {
      if (_supabase == null) return false;
      await _supabase!.from('cursos').delete().eq('id', cursoId);
      return true;
    } catch (e) {
      print('Error al eliminar curso: $e');
      return false;
    }
  }

  /// Ocultar/mostrar curso
  Future<bool> toggleOcultarCurso(String cursoId, bool oculto) async {
    try {
      if (_supabase == null) return false;
      await _supabase!.from('cursos').update({'oculto': oculto}).eq('id', cursoId);
      return true;
    } catch (e) {
      print('Error al ocultar/mostrar curso: $e');
      return false;
    }
  }

  /// Establecer curso activo
  Future<bool> establecerCursoActivo(String cursoId) async {
    try {
      if (_supabase == null) return false;
      final userId = _supabase!.auth.currentUser?.id;
      if (userId == null) return false;

      // Desactivar todos los cursos del usuario
      await _supabase!
          .from('cursos')
          .update({'activo': false})
          .eq('user_id', userId);

      // Activar el curso seleccionado
      await _supabase!
          .from('cursos')
          .update({'activo': true})
          .eq('id', cursoId);

      return true;
    } catch (e) {
      print('Error al establecer curso activo: $e');
      return false;
    }
  }

  /// Obtener curso activo
  Future<Map<String, dynamic>?> obtenerCursoActivo() async {
    try {
      if (_supabase == null) return null;
      final userId = _supabase!.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase!
          .from('cursos')
          .select()
          .eq('user_id', userId)
          .eq('activo', true)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener curso activo: $e');
      return null;
    }
  }

  /// Agregar sección a un curso
  Future<bool> agregarSeccion(String cursoId, String seccion) async {
    try {
      if (_supabase == null) return false;
      // Obtener curso actual
      final curso = await _supabase!
          .from('cursos')
          .select('secciones')
          .eq('id', cursoId)
          .single();

      // Parsear secciones
      List<String> secciones = [];
      if (curso['secciones'] is String) {
        secciones = List<String>.from(jsonDecode(curso['secciones']));
      } else if (curso['secciones'] is List) {
        secciones = List<String>.from(curso['secciones']);
      }

      // Agregar nueva sección
      if (!secciones.contains(seccion)) {
        secciones.add(seccion);
      }

      // Actualizar
      await _supabase!
          .from('cursos')
          .update({'secciones': jsonEncode(secciones)})
          .eq('id', cursoId);

      return true;
    } catch (e) {
      print('Error al agregar sección: $e');
      return false;
    }
  }

  /// Eliminar sección de un curso
  Future<bool> eliminarSeccion(String cursoId, String seccion) async {
    try {
      if (_supabase == null) return false;
      // Obtener curso actual
      final curso = await _supabase!
          .from('cursos')
          .select('secciones')
          .eq('id', cursoId)
          .single();

      // Parsear secciones
      List<String> secciones = [];
      if (curso['secciones'] is String) {
        secciones = List<String>.from(jsonDecode(curso['secciones']));
      } else if (curso['secciones'] is List) {
        secciones = List<String>.from(curso['secciones']);
      }

      // Eliminar sección
      secciones.remove(seccion);

      // Actualizar
      await _supabase!
          .from('cursos')
          .update({'secciones': jsonEncode(secciones)})
          .eq('id', cursoId);

      return true;
    } catch (e) {
      print('Error al eliminar sección: $e');
      return false;
    }
  }
}
