import 'package:cloud_firestore/cloud_firestore.dart';
import '../activity_log_service.dart';

/// Servicio Base de Firestore
/// Proporciona operaciones CRUD genéricas para todas las colecciones
///
/// Patrón de uso:
/// - Todas las colecciones siguen el patrón: users/{uid}/collection/{docId}
/// - Aislamiento de datos por usuario
/// - Sincronización automática en tiempo real
/// - Soporte offline con persistencia local
abstract class FirestoreBaseService<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivityLogService _activityLog = ActivityLogService();

  /// Nombre de la colección (ej: 'cursos', 'estudiantes', 'evidencias')
  String get collectionName;

  /// ID del usuario actual (debe ser proporcionado por auth_service)
  String? get currentUserId;

  /// Convertir documento de Firestore a modelo
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot);

  /// Convertir modelo a Map para Firestore
  Map<String, dynamic> toFirestore(T item);

  // ============================================
  // REFERENCIA A LA COLECCIÓN DEL USUARIO
  // ============================================

  /// Obtener referencia a la colección del usuario actual
  /// Patrón: users/{uid}/{collectionName}
  CollectionReference<Map<String, dynamic>> _getUserCollection() {
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(currentUserId!)
        .collection(collectionName);
  }

  // ============================================
  // OPERACIONES CRUD
  // ============================================

  /// Crear un nuevo documento
  Future<T?> create({
    required String id,
    required T item,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final docRef = _getUserCollection().doc(id);
      final data = toFirestore(item);

      // Agregar timestamps automáticos
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();

      // Agregar datos extra si existen
      if (extraData != null) {
        data.addAll(extraData);
      }

      await docRef.set(data);

      // Registrar actividad
      await _activityLog.log(
        action: 'create',
        entityType: collectionName,
        entityId: id,
        details: {'item': data},
      );

      // Obtener el documento creado
      final snapshot = await docRef.get();
      return fromFirestore(snapshot);
    } catch (e) {
      return null;
    }
  }

  /// Obtener un documento por ID
  Future<T?> getById(String id) async {
    try {
      final snapshot = await _getUserCollection().doc(id).get();

      if (!snapshot.exists) {
        return null;
      }

      return fromFirestore(snapshot);
    } catch (e) {
      return null;
    }
  }

  /// Obtener todos los documentos de la colección
  Future<List<T>> getAll() async {
    try {
      final querySnapshot = await _getUserCollection().get();

      return querySnapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener documentos con filtro
  /// Ejemplo: getWhere('curso_id', isEqualTo: 'abc123')
  Future<List<T>> getWhere(
    String field, {
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic>? arrayContainsAny,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _getUserCollection();

      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isNotEqualTo != null) {
        query = query.where(field, isNotEqualTo: isNotEqualTo);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (isLessThanOrEqualTo != null) {
        query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (isGreaterThanOrEqualTo != null) {
        query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
      }
      if (arrayContains != null) {
        query = query.where(field, arrayContains: arrayContains);
      }
      if (arrayContainsAny != null) {
        query = query.where(field, arrayContainsAny: arrayContainsAny);
      }
      if (whereIn != null) {
        query = query.where(field, whereIn: whereIn);
      }
      if (whereNotIn != null) {
        query = query.where(field, whereNotIn: whereNotIn);
      }
      if (isNull != null) {
        query = query.where(field, isNull: isNull);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Actualizar un documento
  Future<bool> update({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final docRef = _getUserCollection().doc(id);

      // Agregar timestamp de actualización
      updates['updated_at'] = FieldValue.serverTimestamp();

      await docRef.update(updates);

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: collectionName,
        entityId: id,
        details: updates,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar un documento
  Future<bool> delete(String id) async {
    try {
      await _getUserCollection().doc(id).delete();

      // Registrar actividad
      await _activityLog.log(
        action: 'delete',
        entityType: collectionName,
        entityId: id,
        details: {},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar múltiples documentos que cumplan una condición
  Future<int> deleteWhere(
    String field, {
    dynamic isEqualTo,
  }) async {
    try {
      final query = _getUserCollection().where(field, isEqualTo: isEqualTo);
      final querySnapshot = await query.get();

      int deletedCount = 0;
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  // ============================================
  // OPERACIONES EN TIEMPO REAL
  // ============================================

  /// Stream para escuchar cambios en todos los documentos
  Stream<List<T>> streamAll() {
    return _getUserCollection().snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream para escuchar cambios en un documento específico
  Stream<T?> streamById(String id) {
    return _getUserCollection().doc(id).snapshots().map(
          (snapshot) {
            if (!snapshot.exists) return null;
            return fromFirestore(snapshot);
          },
        );
  }

  /// Stream con filtros
  Stream<List<T>> streamWhere(
    String field, {
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
  }) {
    Query<Map<String, dynamic>> query = _getUserCollection();

    if (isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }
    if (isNotEqualTo != null) {
      query = query.where(field, isNotEqualTo: isNotEqualTo);
    }
    if (isLessThan != null) {
      query = query.where(field, isLessThan: isLessThan);
    }
    if (isLessThanOrEqualTo != null) {
      query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) {
      query = query.where(field, isGreaterThan: isGreaterThan);
    }
    if (isGreaterThanOrEqualTo != null) {
      query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => fromFirestore(doc))
              .toList(),
        );
  }

  // ============================================
  // OPERACIONES POR LOTES (BATCH)
  // ============================================

  /// Crear múltiples documentos en una sola transacción
  Future<bool> createBatch(List<Map<String, dynamic>> items) async {
    try {
      final batch = _firestore.batch();

      for (var itemData in items) {
        final id = itemData['id'] as String;
        final docRef = _getUserCollection().doc(id);

        itemData['created_at'] = FieldValue.serverTimestamp();
        itemData['updated_at'] = FieldValue.serverTimestamp();

        batch.set(docRef, itemData);
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Actualizar múltiples documentos en una sola transacción
  Future<bool> updateBatch(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();

      for (var updateData in updates) {
        final id = updateData['id'] as String;
        final docRef = _getUserCollection().doc(id);

        updateData['updated_at'] = FieldValue.serverTimestamp();
        updateData.remove('id'); // No actualizar el ID

        batch.update(docRef, updateData);
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar múltiples documentos en una sola transacción
  Future<bool> deleteBatch(List<String> ids) async {
    try {
      final batch = _firestore.batch();

      for (var id in ids) {
        final docRef = _getUserCollection().doc(id);
        batch.delete(docRef);
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Contar documentos en la colección
  Future<int> count() async {
    try {
      final querySnapshot = await _getUserCollection().get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Verificar si existe un documento
  Future<bool> exists(String id) async {
    try {
      final snapshot = await _getUserCollection().doc(id).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Ordenar resultados
  Future<List<T>> getAllOrdered(
    String field, {
    bool descending = false,
  }) async {
    try {
      final querySnapshot = await _getUserCollection()
          .orderBy(field, descending: descending)
          .get();

      return querySnapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener con límite
  Future<List<T>> getAllLimited(int limit) async {
    try {
      final querySnapshot = await _getUserCollection().limit(limit).get();

      return querySnapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
