import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/estudiante.dart';
import 'firebase_auth_service.dart';
import '../activity_log_service.dart';

/// Servicio de Estudiantes para Firestore
/// Reemplazo completo de EstudiantesSupabaseService
///
/// Funcionalidades:
/// - CRUD de estudiantes por curso
/// - Gestión de número de orden
/// - Búsqueda por nombre
/// - Sincronización en tiempo real
/// - Datos generales, emergencias, parentesco, condición inicial
///
/// Estructura en Firestore:
/// users/{uid}/cursos/{cursoId}/estudiantes/{estudianteId}
class EstudiantesFirestoreService {
  static final EstudiantesFirestoreService _instance = EstudiantesFirestoreService._internal();
  factory EstudiantesFirestoreService() => _instance;
  EstudiantesFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ActivityLogService _activityLog = ActivityLogService();
  final Uuid _uuid = const Uuid();

  String? get _currentUserId => _authService.currentUserId;

  // ============================================
  // REFERENCIA A LA COLECCIÓN
  // ============================================

  /// Obtener referencia a la colección de estudiantes de un curso
  CollectionReference<Map<String, dynamic>> _getEstudiantesCollection(String cursoId) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(cursoId)
        .collection('estudiantes');
  }

  // ============================================
  // CRUD DE ESTUDIANTES
  // ============================================

  /// Obtener todos los estudiantes de un curso
  Future<List<Estudiante>> obtenerEstudiantes(String cursoId) async {
    try {
      final querySnapshot = await _getEstudiantesCollection(cursoId)
          .orderBy('numero_orden', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Estudiante.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Crear un nuevo estudiante
  Future<Estudiante?> crearEstudiante({
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
      final estudianteId = _uuid.v4();

      final estudiante = Estudiante(
        id: estudianteId,
        cursoId: cursoId,
        nombre: nombre,
        apellido: apellido,
        sexo: sexo,
        fechaNacimiento: fechaNacimiento,
        edad: edad,
        cedula: cedula,
        rne: rne,
        lugarResidencia: lugarResidencia,
        provincia: provincia,
        municipio: municipio,
        sector: sector,
        correoElectronico: correoElectronico,
        telefono: telefono,
        centroEducativo: centroEducativo,
        regional: regional,
        distrito: distrito,
        repiteGrado: repiteGrado,
        nuevoIngreso: nuevoIngreso,
        promovido: promovido,
        contactoEmergenciaNombre: contactoEmergenciaNombre,
        contactoEmergenciaTelefono: contactoEmergenciaTelefono,
        contactoEmergenciaParentesco: contactoEmergenciaParentesco,
        seccion: seccion,
        numeroOrden: numeroOrden ?? 0,
        fotoUrl: fotoUrl,
        observaciones: observaciones,
        createdAt: DateTime.now(),
      );

      final docRef = _getEstudiantesCollection(cursoId).doc(estudianteId);
      final data = estudiante.toFirestore();
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();

      await docRef.set(data);

      // Registrar actividad
      await _activityLog.log(
        action: 'create',
        entityType: 'estudiante',
        entityId: estudianteId,
        details: {'nombre': nombre, 'curso_id': cursoId},
      );

      final snapshot = await docRef.get();
      return Estudiante.fromFirestore(snapshot.data()!, snapshot.id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener estudiante por ID
  Future<Estudiante?> obtenerEstudiantePorId(String cursoId, String estudianteId) async {
    try {
      final snapshot = await _getEstudiantesCollection(cursoId)
          .doc(estudianteId)
          .get();

      if (!snapshot.exists) {
        return null;
      }

      return Estudiante.fromFirestore(snapshot.data()!, snapshot.id);
    } catch (e) {
      return null;
    }
  }

  /// Actualizar un estudiante
  Future<bool> actualizarEstudiante(
    String cursoId,
    String estudianteId,
    Map<String, dynamic> datos,
  ) async {
    try {
      datos['updated_at'] = FieldValue.serverTimestamp();

      await _getEstudiantesCollection(cursoId)
          .doc(estudianteId)
          .update(datos);

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'estudiante',
        entityId: estudianteId,
        details: datos,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar un estudiante
  Future<bool> eliminarEstudiante(String cursoId, String estudianteId) async {
    try {
      await _getEstudiantesCollection(cursoId)
          .doc(estudianteId)
          .delete();

      // Registrar actividad
      await _activityLog.log(
        action: 'delete',
        entityType: 'estudiante',
        entityId: estudianteId,
        details: {'curso_id': cursoId},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // BÚSQUEDA Y FILTRADO
  // ============================================

  /// Buscar estudiantes por nombre
  Future<List<Estudiante>> buscarEstudiantesPorNombre(
    String cursoId,
    String nombre,
  ) async {
    try {
      // Firestore no soporta LIKE/ILIKE directamente
      // Obtenemos todos y filtramos en cliente
      final estudiantes = await obtenerEstudiantes(cursoId);

      return estudiantes.where((e) {
        final nombreCompleto = e.nombreCompleto.toLowerCase();
        return nombreCompleto.contains(nombre.toLowerCase());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener solo los nombres de estudiantes
  Future<List<String>> obtenerNombresEstudiantes(String cursoId) async {
    try {
      final estudiantes = await obtenerEstudiantes(cursoId);
      return estudiantes.map((e) => e.nombreCompleto).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener cantidad de estudiantes de un curso
  Future<int> obtenerCantidadEstudiantes(String cursoId) async {
    try {
      final querySnapshot = await _getEstudiantesCollection(cursoId).get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // ============================================
  // GESTIÓN DE ORDEN
  // ============================================

  /// Actualizar número de orden masivamente
  Future<bool> actualizarOrdenEstudiantes(
    String cursoId,
    Map<String, int> estudianteIdOrden,
  ) async {
    try {
      final batch = _firestore.batch();

      for (var entry in estudianteIdOrden.entries) {
        final docRef = _getEstudiantesCollection(cursoId).doc(entry.key);
        batch.update(docRef, {
          'numero_orden': entry.value,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // STREAMS EN TIEMPO REAL
  // ============================================

  /// Stream de todos los estudiantes de un curso
  Stream<List<Estudiante>> estudiantesStream(String cursoId) {
    return _getEstudiantesCollection(cursoId)
        .orderBy('numero_orden', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Estudiante.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream de un estudiante específico
  Stream<Estudiante?> estudianteStream(String cursoId, String estudianteId) {
    return _getEstudiantesCollection(cursoId)
        .doc(estudianteId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return Estudiante.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  // ============================================
  // DATOS GENERALES (Tabla estilo hoja de cálculo)
  // ============================================

  /// Referencia a colección de datos generales
  DocumentReference<Map<String, dynamic>> _getDatosGeneralesDoc(String cursoId) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(cursoId)
        .collection('datos_complementarios')
        .doc('datos_generales');
  }

  /// Guardar datos generales de estudiantes
  Future<bool> guardarDatosGenerales({
    required String cursoId,
    required List<String> nombres,
    required List<Map<String, String>> camposAdicionales,
  }) async {
    try {
      await _getDatosGeneralesDoc(cursoId).set({
        'nombres': nombres,
        'campos_adicionales': camposAdicionales,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener datos generales de estudiantes
  Future<Map<String, dynamic>?> obtenerDatosGenerales(String cursoId) async {
    try {
      final snapshot = await _getDatosGeneralesDoc(cursoId).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      return {
        'nombres': (data['nombres'] as List).map((e) => e.toString()).toList(),
        'camposAdicionales': (data['campos_adicionales'] as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList(),
      };
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // CONDICIÓN INICIAL
  // ============================================

  DocumentReference<Map<String, dynamic>> _getCondicionInicialDoc(String cursoId) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(cursoId)
        .collection('datos_complementarios')
        .doc('condicion_inicial');
  }

  /// Guardar condición inicial de estudiantes
  Future<bool> guardarCondicionInicial({
    required String cursoId,
    required List<Map<String, dynamic>> condiciones,
  }) async {
    try {
      await _getCondicionInicialDoc(cursoId).set({
        'condiciones': condiciones,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener condición inicial de estudiantes
  Future<List<Map<String, dynamic>>?> obtenerCondicionInicial(String cursoId) async {
    try {
      final snapshot = await _getCondicionInicialDoc(cursoId).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      return (data['condiciones'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // DATOS DE EMERGENCIAS
  // ============================================

  DocumentReference<Map<String, dynamic>> _getDatosEmergenciasDoc(String cursoId) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(cursoId)
        .collection('datos_complementarios')
        .doc('datos_emergencias');
  }

  /// Guardar datos de emergencias de estudiantes
  Future<bool> guardarDatosEmergencias({
    required String cursoId,
    required List<Map<String, String>> emergencias,
  }) async {
    try {
      await _getDatosEmergenciasDoc(cursoId).set({
        'emergencias': emergencias,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener datos de emergencias de estudiantes
  Future<List<Map<String, String>>?> obtenerDatosEmergencias(String cursoId) async {
    try {
      final snapshot = await _getDatosEmergenciasDoc(cursoId).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      return (data['emergencias'] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // DATOS DE PARENTESCO
  // ============================================

  DocumentReference<Map<String, dynamic>> _getDatosParentescoDoc(String cursoId) {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('cursos')
        .doc(cursoId)
        .collection('datos_complementarios')
        .doc('parentesco');
  }

  /// Guardar datos de parentesco de estudiantes
  Future<bool> guardarDatosParentesco({
    required String cursoId,
    required List<Map<String, String>> parentescos,
  }) async {
    try {
      await _getDatosParentescoDoc(cursoId).set({
        'parentescos': parentescos,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener datos de parentesco de estudiantes
  Future<List<Map<String, String>>?> obtenerDatosParentesco(String cursoId) async {
    try {
      final snapshot = await _getDatosParentescoDoc(cursoId).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      return (data['parentescos'] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Convertir lista de estudiantes a formato Map (compatibilidad con UI antigua)
  Future<List<Map<String, dynamic>>> obtenerEstudiantesComoMaps(String cursoId) async {
    final estudiantes = await obtenerEstudiantes(cursoId);
    return estudiantes.map((e) => e.toMap()).toList();
  }
}
