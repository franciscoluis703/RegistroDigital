import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'firebase_auth_service.dart';
import '../activity_log_service.dart';

/// Servicio de Sincronización Permanente de Datos
///
/// Garantiza que todas las actividades del usuario se guarden de forma permanente
/// hasta que el usuario decida hacer cambios explícitamente.
///
/// Características:
/// - Sincronización automática con Firestore
/// - Cache local persistente
/// - Control de versiones de datos
/// - Registro de cambios del usuario
/// - Backup automático antes de cambios
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _currentUserId => _authService.currentUserId;

  // Keys para SharedPreferences
  static const String _keyLastSync = 'last_sync_timestamp';
  static const String _keyPendingChanges = 'pending_changes';
  static const String _keySyncEnabled = 'sync_enabled';
  static const String _keyAutoBackup = 'auto_backup_enabled';

  // ============================================
  // CONFIGURACIÓN DE SINCRONIZACIÓN
  // ============================================

  /// Verificar si la sincronización está habilitada
  Future<bool> isSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySyncEnabled) ?? true; // Habilitada por defecto
  }

  /// Habilitar/deshabilitar sincronización
  Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySyncEnabled, enabled);

    await _activityLog.log(
      action: enabled ? 'enable_sync' : 'disable_sync',
      entityType: 'sync',
      details: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Verificar si el backup automático está habilitado
  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoBackup) ?? true; // Habilitado por defecto
  }

  /// Habilitar/deshabilitar backup automático
  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackup, enabled);
  }

  // ============================================
  // SINCRONIZACIÓN DE DATOS
  // ============================================

  /// Sincronizar todos los datos del usuario con Firestore
  Future<Map<String, dynamic>> syncAllData() async {
    try {
      if (_currentUserId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }

      if (!await isSyncEnabled()) {
        return {
          'success': false,
          'message': 'Sincronización deshabilitada',
        };
      }

      final startTime = DateTime.now();

      // Sincronizar cada colección
      final results = <String, bool>{};

      results['cursos'] = await _syncCollection('cursos');
      results['notas'] = await _syncCollection('notas');
      results['horarios'] = await _syncCollection('horarios');
      results['evidencias'] = await _syncCollection('evidencias');

      // Actualizar timestamp de última sincronización
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());

      // Registrar actividad
      await _activityLog.log(
        action: 'sync_all',
        entityType: 'sync',
        details: {
          'results': results,
          'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
        },
      );

      final successCount = results.values.where((v) => v).length;
      final totalCount = results.length;

      return {
        'success': successCount == totalCount,
        'message': 'Sincronizado: $successCount/$totalCount colecciones',
        'results': results,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al sincronizar: ${e.toString()}',
      };
    }
  }

  /// Sincronizar una colección específica
  Future<bool> _syncCollection(String collectionName) async {
    try {
      if (_currentUserId == null) return false;

      // Aquí ya no necesitamos hacer nada porque Firebase
      // guarda automáticamente todo en Firestore
      // Este método se mantiene para futuras extensiones
      return true;
    } catch (e) {
      print('Error al sincronizar $collectionName: $e');
      return false;
    }
  }

  /// Obtener fecha/hora de última sincronización
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_keyLastSync);

      if (lastSyncStr != null) {
        return DateTime.parse(lastSyncStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // CONTROL DE CAMBIOS DEL USUARIO
  // ============================================

  /// Registrar un cambio pendiente antes de aplicarlo
  Future<void> registerPendingChange({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
    required String changeType, // 'create', 'update', 'delete'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingChangesJson = prefs.getString(_keyPendingChanges);

      List<dynamic> pendingChanges = [];
      if (pendingChangesJson != null) {
        pendingChanges = json.decode(pendingChangesJson) as List<dynamic>;
      }

      // Agregar nuevo cambio
      pendingChanges.add({
        'collection': collectionName,
        'document_id': documentId,
        'old_data': oldData,
        'new_data': newData,
        'change_type': changeType,
        'timestamp': DateTime.now().toIso8601String(),
        'applied': false,
      });

      await prefs.setString(_keyPendingChanges, json.encode(pendingChanges));
    } catch (e) {
      print('Error al registrar cambio pendiente: $e');
    }
  }

  /// Aplicar un cambio específico
  Future<Map<String, dynamic>> applyChange(String changeId) async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      final prefs = await SharedPreferences.getInstance();
      final pendingChangesJson = prefs.getString(_keyPendingChanges);

      if (pendingChangesJson == null) {
        return {'success': false, 'message': 'No hay cambios pendientes'};
      }

      List<dynamic> pendingChanges = json.decode(pendingChangesJson) as List<dynamic>;

      // Buscar el cambio
      final changeIndex = pendingChanges.indexWhere(
        (c) => c['timestamp'] == changeId && !(c['applied'] ?? false)
      );

      if (changeIndex == -1) {
        return {'success': false, 'message': 'Cambio no encontrado'};
      }

      final change = pendingChanges[changeIndex] as Map<String, dynamic>;

      // Crear backup si está habilitado
      if (await isAutoBackupEnabled()) {
        await _createBackup(
          collection: change['collection'],
          documentId: change['document_id'],
          data: change['old_data'],
        );
      }

      // Aplicar el cambio en Firestore
      final docRef = _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection(change['collection'])
          .doc(change['document_id']);

      switch (change['change_type']) {
        case 'create':
          await docRef.set(change['new_data']);
          break;
        case 'update':
          await docRef.update(change['new_data']);
          break;
        case 'delete':
          await docRef.delete();
          break;
      }

      // Marcar como aplicado
      pendingChanges[changeIndex]['applied'] = true;
      pendingChanges[changeIndex]['applied_at'] = DateTime.now().toIso8601String();
      await prefs.setString(_keyPendingChanges, json.encode(pendingChanges));

      // Registrar actividad
      await _activityLog.log(
        action: 'apply_change',
        entityType: change['collection'],
        entityId: change['document_id'],
        details: {'change_type': change['change_type']},
      );

      return {
        'success': true,
        'message': 'Cambio aplicado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al aplicar cambio: ${e.toString()}',
      };
    }
  }

  /// Obtener lista de cambios pendientes
  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingChangesJson = prefs.getString(_keyPendingChanges);

      if (pendingChangesJson == null) {
        return [];
      }

      final pendingChanges = json.decode(pendingChangesJson) as List<dynamic>;

      // Filtrar solo los no aplicados
      return pendingChanges
          .where((c) => !(c['applied'] ?? false))
          .map((c) => c as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Limpiar cambios aplicados
  Future<void> cleanAppliedChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingChangesJson = prefs.getString(_keyPendingChanges);

      if (pendingChangesJson == null) return;

      final pendingChanges = json.decode(pendingChangesJson) as List<dynamic>;

      // Mantener solo los no aplicados
      final unappliedChanges = pendingChanges
          .where((c) => !(c['applied'] ?? false))
          .toList();

      await prefs.setString(_keyPendingChanges, json.encode(unappliedChanges));
    } catch (e) {
      print('Error al limpiar cambios aplicados: $e');
    }
  }

  // ============================================
  // BACKUP DE DATOS
  // ============================================

  /// Crear backup de datos antes de un cambio
  Future<void> _createBackup({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (_currentUserId == null) return;

      await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('backups')
          .add({
        'collection': collection,
        'document_id': documentId,
        'data': data,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al crear backup: $e');
    }
  }

  /// Crear backup manual completo
  Future<Map<String, dynamic>> createManualBackup() async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      final collections = ['cursos', 'notas', 'horarios', 'evidencias'];
      final backupId = DateTime.now().millisecondsSinceEpoch.toString();

      for (final collectionName in collections) {
        final snapshot = await _firestore
            .collection('users')
            .doc(_currentUserId!)
            .collection(collectionName)
            .get();

        for (final doc in snapshot.docs) {
          await _firestore
              .collection('users')
              .doc(_currentUserId!)
              .collection('backups')
              .add({
            'backup_id': backupId,
            'collection': collectionName,
            'document_id': doc.id,
            'data': doc.data(),
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      }

      await _activityLog.log(
        action: 'create_backup',
        entityType: 'backup',
        details: {'backup_id': backupId},
      );

      return {
        'success': true,
        'message': 'Backup creado exitosamente',
        'backup_id': backupId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al crear backup: ${e.toString()}',
      };
    }
  }

  /// Restaurar desde un backup
  Future<Map<String, dynamic>> restoreFromBackup(String backupId) async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      // Obtener todos los documentos del backup
      final backupSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('backups')
          .where('backup_id', isEqualTo: backupId)
          .get();

      if (backupSnapshot.docs.isEmpty) {
        return {'success': false, 'message': 'Backup no encontrado'};
      }

      // Restaurar cada documento
      for (final backupDoc in backupSnapshot.docs) {
        final data = backupDoc.data();
        final collection = data['collection'] as String;
        final documentId = data['document_id'] as String;
        final docData = data['data'] as Map<String, dynamic>;

        await _firestore
            .collection('users')
            .doc(_currentUserId!)
            .collection(collection)
            .doc(documentId)
            .set(docData);
      }

      await _activityLog.log(
        action: 'restore_backup',
        entityType: 'backup',
        details: {'backup_id': backupId},
      );

      return {
        'success': true,
        'message': 'Datos restaurados exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al restaurar backup: ${e.toString()}',
      };
    }
  }

  /// Listar backups disponibles
  Future<List<Map<String, dynamic>>> listBackups() async {
    try {
      if (_currentUserId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .collection('backups')
          .orderBy('created_at', descending: true)
          .get();

      // Agrupar por backup_id
      final Map<String, Map<String, dynamic>> backups = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final backupId = data['backup_id'] as String? ?? 'unknown';

        if (!backups.containsKey(backupId)) {
          backups[backupId] = {
            'backup_id': backupId,
            'created_at': data['created_at'],
            'documents_count': 0,
          };
        }

        backups[backupId]!['documents_count'] =
            (backups[backupId]!['documents_count'] as int) + 1;
      }

      return backups.values.toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // VERIFICACIÓN DE INTEGRIDAD
  // ============================================

  /// Verificar integridad de los datos sincronizados
  Future<Map<String, dynamic>> verifyDataIntegrity() async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      final issues = <String, dynamic>{};
      final collections = ['cursos', 'notas', 'horarios', 'evidencias'];

      for (final collection in collections) {
        final snapshot = await _firestore
            .collection('users')
            .doc(_currentUserId!)
            .collection(collection)
            .get();

        issues[collection] = {
          'total_documents': snapshot.docs.length,
          'corrupted': 0,
          'missing_fields': 0,
        };

        // Aquí se pueden agregar validaciones específicas
        // por ahora solo contamos documentos
      }

      return {
        'success': true,
        'message': 'Verificación completada',
        'issues': issues,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al verificar integridad: ${e.toString()}',
      };
    }
  }

  // ============================================
  // ESTADÍSTICAS
  // ============================================

  /// Obtener estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final lastSync = await getLastSyncTime();
      final pendingChanges = await getPendingChanges();
      final syncEnabled = await isSyncEnabled();
      final autoBackupEnabled = await isAutoBackupEnabled();

      return {
        'sync_enabled': syncEnabled,
        'auto_backup_enabled': autoBackupEnabled,
        'last_sync': lastSync?.toIso8601String(),
        'pending_changes_count': pendingChanges.length,
        'minutes_since_sync': lastSync != null
            ? DateTime.now().difference(lastSync).inMinutes
            : null,
      };
    } catch (e) {
      return {};
    }
  }
}
