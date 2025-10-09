import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class EstudiantesSupabaseService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Obtener todos los estudiantes de un curso
  Future<List<Map<String, dynamic>>> obtenerEstudiantes(String cursoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      final response = await supabase
          .from('estudiantes')
          .select()
          .eq('curso_id', cursoId)
          .order('numero_orden', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener estudiantes
      return [];
    }
  }

  /// Crear un nuevo estudiante
  Future<Map<String, dynamic>?> crearEstudiante({
    required String cursoId,
    required String nombre,
    String? apellido,
    String? sexo,
    DateTime? fechaNacimiento,
    int? edad,
    String? cedula,
    String? rne,
    String? lugarResidencia,
    String? provincia,
    String? municipio,
    String? sector,
    String? correoElectronico,
    String? telefono,
    String? centroEducativo,
    String? regional,
    String? distrito,
    bool repiteGrado = false,
    bool nuevoIngreso = false,
    bool promovido = false,
    String? contactoEmergenciaNombre,
    String? contactoEmergenciaTelefono,
    String? contactoEmergenciaParentesco,
    String? seccion,
    int? numeroOrden,
    String? fotoUrl,
    String? observaciones,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;

      final response = await supabase.from('estudiantes').insert({
        'curso_id': cursoId,
        'nombre': nombre,
        'apellido': apellido,
        'sexo': sexo,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'edad': edad,
        'cedula': cedula,
        'rne': rne,
        'lugar_residencia': lugarResidencia,
        'provincia': provincia,
        'municipio': municipio,
        'sector': sector,
        'correo_electronico': correoElectronico,
        'telefono': telefono,
        'centro_educativo': centroEducativo,
        'regional': regional,
        'distrito': distrito,
        'repite_grado': repiteGrado,
        'nuevo_ingreso': nuevoIngreso,
        'promovido': promovido,
        'contacto_emergencia_nombre': contactoEmergenciaNombre,
        'contacto_emergencia_telefono': contactoEmergenciaTelefono,
        'contacto_emergencia_parentesco': contactoEmergenciaParentesco,
        'seccion': seccion,
        'numero_orden': numeroOrden,
        'foto_url': fotoUrl,
        'observaciones': observaciones,
      }).select().single();

      return response;
    } catch (e) {
      // Error al crear estudiante
      return null;
    }
  }

  /// Actualizar un estudiante
  Future<bool> actualizarEstudiante(String estudianteId, Map<String, dynamic> datos) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('estudiantes')
          .update(datos)
          .eq('id', estudianteId);

      return true;
    } catch (e) {
      // Error al actualizar estudiante
      return false;
    }
  }

  /// Eliminar un estudiante
  Future<bool> eliminarEstudiante(String estudianteId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      await supabase
          .from('estudiantes')
          .delete()
          .eq('id', estudianteId);

      return true;
    } catch (e) {
      // Error al eliminar estudiante
      return false;
    }
  }

  /// Obtener solo los nombres de estudiantes de un curso
  Future<List<String>> obtenerNombresEstudiantes(String cursoId) async {
    try {
      final estudiantes = await obtenerEstudiantes(cursoId);
      return estudiantes
          .map((e) => '${e['nombre']} ${e['apellido'] ?? ''}'.trim())
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener cantidad de estudiantes de un curso
  Future<int> obtenerCantidadEstudiantes(String cursoId) async {
    try {
      final estudiantes = await obtenerEstudiantes(cursoId);
      return estudiantes.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtener estudiante por ID
  Future<Map<String, dynamic>?> obtenerEstudiantePorId(String estudianteId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;

      final response = await supabase
          .from('estudiantes')
          .select()
          .eq('id', estudianteId)
          .maybeSingle();

      return response;
    } catch (e) {
      // Error al obtener estudiante
      return null;
    }
  }

  /// Buscar estudiantes por nombre
  Future<List<Map<String, dynamic>>> buscarEstudiantesPorNombre(
    String cursoId,
    String nombre,
  ) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return [];

      final response = await supabase
          .from('estudiantes')
          .select()
          .eq('curso_id', cursoId)
          .ilike('nombre', '%$nombre%')
          .order('numero_orden', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al buscar estudiantes
      return [];
    }
  }

  /// Actualizar número de orden masivamente
  Future<bool> actualizarOrdenEstudiantes(
    Map<String, int> estudianteIdOrden,
  ) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;

      for (var entry in estudianteIdOrden.entries) {
        await supabase
            .from('estudiantes')
            .update({'numero_orden': entry.value})
            .eq('id', entry.key);
      }

      return true;
    } catch (e) {
      // Error al actualizar orden
      return false;
    }
  }

  /// Guardar datos generales de estudiantes (tabla estilo hoja de cálculo)
  Future<bool> guardarDatosGenerales({
    required String cursoId,
    required List<String> nombres,
    required List<Map<String, String>> camposAdicionales,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Convertir a JSON
      final datosJson = {
        'nombres': nombres,
        'campos_adicionales': camposAdicionales,
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('datos_generales_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('datos_generales_estudiantes')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso_id', cursoId);
      } else {
        // Crear
        await supabase.from('datos_generales_estudiantes').insert({
          'user_id': userId,
          'curso_id': cursoId,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar datos generales: $e');
      return false;
    }
  }

  /// Obtener datos generales de estudiantes
  Future<Map<String, dynamic>?> obtenerDatosGenerales(String cursoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('datos_generales_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final datos = response['datos'] as Map<String, dynamic>;
        return {
          'nombres': (datos['nombres'] as List).map((e) => e.toString()).toList(),
          'camposAdicionales': (datos['campos_adicionales'] as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList(),
        };
      }

      return null;
    } catch (e) {
      print('Error al obtener datos generales: $e');
      return null;
    }
  }

  /// Guardar condición inicial de estudiantes
  Future<bool> guardarCondicionInicial({
    required String cursoId,
    required List<Map<String, dynamic>> condiciones,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Convertir a JSON
      final datosJson = {
        'condiciones': condiciones,
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('condicion_inicial_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('condicion_inicial_estudiantes')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso_id', cursoId);
      } else {
        // Crear
        await supabase.from('condicion_inicial_estudiantes').insert({
          'user_id': userId,
          'curso_id': cursoId,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar condición inicial: $e');
      return false;
    }
  }

  /// Obtener condición inicial de estudiantes
  Future<List<Map<String, dynamic>>?> obtenerCondicionInicial(String cursoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('condicion_inicial_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final datos = response['datos'] as Map<String, dynamic>;
        return (datos['condiciones'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      return null;
    } catch (e) {
      print('Error al obtener condición inicial: $e');
      return null;
    }
  }

  /// Guardar datos de emergencias de estudiantes
  Future<bool> guardarDatosEmergencias({
    required String cursoId,
    required List<Map<String, String>> emergencias,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Convertir a JSON
      final datosJson = {
        'emergencias': emergencias,
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('datos_emergencias_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('datos_emergencias_estudiantes')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso_id', cursoId);
      } else {
        // Crear
        await supabase.from('datos_emergencias_estudiantes').insert({
          'user_id': userId,
          'curso_id': cursoId,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar datos de emergencias: $e');
      return false;
    }
  }

  /// Obtener datos de emergencias de estudiantes
  Future<List<Map<String, String>>?> obtenerDatosEmergencias(String cursoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('datos_emergencias_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final datos = response['datos'] as Map<String, dynamic>;
        return (datos['emergencias'] as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
      }

      return null;
    } catch (e) {
      print('Error al obtener datos de emergencias: $e');
      return null;
    }
  }

  /// Guardar datos de parentesco de estudiantes
  Future<bool> guardarDatosParentesco({
    required String cursoId,
    required List<Map<String, String>> parentescos,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return false;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Convertir a JSON
      final datosJson = {
        'parentescos': parentescos,
      };

      // Verificar si ya existe
      final existing = await supabase
          .from('parentesco_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (existing != null) {
        // Actualizar
        await supabase
            .from('parentesco_estudiantes')
            .update({
              'datos': datosJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('curso_id', cursoId);
      } else {
        // Crear
        await supabase.from('parentesco_estudiantes').insert({
          'user_id': userId,
          'curso_id': cursoId,
          'datos': datosJson,
        });
      }

      return true;
    } catch (e) {
      print('Error al guardar datos de parentesco: $e');
      return false;
    }
  }

  /// Obtener datos de parentesco de estudiantes
  Future<List<Map<String, String>>?> obtenerDatosParentesco(String cursoId) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('parentesco_estudiantes')
          .select()
          .eq('user_id', userId)
          .eq('curso_id', cursoId)
          .maybeSingle();

      if (response != null && response['datos'] != null) {
        final datos = response['datos'] as Map<String, dynamic>;
        return (datos['parentescos'] as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
      }

      return null;
    } catch (e) {
      print('Error al obtener datos de parentesco: $e');
      return null;
    }
  }
}
