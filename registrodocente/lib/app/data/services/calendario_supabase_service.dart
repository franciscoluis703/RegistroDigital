import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class CalendarioSupabaseService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Crear evento en el calendario
  Future<Map<String, dynamic>?> crearEvento({
    required String titulo,
    required DateTime fecha,
    String? descripcion,
    String? horaInicio,
    String? horaFin,
    String? tipo, // 'feriado', 'reunion', 'evaluacion', 'actividad', 'otro'
    String? color,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase.from('eventos_calendario').insert({
        'user_id': userId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String().split('T')[0],
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'tipo': tipo,
        'color': color,
      }).select().single();

      return response;
    } catch (e) {
      // Error al crear evento
      return null;
    }
  }

  /// Obtener eventos del calendario
  Future<List<Map<String, dynamic>>> obtenerEventos({
    DateTime? desde,
    DateTime? hasta,
    String? tipo,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = supabase
          .from('eventos_calendario')
          .select()
          .eq('user_id', userId);

      if (desde != null) {
        query = query.gte('fecha', desde.toIso8601String().split('T')[0]);
      }

      if (hasta != null) {
        query = query.lte('fecha', hasta.toIso8601String().split('T')[0]);
      }

      if (tipo != null) {
        query = query.eq('tipo', tipo);
      }

      final response = await query.order('fecha', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener eventos
      return [];
    }
  }

  /// Obtener eventos de un mes específico
  Future<List<Map<String, dynamic>>> obtenerEventosMes({
    required int anio,
    required int mes,
  }) async {
    final primerDia = DateTime(anio, mes, 1);
    final ultimoDia = DateTime(anio, mes + 1, 0);

    return await obtenerEventos(
      desde: primerDia,
      hasta: ultimoDia,
    );
  }

  /// Obtener eventos de una fecha específica
  Future<List<Map<String, dynamic>>> obtenerEventosFecha(DateTime fecha) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final fechaStr = fecha.toIso8601String().split('T')[0];

      final response = await supabase
          .from('eventos_calendario')
          .select()
          .eq('user_id', userId)
          .eq('fecha', fechaStr)
          .order('hora_inicio', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener eventos
      return [];
    }
  }

  /// Actualizar evento
  Future<bool> actualizarEvento(
    String eventoId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('eventos_calendario')
          .update(datos)
          .eq('id', eventoId);

      return true;
    } catch (e) {
      // Error al actualizar evento
      return false;
    }
  }

  /// Eliminar evento
  Future<bool> eliminarEvento(String eventoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('eventos_calendario')
          .delete()
          .eq('id', eventoId);

      return true;
    } catch (e) {
      // Error al eliminar evento
      return false;
    }
  }

  /// Obtener próximos eventos (a partir de hoy)
  Future<List<Map<String, dynamic>>> obtenerProximosEventos({
    int limite = 10,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final hoy = DateTime.now().toIso8601String().split('T')[0];

      final response = await supabase
          .from('eventos_calendario')
          .select()
          .eq('user_id', userId)
          .gte('fecha', hoy)
          .order('fecha', ascending: true)
          .limit(limite);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener próximos eventos
      return [];
    }
  }

  /// Verificar si una fecha es feriado
  Future<bool> esFeriado(DateTime fecha) async {
    try {
      final eventos = await obtenerEventosFecha(fecha);
      return eventos.any((e) => e['tipo'] == 'feriado');
    } catch (e) {
      return false;
    }
  }
}
