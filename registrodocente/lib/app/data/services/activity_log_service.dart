import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

/// Servicio para registrar todas las actividades del usuario
/// Crea un historial completo de acciones para auditoría
class ActivityLogService {
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener el ID del usuario actual
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Registrar una actividad del usuario
  Future<void> log({
    required String action,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    try {
      if (_currentUserId == null) {
        print('Warning: Intentando registrar log sin usuario autenticado');
        return;
      }

      await _supabase.from('user_activity_logs').insert({
        'user_id': _currentUserId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details != null ? json.encode(details) : null,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al registrar log de actividad: $e');
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
      if (_currentUserId == null) {
        return [];
      }

      // Construir query base
      dynamic query = _supabase
          .from('user_activity_logs')
          .select()
          .eq('user_id', _currentUserId!);

      // Aplicar filtros opcionales
      if (entityType != null) {
        query = query.eq('entity_type', entityType);
      }

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      // Aplicar ordenamiento y límite al final
      query = query.order('timestamp', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error al obtener logs: $e');
      return [];
    }
  }

  /// Obtener estadísticas de actividad del usuario
  Future<Map<String, dynamic>> getActivityStats() async {
    try {
      if (_currentUserId == null) {
        return {};
      }

      final logs = await getUserLogs(limit: null);

      // Contar acciones por tipo
      final Map<String, int> actionCounts = {};
      final Map<String, int> entityCounts = {};

      for (var log in logs) {
        final action = log['action'] as String;
        final entityType = log['entity_type'] as String;

        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
        entityCounts[entityType] = (entityCounts[entityType] ?? 0) + 1;
      }

      return {
        'total_activities': logs.length,
        'actions': actionCounts,
        'entities': entityCounts,
        'last_activity': logs.isNotEmpty ? logs.first['timestamp'] : null,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {};
    }
  }

  /// Limpiar logs antiguos (opcional, para mantenimiento)
  Future<void> cleanOldLogs({int daysToKeep = 90}) async {
    try {
      if (_currentUserId == null) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await _supabase
          .from('user_activity_logs')
          .delete()
          .eq('user_id', _currentUserId!)
          .lt('timestamp', cutoffDate.toIso8601String());
    } catch (e) {
      print('Error al limpiar logs antiguos: $e');
    }
  }
}
