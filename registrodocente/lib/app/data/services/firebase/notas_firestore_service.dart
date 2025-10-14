import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth_service.dart';
import '../activity_log_service.dart';

/// Servicio de Notas para Firestore
/// Reemplazo completo de NotasService (Supabase)
///
/// Funcionalidades:
/// - Crear, leer, actualizar y eliminar notas
/// - Sincronización en tiempo real
/// - Formato timestamp automático
///
/// Estructura en Firestore:
/// users/{uid}/notas/{notaId}
class NotasFirestoreService {
  static final NotasFirestoreService _instance = NotasFirestoreService._internal();
  factory NotasFirestoreService() => _instance;
  NotasFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _currentUserId => _authService.currentUserId;

  // ============================================
  // REFERENCIA A COLECCIÓN
  // ============================================

  /// Referencia a la colección de notas del usuario
  CollectionReference<Map<String, dynamic>> _getNotasCollection() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('notas');
  }

  // ============================================
  // CRUD DE NOTAS
  // ============================================

  /// Crear una nueva nota
  Future<String> crearNota(String titulo, String contenido) async {
    try {
      final docRef = await _getNotasCollection().add({
        'titulo': titulo,
        'contenido': contenido,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad
      await _activityLog.log(
        action: 'create',
        entityType: 'nota',
        entityId: docRef.id,
        details: {
          'titulo': titulo,
        },
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear nota: $e');
    }
  }

  /// Obtener todas las notas del usuario
  Future<List<Map<String, dynamic>>> obtenerNotas() async {
    try {
      final snapshot = await _getNotasCollection()
          .orderBy('updated_at', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'titulo': data['titulo'] ?? '',
          'contenido': data['contenido'] ?? '',
          'created_at': _timestampToString(data['created_at']),
          'updated_at': _timestampToString(data['updated_at']),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener una nota específica por ID
  Future<Map<String, dynamic>?> obtenerNotaPorId(String notaId) async {
    try {
      final doc = await _getNotasCollection().doc(notaId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return {
        'id': doc.id,
        'titulo': data['titulo'] ?? '',
        'contenido': data['contenido'] ?? '',
        'created_at': _timestampToString(data['created_at']),
        'updated_at': _timestampToString(data['updated_at']),
      };
    } catch (e) {
      return null;
    }
  }

  /// Actualizar una nota existente
  Future<void> actualizarNota(String notaId, String titulo, String contenido) async {
    try {
      await _getNotasCollection().doc(notaId).update({
        'titulo': titulo,
        'contenido': contenido,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'nota',
        entityId: notaId,
        details: {
          'titulo': titulo,
        },
      );
    } catch (e) {
      throw Exception('Error al actualizar nota: $e');
    }
  }

  /// Eliminar una nota
  Future<void> eliminarNota(String notaId) async {
    try {
      await _getNotasCollection().doc(notaId).delete();

      // Registrar actividad
      await _activityLog.log(
        action: 'delete',
        entityType: 'nota',
        entityId: notaId,
        details: {},
      );
    } catch (e) {
      throw Exception('Error al eliminar nota: $e');
    }
  }

  // ============================================
  // STREAMS EN TIEMPO REAL
  // ============================================

  /// Stream de todas las notas del usuario
  Stream<List<Map<String, dynamic>>> notasStream() {
    return _getNotasCollection()
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'titulo': data['titulo'] ?? '',
          'contenido': data['contenido'] ?? '',
          'created_at': _timestampToString(data['created_at']),
          'updated_at': _timestampToString(data['updated_at']),
        };
      }).toList();
    });
  }

  /// Stream de una nota específica
  Stream<Map<String, dynamic>?> notaStream(String notaId) {
    return _getNotasCollection().doc(notaId).snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data()!;
      return {
        'id': doc.id,
        'titulo': data['titulo'] ?? '',
        'contenido': data['contenido'] ?? '',
        'created_at': _timestampToString(data['created_at']),
        'updated_at': _timestampToString(data['updated_at']),
      };
    });
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Convertir Timestamp de Firestore a String ISO 8601
  String? _timestampToString(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate().toIso8601String();
    }
    return null;
  }

  /// Buscar notas por texto (título o contenido)
  Future<List<Map<String, dynamic>>> buscarNotas(String query) async {
    try {
      if (query.isEmpty) {
        return obtenerNotas();
      }

      final snapshot = await _getNotasCollection().get();

      final queryLower = query.toLowerCase();
      final resultados = snapshot.docs.where((doc) {
        final data = doc.data();
        final titulo = (data['titulo'] ?? '').toLowerCase();
        final contenido = (data['contenido'] ?? '').toLowerCase();
        return titulo.contains(queryLower) || contenido.contains(queryLower);
      }).map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'titulo': data['titulo'] ?? '',
          'contenido': data['contenido'] ?? '',
          'created_at': _timestampToString(data['created_at']),
          'updated_at': _timestampToString(data['updated_at']),
        };
      }).toList();

      // Ordenar por fecha de actualización
      resultados.sort((a, b) {
        final dateA = DateTime.tryParse(a['updated_at'] ?? '');
        final dateB = DateTime.tryParse(b['updated_at'] ?? '');
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      return resultados;
    } catch (e) {
      return [];
    }
  }

  /// Contar total de notas del usuario
  Future<int> contarNotas() async {
    try {
      final snapshot = await _getNotasCollection().get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
