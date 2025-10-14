import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/asistencia.dart';
import 'firebase_auth_service.dart';
import '../activity_log_service.dart';

/// Servicio de Asistencia para Firestore
/// Reemplazo completo de AsistenciaSupabaseService
///
/// Funcionalidades:
/// - Crear y gestionar registros de meses
/// - Guardar/obtener datos de asistencia por mes
/// - Sincronización en tiempo real
///
/// Estructura en Firestore:
/// users/{uid}/cursos/{cursoId}/asistencia/registro_meses
/// users/{uid}/cursos/{cursoId}/asistencia/mes_{nombre_mes}_{seccion}
class AsistenciaFirestoreService {
  static final AsistenciaFirestoreService _instance = AsistenciaFirestoreService._internal();
  factory AsistenciaFirestoreService() => _instance;
  AsistenciaFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _currentUserId => _authService.currentUserId;

  /// Lista de todos los meses del año
  static const List<String> mesesDelAnio = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  // ============================================
  // REFERENCIAS A DOCUMENTOS
  // ============================================

  /// Referencia al documento de registro de meses
  DocumentReference<Map<String, dynamic>> _getRegistroMesesDoc(String curso, String seccion) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(curso)
        .collection('asistencia')
        .doc('registro_meses_$seccion');
  }

  /// Referencia al documento de datos de asistencia de un mes específico
  DocumentReference<Map<String, dynamic>> _getDatosAsistenciaDoc(
    String curso,
    String seccion,
    String mes,
  ) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(curso)
        .collection('asistencia')
        .doc('mes_${mes}_$seccion');
  }

  // ============================================
  // REGISTRO DE MESES
  // ============================================

  /// Crear 10 meses consecutivos desde el mes inicial
  Future<List<Map<String, dynamic>>> crear10Meses(
    String mesInicial,
    String curso,
    String seccion,
  ) async {
    try {
      int mesIndex = mesesDelAnio.indexOf(mesInicial);
      if (mesIndex == -1) return [];

      List<Map<String, dynamic>> meses = [];
      for (int i = 0; i < 10; i++) {
        int indexActual = (mesIndex + i) % 12;
        meses.add({
          'mes': mesesDelAnio[indexActual],
          'materia': curso,
          'seccion': seccion,
        });
      }

      // Guardar en Firestore
      await _getRegistroMesesDoc(curso, seccion).set({
        'curso_id': curso,
        'seccion': seccion,
        'registros': meses,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad
      await _activityLog.log(
        action: 'create',
        entityType: 'registro_meses',
        entityId: 'registro_meses_$seccion',
        details: {
          'curso': curso,
          'seccion': seccion,
          'mes_inicial': mesInicial,
          'total_meses': 10,
        },
      );

      return meses;
    } catch (e) {
      return [];
    }
  }

  /// Obtener registros de meses de un curso y sección
  Future<List<Map<String, dynamic>>> obtenerRegistros(String curso, String seccion) async {
    try {
      final snapshot = await _getRegistroMesesDoc(curso, seccion).get();

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.data()!;
      return RegistroMeses.parseRegistros(data['registros']);
    } catch (e) {
      return [];
    }
  }

  /// Verificar si ya existen registros
  Future<bool> existenRegistros(String curso, String seccion) async {
    try {
      final snapshot = await _getRegistroMesesDoc(curso, seccion).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Limpiar registros de un curso y sección
  Future<void> limpiarRegistros(String curso, String seccion) async {
    try {
      await _getRegistroMesesDoc(curso, seccion).delete();
    } catch (e) {
      // Error al limpiar
    }
  }

  // ============================================
  // DATOS DE ASISTENCIA POR MES
  // ============================================

  /// Guardar datos completos de asistencia para un mes específico
  Future<bool> guardarDatosAsistencia({
    required String curso,
    required String seccion,
    required String mes,
    required List<List<String>> asistencia,
    required Map<int, String> feriados,
    required List<String> diasMes,
  }) async {
    try {
      await _getDatosAsistenciaDoc(curso, seccion, mes).set({
        'curso_id': curso,
        'seccion': seccion,
        'mes': mes,
        'asistencia': asistencia,
        'feriados': feriados.map((key, value) => MapEntry(key.toString(), value)),
        'dias_mes': diasMes,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'asistencia',
        entityId: 'mes_${mes}_$seccion',
        details: {
          'curso': curso,
          'seccion': seccion,
          'mes': mes,
          'total_estudiantes': asistencia.length,
          'total_dias': diasMes.length,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener datos completos de asistencia para un mes específico
  Future<Map<String, dynamic>?> obtenerDatosAsistencia({
    required String curso,
    required String seccion,
    required String mes,
  }) async {
    try {
      final snapshot = await _getDatosAsistenciaDoc(curso, seccion, mes).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;

      return {
        'asistencia': Asistencia.parseAsistencia(data['asistencia']),
        'feriados': Asistencia.parseFeriados(data['feriados']),
        'diasMes': Asistencia.parseDiasMes(data['dias_mes']),
      };
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // STREAMS EN TIEMPO REAL
  // ============================================

  /// Stream de registro de meses
  Stream<RegistroMeses?> registroMesesStream(String curso, String seccion) {
    return _getRegistroMesesDoc(curso, seccion).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return RegistroMeses.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  /// Stream de datos de asistencia de un mes específico
  Stream<Asistencia?> asistenciaMesStream(String curso, String seccion, String mes) {
    return _getDatosAsistenciaDoc(curso, seccion, mes).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return Asistencia.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Verificar si existen datos de asistencia para un mes
  Future<bool> existeDatosAsistenciaMes({
    required String curso,
    required String seccion,
    required String mes,
  }) async {
    try {
      final snapshot = await _getDatosAsistenciaDoc(curso, seccion, mes).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Obtener todos los meses con datos de asistencia para un curso
  Future<List<String>> obtenerMesesConDatos(String curso, String seccion) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('cursos')
          .doc(curso)
          .collection('asistencia')
          .where('curso_id', isEqualTo: curso)
          .where('seccion', isEqualTo: seccion)
          .get();

      final meses = <String>[];
      for (var doc in querySnapshot.docs) {
        if (doc.id.startsWith('mes_')) {
          // Extraer nombre del mes del ID del documento
          final parts = doc.id.split('_');
          if (parts.length >= 2) {
            meses.add(parts[1]);
          }
        }
      }

      return meses;
    } catch (e) {
      return [];
    }
  }

  /// Eliminar datos de asistencia de un mes específico
  Future<bool> eliminarDatosAsistenciaMes({
    required String curso,
    required String seccion,
    required String mes,
  }) async {
    try {
      await _getDatosAsistenciaDoc(curso, seccion, mes).delete();

      // Registrar actividad
      await _activityLog.log(
        action: 'delete',
        entityType: 'asistencia',
        entityId: 'mes_${mes}_$seccion',
        details: {
          'curso': curso,
          'seccion': seccion,
          'mes': mes,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
