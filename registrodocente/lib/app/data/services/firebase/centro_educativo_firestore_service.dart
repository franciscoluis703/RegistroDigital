import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth_service.dart';
import '../activity_log_service.dart';

/// Servicio de Datos del Centro Educativo para Firestore
/// Reemplazo completo de CentroEducativoService (Supabase)
///
/// Funcionalidades:
/// - Guardar y obtener datos del centro educativo
/// - Información del director y docente encargado
/// - Datos de ubicación y clasificación
///
/// Estructura en Firestore:
/// users/{uid}/configuracion/centro_educativo
class CentroEducativoFirestoreService {
  static final CentroEducativoFirestoreService _instance = CentroEducativoFirestoreService._internal();
  factory CentroEducativoFirestoreService() => _instance;
  CentroEducativoFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _currentUserId => _authService.currentUserId;

  // ============================================
  // REFERENCIA A DOCUMENTO
  // ============================================

  /// Referencia al documento de centro educativo del usuario
  DocumentReference<Map<String, dynamic>> _getCentroDoc() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('configuracion')
        .doc('centro_educativo');
  }

  // ============================================
  // CRUD DE DATOS DEL CENTRO
  // ============================================

  /// Guardar datos del centro educativo
  Future<bool> guardarDatosCentro(Map<String, dynamic> datos) async {
    try {
      await _getCentroDoc().set({
        ...datos,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'centro_educativo',
        entityId: 'centro_educativo',
        details: {
          'nombre_centro': datos['nombre_centro'] ?? '',
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener datos del centro educativo
  Future<Map<String, dynamic>?> obtenerDatosCentro() async {
    try {
      final snapshot = await _getCentroDoc().get();

      if (!snapshot.exists) {
        return null;
      }

      return snapshot.data();
    } catch (e) {
      return null;
    }
  }

  /// Actualizar un campo específico
  Future<bool> actualizarCampo(String campo, dynamic valor) async {
    try {
      await _getCentroDoc().update({
        campo: valor,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // MÉTODOS ESPECÍFICOS
  // ============================================

  /// Obtener nombre del centro
  Future<String?> obtenerNombreCentro() async {
    try {
      final datos = await obtenerDatosCentro();
      return datos?['nombre_centro'];
    } catch (e) {
      return null;
    }
  }

  /// Obtener información del director
  Future<Map<String, String>?> obtenerInfoDirector() async {
    try {
      final datos = await obtenerDatosCentro();
      if (datos == null) return null;

      return {
        'nombre': datos['director_nombre'] ?? '',
        'correo': datos['director_correo'] ?? '',
        'telefono': datos['director_telefono'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  /// Obtener información del docente encargado
  Future<Map<String, String>?> obtenerInfoDocente() async {
    try {
      final datos = await obtenerDatosCentro();
      if (datos == null) return null;

      return {
        'nombre': datos['docente_nombre'] ?? '',
        'correo': datos['docente_correo'] ?? '',
        'telefono': datos['docente_telefono'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // STREAMS EN TIEMPO REAL
  // ============================================

  /// Stream de datos del centro educativo
  Stream<Map<String, dynamic>?> centroEducativoStream() {
    return _getCentroDoc().snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Verificar si existen datos del centro
  Future<bool> existenDatosCentro() async {
    try {
      final snapshot = await _getCentroDoc().get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Limpiar datos del centro (usar con precaución)
  Future<bool> limpiarDatosCentro() async {
    try {
      await _getCentroDoc().delete();

      // Registrar actividad
      await _activityLog.log(
        action: 'delete',
        entityType: 'centro_educativo',
        entityId: 'centro_educativo',
        details: {},
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
