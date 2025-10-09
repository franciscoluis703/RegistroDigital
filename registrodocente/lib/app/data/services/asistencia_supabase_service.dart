import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AsistenciaSupabaseService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Registrar asistencia de un estudiante
  Future<Map<String, dynamic>?> registrarAsistencia({
    required String cursoId,
    required String estudianteId,
    required DateTime fecha,
    required String estado, // 'presente', 'ausente', 'tardanza', 'justificado', 'feriado'
    String? seccion,
    String? observaciones,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;

      final mes = _obtenerNombreMes(fecha.month);
      final anio = fecha.year;

      final response = await supabase.from('asistencias').upsert({
        'curso_id': cursoId,
        'estudiante_id': estudianteId,
        'fecha': fecha.toIso8601String().split('T')[0],
        'mes': mes,
        'anio': anio,
        'estado': estado,
        'seccion': seccion,
        'observaciones': observaciones,
      }).select().single();

      return response;
    } catch (e) {
      // Error al registrar asistencia
      return null;
    }
  }

  /// Obtener asistencias de un estudiante en un mes
  Future<List<Map<String, dynamic>>> obtenerAsistenciasEstudiante({
    required String estudianteId,
    required String mes,
    required int anio,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      final response = await supabase
          .from('asistencias')
          .select()
          .eq('estudiante_id', estudianteId)
          .eq('mes', mes)
          .eq('anio', anio)
          .order('fecha', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener asistencias
      return [];
    }
  }

  /// Obtener todas las asistencias de un curso en un mes
  Future<List<Map<String, dynamic>>> obtenerAsistenciasCurso({
    required String cursoId,
    required String mes,
    required int anio,
    String? seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      var query = supabase
          .from('asistencias')
          .select('*, estudiantes(*)')
          .eq('curso_id', cursoId)
          .eq('mes', mes)
          .eq('anio', anio);

      if (seccion != null) {
        query = query.eq('seccion', seccion);
      }

      final response = await query.order('fecha', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener asistencias
      return [];
    }
  }

  /// Crear registro de mes de asistencia
  Future<Map<String, dynamic>?> crearRegistroMes({
    required String cursoId,
    required String mes,
    required int anio,
    required String seccion,
    List<String>? diasMes,
    Map<int, String>? feriados,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;

      final response = await supabase.from('asistencia_registros').upsert({
        'curso_id': cursoId,
        'mes': mes,
        'anio': anio,
        'seccion': seccion,
        'dias_mes': diasMes ?? [],
        'feriados': feriados ?? {},
      }).select().single();

      return response;
    } catch (e) {
      // Error al crear registro de mes
      return null;
    }
  }

  /// Obtener registro de mes de asistencia
  Future<Map<String, dynamic>?> obtenerRegistroMes({
    required String cursoId,
    required String mes,
    required int anio,
    required String seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;

      final response = await supabase
          .from('asistencia_registros')
          .select()
          .eq('curso_id', cursoId)
          .eq('mes', mes)
          .eq('anio', anio)
          .eq('seccion', seccion)
          .maybeSingle();

      return response;
    } catch (e) {
      // Error al obtener registro de mes
      return null;
    }
  }

  /// Verificar si existe registro de mes
  Future<bool> existeRegistroMes({
    required String cursoId,
    required String mes,
    required int anio,
    required String seccion,
  }) async {
    final registro = await obtenerRegistroMes(
      cursoId: cursoId,
      mes: mes,
      anio: anio,
      seccion: seccion,
    );
    return registro != null;
  }

  /// Obtener todos los registros de meses de un curso
  Future<List<Map<String, dynamic>>> obtenerTodosRegistrosMeses(
    String cursoId,
  ) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      final response = await supabase
          .from('asistencia_registros')
          .select()
          .eq('curso_id', cursoId)
          .order('anio', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener registros de meses
      return [];
    }
  }

  /// Registrar asistencias masivas (múltiples estudiantes en una fecha)
  Future<bool> registrarAsistenciasMasivas({
    required String cursoId,
    required List<String> estudiantesIds,
    required DateTime fecha,
    required Map<String, String> estadosPorEstudiante, // estudianteId -> estado
    String? seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      final mes = _obtenerNombreMes(fecha.month);
      final anio = fecha.year;
      final fechaStr = fecha.toIso8601String().split('T')[0];

      final asistencias = estudiantesIds.map((estudianteId) {
        return {
          'curso_id': cursoId,
          'estudiante_id': estudianteId,
          'fecha': fechaStr,
          'mes': mes,
          'anio': anio,
          'estado': estadosPorEstudiante[estudianteId] ?? 'presente',
          'seccion': seccion,
        };
      }).toList();

      await supabase.from('asistencias').upsert(asistencias);

      return true;
    } catch (e) {
      // Error al registrar asistencias masivas
      return false;
    }
  }

  /// Obtener estadísticas de asistencia de un estudiante
  Future<Map<String, int>> obtenerEstadisticasEstudiante({
    required String estudianteId,
    String? mes,
    int? anio,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return {};

      var query = supabase
          .from('asistencias')
          .select('estado')
          .eq('estudiante_id', estudianteId);

      if (mes != null) query = query.eq('mes', mes);
      if (anio != null) query = query.eq('anio', anio);

      final response = await query;

      final estadisticas = <String, int>{
        'presente': 0,
        'ausente': 0,
        'tardanza': 0,
        'justificado': 0,
        'feriado': 0,
      };

      for (var asistencia in response) {
        final estado = asistencia['estado'] as String;
        estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
      }

      return estadisticas;
    } catch (e) {
      // Error al obtener estadísticas
      return {};
    }
  }

  /// Eliminar asistencia
  Future<bool> eliminarAsistencia(String asistenciaId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('asistencias')
          .delete()
          .eq('id', asistenciaId);

      return true;
    } catch (e) {
      // Error al eliminar asistencia
      return false;
    }
  }

  /// Obtener nombre del mes
  String _obtenerNombreMes(int mesNumero) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[mesNumero - 1];
  }

  /// Guardar registros de meses (lista de 10 meses)
  Future<bool> guardarRegistrosMeses({
    required String curso,
    required String seccion,
    required List<Map<String, dynamic>> registros,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final datosJson = {
        'registros': registros,
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('asistencia_registros_meses')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('asistencia_registros_meses')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso', curso)
            .eq('seccion', seccion);
      } else {
        // Crear
        await supabase.from('asistencia_registros_meses').insert({
          'user_id': userId,
          'curso': curso,
          'seccion': seccion,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar registros de meses: $e');
      return false;
    }
  }

  /// Obtener registros de meses
  Future<List<Map<String, dynamic>>?> obtenerRegistrosMeses({
    required String curso,
    required String seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('asistencia_registros_meses')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final datos = response['datos'] as Map<String, dynamic>;
        return (datos['registros'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      return null;
    } catch (e) {
      print('Error al obtener registros de meses: $e');
      return null;
    }
  }

  /// Guardar datos completos de asistencia de un mes
  Future<bool> guardarDatosAsistenciaMes({
    required String curso,
    required String seccion,
    required String mes,
    required List<List<String>> asistencia,
    required Map<int, String> feriados,
    required List<String> diasMes,
  }) async {
    try {
      print('🔵 Intentando guardar asistencia: curso=$curso, seccion=$seccion, mes=$mes');
      final supabase = _supabase;
      if (supabase == null) {
        print('❌ Supabase es null');
        return false;
      }
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return false;
      }
      print('✅ userId=$userId');

      final datosJson = {
        'asistencia': asistencia,
        'feriados': feriados.map((k, v) => MapEntry(k.toString(), v)),
        'diasMes': diasMes,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('asistencia_datos_mes')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .eq('mes', mes)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        print('🔄 Actualizando registro existente');
        await supabase
            .from('asistencia_datos_mes')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso', curso)
            .eq('seccion', seccion)
            .eq('mes', mes);
        print('✅ Registro actualizado exitosamente');
      } else {
        // Crear
        print('➕ Creando nuevo registro');
        await supabase.from('asistencia_datos_mes').insert({
          'user_id': userId,
          'curso': curso,
          'seccion': seccion,
          'mes': mes,
          'datos': datosJson,
        });
        print('✅ Registro creado exitosamente');
      }

      print('✅ ¡Datos guardados en Supabase exitosamente!');
      return true;
    } catch (e) {
      print('❌ Error al guardar datos de asistencia del mes: $e');
      return false;
    }
  }

  /// Obtener datos completos de asistencia de un mes
  Future<Map<String, dynamic>?> obtenerDatosAsistenciaMes({
    required String curso,
    required String seccion,
    required String mes,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('asistencia_datos_mes')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .eq('mes', mes)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final decoded = response['datos'] as Map<String, dynamic>;
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
    } catch (e) {
      print('Error al obtener datos de asistencia del mes: $e');
      return null;
    }
  }
}
