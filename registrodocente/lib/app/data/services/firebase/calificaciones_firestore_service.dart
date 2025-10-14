import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/calificacion.dart';
import 'firebase_auth_service.dart';
import '../activity_log_service.dart';

/// Servicio de Calificaciones para Firestore
/// Reemplazo completo de CalificacionesSupabaseService
///
/// Funcionalidades:
/// - Guardar/obtener notas de los 4 grupos
/// - Guardar/obtener datos de promoción de grado
/// - Guardar/obtener nombres personalizados de grupos
/// - Sincronización en tiempo real
///
/// Estructura en Firestore:
/// users/{uid}/cursos/{cursoId}/calificaciones/notas_grupos
/// users/{uid}/cursos/{cursoId}/calificaciones/promocion_grado
class CalificacionesFirestoreService {
  static final CalificacionesFirestoreService _instance = CalificacionesFirestoreService._internal();
  factory CalificacionesFirestoreService() => _instance;
  CalificacionesFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _currentUserId => _authService.currentUserId;

  // ============================================
  // REFERENCIAS A DOCUMENTOS
  // ============================================

  /// Referencia al documento de notas de grupos
  DocumentReference<Map<String, dynamic>> _getNotasGruposDoc(String curso, String seccion) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(curso)
        .collection('calificaciones')
        .doc('notas_grupos_$seccion');
  }

  /// Referencia al documento de promoción de grado
  DocumentReference<Map<String, dynamic>> _getPromocionGradoDoc(String cursoId) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(cursoId)
        .collection('calificaciones')
        .doc('promocion_grado');
  }

  // ============================================
  // NOTAS DE GRUPOS
  // ============================================

  /// Guardar todas las notas de los 4 grupos
  Future<bool> guardarNotasGrupos({
    required String curso,
    required String seccion,
    required List<List<String>> notasGrupo1,
    required List<List<String>> notasGrupo2,
    required List<List<String>> notasGrupo3,
    required List<List<String>> notasGrupo4,
  }) async {
    try {
      final docRef = _getNotasGruposDoc(curso, seccion);

      // Obtener nombres de grupos actuales (si existen)
      final snapshot = await docRef.get();
      String nombreGrupo1 = 'Grupo 1';
      String nombreGrupo2 = 'Grupo 2';
      String nombreGrupo3 = 'Grupo 3';
      String nombreGrupo4 = 'Grupo 4';

      if (snapshot.exists) {
        final data = snapshot.data()!;
        nombreGrupo1 = data['nombre_grupo_1'] ?? 'Grupo 1';
        nombreGrupo2 = data['nombre_grupo_2'] ?? 'Grupo 2';
        nombreGrupo3 = data['nombre_grupo_3'] ?? 'Grupo 3';
        nombreGrupo4 = data['nombre_grupo_4'] ?? 'Grupo 4';
      }

      await docRef.set({
        'curso_id': curso,
        'seccion': seccion,
        'notas_grupo_1': notasGrupo1,
        'notas_grupo_2': notasGrupo2,
        'notas_grupo_3': notasGrupo3,
        'notas_grupo_4': notasGrupo4,
        'nombre_grupo_1': nombreGrupo1,
        'nombre_grupo_2': nombreGrupo2,
        'nombre_grupo_3': nombreGrupo3,
        'nombre_grupo_4': nombreGrupo4,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'calificaciones',
        entityId: 'notas_grupos_$seccion',
        details: {
          'curso': curso,
          'seccion': seccion,
          'total_estudiantes_grupo1': notasGrupo1.length,
          'total_estudiantes_grupo2': notasGrupo2.length,
          'total_estudiantes_grupo3': notasGrupo3.length,
          'total_estudiantes_grupo4': notasGrupo4.length,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener todas las notas de los 4 grupos
  Future<Map<String, dynamic>?> obtenerNotasGrupos({
    required String curso,
    required String seccion,
  }) async {
    try {
      final snapshot = await _getNotasGruposDoc(curso, seccion).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;

      return {
        'notasGrupo1': Calificacion.parseNotasGrupo(data['notas_grupo_1']),
        'notasGrupo2': Calificacion.parseNotasGrupo(data['notas_grupo_2']),
        'notasGrupo3': Calificacion.parseNotasGrupo(data['notas_grupo_3']),
        'notasGrupo4': Calificacion.parseNotasGrupo(data['notas_grupo_4']),
        'nombreGrupo1': data['nombre_grupo_1'] ?? 'Grupo 1',
        'nombreGrupo2': data['nombre_grupo_2'] ?? 'Grupo 2',
        'nombreGrupo3': data['nombre_grupo_3'] ?? 'Grupo 3',
        'nombreGrupo4': data['nombre_grupo_4'] ?? 'Grupo 4',
      };
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // NOMBRES DE GRUPOS
  // ============================================

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
      await _getNotasGruposDoc(curso, seccion).set({
        'nombre_grupo_1': nombreGrupo1,
        'nombre_grupo_2': nombreGrupo2,
        'nombre_grupo_3': nombreGrupo3,
        'nombre_grupo_4': nombreGrupo4,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener nombres personalizados de los grupos
  Future<Map<String, String>?> obtenerNombresGrupos({
    required String curso,
    required String seccion,
  }) async {
    try {
      final snapshot = await _getNotasGruposDoc(curso, seccion).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;

      return {
        'nombreGrupo1': data['nombre_grupo_1'] ?? 'Grupo 1',
        'nombreGrupo2': data['nombre_grupo_2'] ?? 'Grupo 2',
        'nombreGrupo3': data['nombre_grupo_3'] ?? 'Grupo 3',
        'nombreGrupo4': data['nombre_grupo_4'] ?? 'Grupo 4',
      };
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // PROMOCIÓN DE GRADO
  // ============================================

  /// Guardar datos de promoción del grado (matriz final)
  Future<bool> guardarPromocionGradoMatricial({
    required String cursoId,
    required List<List<String>> datosPromocion,
    required String asignatura,
    required String grado,
    required String docente,
  }) async {
    try {
      await _getPromocionGradoDoc(cursoId).set({
        'curso_id': cursoId,
        'datos_promocion': datosPromocion,
        'asignatura': asignatura,
        'grado': grado,
        'docente': docente,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'promocion_grado',
        entityId: cursoId,
        details: {
          'asignatura': asignatura,
          'grado': grado,
          'docente': docente,
          'total_estudiantes': datosPromocion.length,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener datos de promoción del grado
  Future<Map<String, dynamic>?> obtenerPromocionGradoMatricial(String cursoId) async {
    try {
      final snapshot = await _getPromocionGradoDoc(cursoId).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;

      return {
        'datosPromocion': PromocionGrado.parseDatosPromocion(data['datos_promocion']),
        'asignatura': data['asignatura'] ?? '',
        'grado': data['grado'] ?? '',
        'docente': data['docente'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // STREAMS EN TIEMPO REAL
  // ============================================

  /// Stream de notas de grupos
  Stream<Calificacion?> notasGruposStream(String curso, String seccion) {
    return _getNotasGruposDoc(curso, seccion).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return Calificacion.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  /// Stream de promoción de grado
  Stream<PromocionGrado?> promocionGradoStream(String cursoId) {
    return _getPromocionGradoDoc(cursoId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return PromocionGrado.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  // ============================================
  // MÉTODOS LEGACY (compatibilidad con UI antigua)
  // ============================================

  /// Guardar calificaciones finales (legacy)
  /// Este método se mantiene por compatibilidad pero se recomienda usar guardarNotasGrupos
  Future<void> guardarCalificacionesFinales(
    String curso,
    String seccion,
    List<String> calificaciones,
  ) async {
    // Por ahora, no hace nada
    // Las calificaciones se guardan con guardarNotasGrupos
  }

  /// Obtener calificaciones finales (legacy)
  Future<List<String>> obtenerCalificacionesFinalesAsync(
    String curso,
    String seccion,
  ) async {
    // Retornar lista vacía de 40 elementos
    return List.generate(40, (_) => '');
  }

  /// Obtener fecha de carga (legacy)
  Future<DateTime?> obtenerFechaCargaAsync(String curso, String seccion) async {
    try {
      final snapshot = await _getNotasGruposDoc(curso, seccion).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      if (data['updated_at'] != null) {
        return (data['updated_at'] as Timestamp).toDate();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Limpiar calificaciones
  Future<void> limpiarCalificaciones(String curso, String seccion) async {
    try {
      await _getNotasGruposDoc(curso, seccion).delete();
    } catch (e) {
      // Error al limpiar
    }
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Verificar si existen notas guardadas
  Future<bool> existenNotasGrupos(String curso, String seccion) async {
    try {
      final snapshot = await _getNotasGruposDoc(curso, seccion).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si existe promoción de grado
  Future<bool> existePromocionGrado(String cursoId) async {
    try {
      final snapshot = await _getPromocionGradoDoc(cursoId).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // EVALUACIONES POR DÍAS
  // ============================================

  /// Referencia al documento de evaluaciones por días
  DocumentReference<Map<String, dynamic>> _getEvaluacionesDiasDoc(String cursoId) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(cursoId)
        .collection('calificaciones')
        .doc('evaluaciones_dias');
  }

  /// Guardar evaluaciones por días
  Future<bool> guardarEvaluacionesDias({
    required String cursoId,
    required String nombreDocente,
    required String grado,
    required List<Map<String, String>> estudiantes,
  }) async {
    try {
      await _getEvaluacionesDiasDoc(cursoId).set({
        'curso_id': cursoId,
        'nombre_docente': nombreDocente,
        'grado': grado,
        'estudiantes': estudiantes,
        'ultima_actualizacion': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'evaluaciones_dias',
        entityId: cursoId,
        details: {
          'nombre_docente': nombreDocente,
          'grado': grado,
          'total_estudiantes': estudiantes.length,
        },
      );

      return true;
    } catch (e) {
      print('Error al guardar evaluaciones días: $e');
      return false;
    }
  }

  /// Obtener evaluaciones por días
  Future<Map<String, dynamic>?> obtenerEvaluacionesDias(String cursoId) async {
    try {
      final snapshot = await _getEvaluacionesDiasDoc(cursoId).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;

      return {
        'nombreDocente': data['nombre_docente'] ?? '',
        'grado': data['grado'] ?? '',
        'estudiantes': (data['estudiantes'] as List<dynamic>?)
                ?.map((e) => Map<String, String>.from(e as Map))
                .toList() ??
            [],
        'ultimaActualizacion': data['ultima_actualizacion'] != null
            ? (data['ultima_actualizacion'] as Timestamp).toDate().toIso8601String()
            : null,
      };
    } catch (e) {
      print('Error al obtener evaluaciones días: $e');
      return null;
    }
  }
}
