import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class CentroEducativoService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Guardar o actualizar datos del centro educativo
  Future<bool> guardarDatosCentro(Map<String, dynamic> datos) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Verificar si ya existe una configuración
      final existing = await supabase
          .from('datos_centro_educativo')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar configuración existente
        await supabase
            .from('datos_centro_educativo')
            .update({
              ...datos,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);
      } else {
        // Crear nueva configuración
        await supabase.from('datos_centro_educativo').insert({
          'user_id': userId,
          ...datos,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar datos del centro: $e');
      return false;
    }
  }

  /// Obtener datos del centro educativo
  Future<Map<String, dynamic>?> obtenerDatosCentro() async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('datos_centro_educativo')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener datos del centro: $e');
      return null;
    }
  }

  /// Eliminar datos del centro educativo
  Future<bool> eliminarDatosCentro() async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase
          .from('datos_centro_educativo')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error al eliminar datos del centro: $e');
      return false;
    }
  }
}
