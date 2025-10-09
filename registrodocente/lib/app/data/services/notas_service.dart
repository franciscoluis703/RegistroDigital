import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class NotasService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Crear una nueva nota
  Future<bool> crearNota(String titulo, String contenido) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase.from('notas').insert({
        'user_id': userId,
        'titulo': titulo,
        'contenido': contenido,
      });

      return true;
    } catch (e) {
      print('Error al crear nota: $e');
      return false;
    }
  }

  /// Obtener todas las notas del usuario
  Future<List<Map<String, dynamic>>> obtenerNotas() async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase
          .from('notas')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener notas: $e');
      return [];
    }
  }

  /// Obtener una nota específica
  Future<Map<String, dynamic>?> obtenerNota(String notaId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('notas')
          .select()
          .eq('id', notaId)
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener nota: $e');
      return null;
    }
  }

  /// Actualizar una nota existente
  Future<bool> actualizarNota(String notaId, String titulo, String contenido) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase
          .from('notas')
          .update({
            'titulo': titulo,
            'contenido': contenido,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notaId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error al actualizar nota: $e');
      return false;
    }
  }

  /// Eliminar una nota
  Future<bool> eliminarNota(String notaId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase
          .from('notas')
          .delete()
          .eq('id', notaId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error al eliminar nota: $e');
      return false;
    }
  }

  /// Buscar notas por título o contenido
  Future<List<Map<String, dynamic>>> buscarNotas(String query) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase
          .from('notas')
          .select()
          .eq('user_id', userId)
          .or('titulo.ilike.%$query%,contenido.ilike.%$query%')
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al buscar notas: $e');
      return [];
    }
  }
}
