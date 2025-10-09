import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class CalificacionesSupabaseService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Registrar calificación de un estudiante
  Future<Map<String, dynamic>?> registrarCalificacion({
    required String cursoId,
    required String estudianteId,
    required String periodo, // "Grupo 1", "Grupo 2", "Grupo 3", "Grupo 4", "Final"
    double? competencia1,
    double? competencia2,
    double? competencia3,
    double? competencia4,
    double? competencia5,
    double? competencia6,
    double? competencia7,
    double? competencia8,
    double? competencia9,
    double? competencia10,
    double? calificacionFinal,
    String? seccion,
    String? observaciones,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;

      final response = await supabase.from('calificaciones').upsert({
        'curso_id': cursoId,
        'estudiante_id': estudianteId,
        'periodo': periodo,
        'competencia_1': competencia1,
        'competencia_2': competencia2,
        'competencia_3': competencia3,
        'competencia_4': competencia4,
        'competencia_5': competencia5,
        'competencia_6': competencia6,
        'competencia_7': competencia7,
        'competencia_8': competencia8,
        'competencia_9': competencia9,
        'competencia_10': competencia10,
        'calificacion_final': calificacionFinal,
        'seccion': seccion,
        'observaciones': observaciones,
      }).select().single();

      return response;
    } catch (e) {
      // Error al registrar calificación
      return null;
    }
  }

  /// Obtener calificaciones de un estudiante
  Future<List<Map<String, dynamic>>> obtenerCalificacionesEstudiante({
    required String estudianteId,
    String? periodo,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      var query = supabase
          .from('calificaciones')
          .select()
          .eq('estudiante_id', estudianteId);

      if (periodo != null) {
        query = query.eq('periodo', periodo);
      }

      final response = await query.order('periodo', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener calificaciones
      return [];
    }
  }

  /// Obtener todas las calificaciones de un curso
  Future<List<Map<String, dynamic>>> obtenerCalificacionesCurso({
    required String cursoId,
    String? periodo,
    String? seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      var query = supabase
          .from('calificaciones')
          .select('*, estudiantes(*)')
          .eq('curso_id', cursoId);

      if (periodo != null) {
        query = query.eq('periodo', periodo);
      }

      if (seccion != null) {
        query = query.eq('seccion', seccion);
      }

      final response = await query.order('periodo', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener calificaciones
      return [];
    }
  }

  /// Actualizar calificación
  Future<bool> actualizarCalificacion(
    String calificacionId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('calificaciones')
          .update(datos)
          .eq('id', calificacionId);

      return true;
    } catch (e) {
      // Error al actualizar calificación
      return false;
    }
  }

  /// Eliminar calificación
  Future<bool> eliminarCalificacion(String calificacionId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('calificaciones')
          .delete()
          .eq('id', calificacionId);

      return true;
    } catch (e) {
      // Error al eliminar calificación
      return false;
    }
  }

  /// Registrar promoción de grado de un estudiante
  Future<Map<String, dynamic>?> registrarPromocion({
    required String cursoId,
    required String estudianteId,
    required String anioEscolar,
    int? numeroOrden,
    double? calificacionGrupo1,
    double? calificacionGrupo2,
    double? calificacionGrupo3,
    double? calificacionGrupo4,
    double? promedioFinal,
    String? estadoPromocion, // 'promovido', 'reprobado', 'pendiente'
    String? asignatura,
    String? grado,
    String? seccion,
    String? observaciones,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;

      final response = await supabase.from('promocion_grado').upsert({
        'curso_id': cursoId,
        'estudiante_id': estudianteId,
        'anio_escolar': anioEscolar,
        'numero_orden': numeroOrden,
        'calificacion_grupo_1': calificacionGrupo1,
        'calificacion_grupo_2': calificacionGrupo2,
        'calificacion_grupo_3': calificacionGrupo3,
        'calificacion_grupo_4': calificacionGrupo4,
        'promedio_final': promedioFinal,
        'estado_promocion': estadoPromocion,
        'asignatura': asignatura,
        'grado': grado,
        'seccion': seccion,
        'observaciones': observaciones,
      }).select().single();

      return response;
    } catch (e) {
      // Error al registrar promoción
      return null;
    }
  }

  /// Obtener datos de promoción de un curso
  Future<List<Map<String, dynamic>>> obtenerPromocionCurso({
    required String cursoId,
    String? anioEscolar,
    String? seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      var query = supabase
          .from('promocion_grado')
          .select('*, estudiantes(*)')
          .eq('curso_id', cursoId);

      if (anioEscolar != null) {
        query = query.eq('anio_escolar', anioEscolar);
      }

      if (seccion != null) {
        query = query.eq('seccion', seccion);
      }

      final response = await query.order('numero_orden', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener promoción
      return [];
    }
  }

  /// Obtener estadísticas de promoción
  Future<Map<String, int>> obtenerEstadisticasPromocion({
    required String cursoId,
    String? anioEscolar,
  }) async {
    try {
      final promociones = await obtenerPromocionCurso(
        cursoId: cursoId,
        anioEscolar: anioEscolar,
      );

      final estadisticas = <String, int>{
        'promovido': 0,
        'reprobado': 0,
        'pendiente': 0,
        'total': promociones.length,
      };

      for (var promocion in promociones) {
        final estado = promocion['estado_promocion'] as String?;
        if (estado != null) {
          estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
        }
      }

      return estadisticas;
    } catch (e) {
      // Error al obtener estadísticas
      return {};
    }
  }

  /// Calcular promedio de calificaciones de un estudiante
  Future<double?> calcularPromedioEstudiante({
    required String estudianteId,
    List<String>? periodos,
  }) async {
    try {
      final calificaciones = await obtenerCalificacionesEstudiante(
        estudianteId: estudianteId,
      );

      if (calificaciones.isEmpty) return null;

      final calificacionesFiltradas = periodos != null
          ? calificaciones
              .where((c) => periodos.contains(c['periodo']))
              .toList()
          : calificaciones;

      if (calificacionesFiltradas.isEmpty) return null;

      double suma = 0;
      int count = 0;

      for (var calificacion in calificacionesFiltradas) {
        final calFinal = calificacion['calificacion_final'];
        if (calFinal != null) {
          suma += (calFinal is int ? calFinal.toDouble() : calFinal as double);
          count++;
        }
      }

      return count > 0 ? suma / count : null;
    } catch (e) {
      // Error al calcular promedio
      return null;
    }
  }

  /// Registrar calificaciones masivas
  Future<bool> registrarCalificacionesMasivas({
    required String cursoId,
    required List<Map<String, dynamic>> calificaciones,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase.from('calificaciones').upsert(calificaciones);

      return true;
    } catch (e) {
      // Error al registrar calificaciones masivas
      return false;
    }
  }

  /// Guardar notas de los 4 grupos (formato matricial)
  Future<bool> guardarNotasGrupos({
    required String curso,
    required String seccion,
    required List<List<String>> notasGrupo1,
    required List<List<String>> notasGrupo2,
    required List<List<String>> notasGrupo3,
    required List<List<String>> notasGrupo4,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final datosJson = {
        'grupo1': notasGrupo1,
        'grupo2': notasGrupo2,
        'grupo3': notasGrupo3,
        'grupo4': notasGrupo4,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('calificaciones_notas_grupos')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('calificaciones_notas_grupos')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso', curso)
            .eq('seccion', seccion);
      } else {
        // Crear
        await supabase.from('calificaciones_notas_grupos').insert({
          'user_id': userId,
          'curso': curso,
          'seccion': seccion,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar notas de grupos: $e');
      return false;
    }
  }

  /// Obtener notas de los 4 grupos
  Future<Map<String, dynamic>?> obtenerNotasGrupos({
    required String curso,
    required String seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('calificaciones_notas_grupos')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final decoded = response['datos'] as Map<String, dynamic>;
        return {
          'grupo1': (decoded['grupo1'] as List<dynamic>)
              .map((row) => (row as List<dynamic>).map((e) => e.toString()).toList())
              .toList(),
          'grupo2': (decoded['grupo2'] as List<dynamic>)
              .map((row) => (row as List<dynamic>).map((e) => e.toString()).toList())
              .toList(),
          'grupo3': (decoded['grupo3'] as List<dynamic>)
              .map((row) => (row as List<dynamic>).map((e) => e.toString()).toList())
              .toList(),
          'grupo4': (decoded['grupo4'] as List<dynamic>)
              .map((row) => (row as List<dynamic>).map((e) => e.toString()).toList())
              .toList(),
          'ultimaActualizacion': decoded['ultimaActualizacion'],
        };
      }

      return null;
    } catch (e) {
      print('Error al obtener notas de grupos: $e');
      return null;
    }
  }

  /// Guardar datos de promoción del grado (formato matricial)
  Future<bool> guardarPromocionGradoMatricial({
    required String cursoId,
    required List<List<String>> datosPromocion,
    required String asignatura,
    required String grado,
    required String docente,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final datosJson = {
        'datosPromocion': datosPromocion,
        'asignatura': asignatura,
        'grado': grado,
        'docente': docente,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('promocion_grado_datos')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('promocion_grado_datos')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso_id', cursoId);
      } else {
        // Crear
        await supabase.from('promocion_grado_datos').insert({
          'user_id': userId,
          'curso_id': cursoId,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar promoción del grado: $e');
      return false;
    }
  }

  /// Obtener datos de promoción del grado (formato matricial)
  Future<Map<String, dynamic>?> obtenerPromocionGradoMatricial(String cursoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('promocion_grado_datos')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final decoded = response['datos'] as Map<String, dynamic>;
        return {
          'datosPromocion': (decoded['datosPromocion'] as List<dynamic>)
              .map((row) => (row as List<dynamic>).map((e) => e.toString()).toList())
              .toList(),
          'asignatura': decoded['asignatura'] ?? '',
          'grado': decoded['grado'] ?? '',
          'docente': decoded['docente'] ?? '',
          'ultimaActualizacion': decoded['ultimaActualizacion'],
        };
      }

      return null;
    } catch (e) {
      print('Error al obtener promoción del grado: $e');
      return null;
    }
  }

  /// Guardar datos de evaluaciones (días 1-10) - formato matricial
  Future<bool> guardarEvaluacionesDias({
    required String cursoId,
    required String nombreDocente,
    required String grado,
    required List<Map<String, String>> estudiantes,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final datosJson = {
        'nombreDocente': nombreDocente,
        'grado': grado,
        'estudiantes': estudiantes,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('evaluaciones_dias')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('evaluaciones_dias')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso_id', cursoId);
      } else {
        // Crear
        await supabase.from('evaluaciones_dias').insert({
          'user_id': userId,
          'curso_id': cursoId,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar evaluaciones días: $e');
      return false;
    }
  }

  /// Obtener datos de evaluaciones (días 1-10)
  Future<Map<String, dynamic>?> obtenerEvaluacionesDias(String cursoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('evaluaciones_dias')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final decoded = response['datos'] as Map<String, dynamic>;
        return {
          'nombreDocente': decoded['nombreDocente'] ?? '',
          'grado': decoded['grado'] ?? '',
          'estudiantes': (decoded['estudiantes'] as List<dynamic>)
              .map((e) => Map<String, String>.from(e as Map))
              .toList(),
          'ultimaActualizacion': decoded['ultimaActualizacion'],
        };
      }

      return null;
    } catch (e) {
      print('Error al obtener evaluaciones días: $e');
      return null;
    }
  }

  /// Guardar nombres personalizados de los grupos
  Future<bool> guardarNombresGrupos({
    required String curso,
    required String seccion,
    required String nombreGrupo1,
    required String nombreGrupo2,
    required String nombreGrupo3,
    required String nombreGrupo4,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final datosJson = {
        'grupo1': nombreGrupo1,
        'grupo2': nombreGrupo2,
        'grupo3': nombreGrupo3,
        'grupo4': nombreGrupo4,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('nombres_grupos_calificaciones')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('nombres_grupos_calificaciones')
            .update({
              'nombres': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso', curso)
            .eq('seccion', seccion);
      } else {
        // Crear
        await supabase.from('nombres_grupos_calificaciones').insert({
          'user_id': userId,
          'curso': curso,
          'seccion': seccion,
          'nombres': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar nombres de grupos: $e');
      return false;
    }
  }

  /// Obtener nombres personalizados de los grupos
  Future<Map<String, String>?> obtenerNombresGrupos({
    required String curso,
    required String seccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('nombres_grupos_calificaciones')
          .select()
          .eq('user_id', userId)
          .eq('curso', curso)
          .eq('seccion', seccion)
          .maybeSingle();

      if (response != null && response['nombres'] != null) {
        final decoded = response['nombres'] as Map<String, dynamic>;
        return {
          'grupo1': decoded['grupo1']?.toString() ?? 'GRUPO 1:',
          'grupo2': decoded['grupo2']?.toString() ?? 'GRUPO 2:',
          'grupo3': decoded['grupo3']?.toString() ?? 'GRUPO 3',
          'grupo4': decoded['grupo4']?.toString() ?? 'GRUPO 4',
        };
      }

      return null;
    } catch (e) {
      print('Error al obtener nombres de grupos: $e');
      return null;
    }
  }
}
