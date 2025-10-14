import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para registrar todas las actividades del usuario
/// Crea un historial completo de acciones para auditoría en Firestore
class ActivityLogService {
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtener el ID del usuario actual directamente desde FirebaseAuth
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Registrar una actividad del usuario
  Future<void> log({
    required String action,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return; // Sin usuario autenticado, no registrar
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activity_logs')
          .add({
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // No lanzar excepción para no interrumpir el flujo de la app
    }
  }

  /// Obtener logs de actividad del usuario actual
  Future<List<Map<String, dynamic>>> getUserLogs({
    int? limit = 100,
    String? entityType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      // Construir query base
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('activity_logs')
          .orderBy('timestamp', descending: true);

      // Aplicar filtros opcionales
      if (entityType != null) {
        query = query.where('entity_type', isEqualTo: entityType);
      }

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      // Aplicar límite
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener estadísticas de actividad del usuario
  Future<Map<String, dynamic>> getActivityStats() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return {};
      }

      final logs = await getUserLogs(limit: 1000);

      // Contar acciones por tipo
      final Map<String, int> actionCounts = {};
      final Map<String, int> entityCounts = {};

      for (var log in logs) {
        final action = log['action'] as String?;
        final entityType = log['entity_type'] as String?;

        if (action != null) {
          actionCounts[action] = (actionCounts[action] ?? 0) + 1;
        }
        if (entityType != null) {
          entityCounts[entityType] = (entityCounts[entityType] ?? 0) + 1;
        }
      }

      return {
        'total_activities': logs.length,
        'actions': actionCounts,
        'entities': entityCounts,
        'last_activity': logs.isNotEmpty ? logs.first['timestamp'] : null,
      };
    } catch (e) {
      return {};
    }
  }

  /// Limpiar logs antiguos (opcional, para mantenimiento)
  Future<void> cleanOldLogs({int daysToKeep = 90}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      // Obtener logs antiguos
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activity_logs')
          .where('timestamp', isLessThan: cutoffDate)
          .get();

      // Eliminar en batch
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Error al limpiar logs
    }
  }
}
