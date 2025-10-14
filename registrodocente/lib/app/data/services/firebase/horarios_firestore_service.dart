import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth_service.dart';
import '../activity_log_service.dart';

/// Servicio de Horarios para Firestore
/// Gestiona la configuración del horario de clases del docente
///
/// Funcionalidades:
/// - Guardar/obtener configuración del horario
/// - Soporte para múltiples períodos con materias
/// - Soporte para recreos y almuerzos
/// - Soporte para alarmas por período
///
/// Estructura en Firestore:
/// users/{uid}/configuraciones/horario_clase
class HorariosFirestoreService {
  static final HorariosFirestoreService _instance = HorariosFirestoreService._internal();
  factory HorariosFirestoreService() => _instance;
  HorariosFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _currentUserId => _authService.currentUserId;

  // ============================================
  // REFERENCIAS A DOCUMENTOS
  // ============================================

  /// Referencia al documento de configuración del horario
  DocumentReference<Map<String, dynamic>> _getHorarioDoc() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('configuraciones')
        .doc('horario_clase');
  }

  // ============================================
  // CONFIGURACIÓN DEL HORARIO
  // ============================================

  /// Guardar configuración del horario (JSON string con todos los períodos)
  Future<bool> guardarConfiguracionHorario(String configuracionJson) async {
    try {
      await _getHorarioDoc().set({
        'configuracion': configuracionJson,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'horario_clase',
        entityId: 'configuracion',
        details: {
          'size': configuracionJson.length,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener configuración del horario
  Future<String?> obtenerConfiguracionHorario() async {
    try {
      final snapshot = await _getHorarioDoc().get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      return data['configuracion'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Eliminar configuración del horario
  Future<bool> eliminarConfiguracionHorario() async {
    try {
      await _getHorarioDoc().delete();

      // Registrar actividad
      await _activityLog.log(
        action: 'delete',
        entityType: 'horario_clase',
        entityId: 'configuracion',
        details: {},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si existe una configuración de horario
  Future<bool> existeConfiguracion() async {
    try {
      final snapshot = await _getHorarioDoc().get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // STREAM EN TIEMPO REAL
  // ============================================

  /// Stream de configuración del horario
  /// Permite actualización en tiempo real de cambios
  Stream<String?> configuracionHorarioStream() {
    return _getHorarioDoc().snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      return data?['configuracion'] as String?;
    });
  }
}
