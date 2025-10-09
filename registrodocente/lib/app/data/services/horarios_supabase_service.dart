import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class HorariosSupabaseService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Crear horario
  Future<Map<String, dynamic>?> crearHorario({
    required String diaSemana, // 'lunes', 'martes', etc.
    required String horaInicio, // '08:00'
    required String horaFin, // '09:00'
    String? cursoId,
    String? asignatura,
    String? aula,
    String? seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase.from('horarios').insert({
        'user_id': userId,
        'curso_id': cursoId,
        'dia_semana': diaSemana,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'asignatura': asignatura,
        'aula': aula,
        'seccion': seccion,
      }).select().single();

      return response;
    } catch (e) {
      // Error al crear horario
      return null;
    }
  }

  /// Obtener horarios del usuario
  Future<List<Map<String, dynamic>>> obtenerHorarios({
    String? diaSemana,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = supabase
          .from('horarios')
          .select('*, cursos(*)')
          .eq('user_id', userId);

      if (diaSemana != null) {
        query = query.eq('dia_semana', diaSemana);
      }

      final response = await query.order('hora_inicio', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener horarios
      return [];
    }
  }

  /// Actualizar horario
  Future<bool> actualizarHorario(
    String horarioId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('horarios')
          .update(datos)
          .eq('id', horarioId);

      return true;
    } catch (e) {
      // Error al actualizar horario
      return false;
    }
  }

  /// Eliminar horario
  Future<bool> eliminarHorario(String horarioId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('horarios')
          .delete()
          .eq('id', horarioId);

      return true;
    } catch (e) {
      // Error al eliminar horario
      return false;
    }
  }

  /// Obtener horarios de un día específico
  Future<List<Map<String, dynamic>>> obtenerHorariosDia(String dia) async {
    return await obtenerHorarios(diaSemana: dia);
  }

  /// Verificar conflictos de horario
  Future<bool> tieneConflicto({
    required String diaSemana,
    required String horaInicio,
    required String horaFin,
    String? horarioIdExcluir,
  }) async {
    try {
      final horarios = await obtenerHorarios(diaSemana: diaSemana);

      for (var horario in horarios) {
        if (horarioIdExcluir != null && horario['id'] == horarioIdExcluir) {
          continue;
        }

        final inicio = horario['hora_inicio'] as String;
        final fin = horario['hora_fin'] as String;

        if (_hayConflictoHorario(horaInicio, horaFin, inicio, fin)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  bool _hayConflictoHorario(
    String inicio1,
    String fin1,
    String inicio2,
    String fin2,
  ) {
    return (inicio1.compareTo(fin2) < 0 && fin1.compareTo(inicio2) > 0);
  }

  /// Guardar configuración completa del horario
  Future<bool> guardarConfiguracionHorario(String configuracionJson) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Verificar si ya existe una configuración
      final existing = await supabase
          .from('configuraciones_horario')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar configuración existente
        await supabase
            .from('configuraciones_horario')
            .update({
              'configuracion': configuracionJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);
      } else {
        // Crear nueva configuración
        await supabase.from('configuraciones_horario').insert({
          'user_id': userId,
          'configuracion': configuracionJson,
        });
      }

      return true;
    } catch (e) {
      // Error al guardar configuración
      return false;
    }
  }

  /// Obtener configuración completa del horario
  Future<String?> obtenerConfiguracionHorario() async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('configuraciones_horario')
          .select('configuracion')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return response['configuracion'] as String?;
      }

      return null;
    } catch (e) {
      // Error al obtener configuración
      return null;
    }
  }
}
