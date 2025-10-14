import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/curso.dart';
import 'firestore_base_service.dart';
import 'firebase_auth_service.dart';

/// Servicio de Cursos para Firestore
/// Reemplazo completo de CursosSupabaseService
///
/// Funcionalidades:
/// - CRUD de cursos
/// - Gestión de secciones
/// - Ocultar/mostrar cursos
/// - Establecer curso activo
/// - Sincronización en tiempo real
class CursosFirestoreService extends FirestoreBaseService<Curso> {
  static final CursosFirestoreService _instance = CursosFirestoreService._internal();
  factory CursosFirestoreService() => _instance;
  CursosFirestoreService._internal();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final Uuid _uuid = const Uuid();

  @override
  String get collectionName => 'cursos';

  @override
  String? get currentUserId => _authService.currentUserId;

  @override
  Curso fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Curso.fromFirestore(data, snapshot.id);
  }

  @override
  Map<String, dynamic> toFirestore(Curso curso) {
    return curso.toFirestore();
  }

  // ============================================
  // OPERACIONES DE CURSOS
  // ============================================

  /// Obtener todos los cursos del usuario actual
  /// Ordenados por fecha de creación (más recientes primero)
  Future<List<Curso>> obtenerCursos() async {
    try {
      return await getAllOrdered('created_at', descending: true);
    } catch (e) {
      return [];
    }
  }

  /// Crear un nuevo curso
  Future<Curso?> crearCurso({
    required String nombre,
    required String asignatura,
    List<String> secciones = const ['A'],
    bool oculto = false,
  }) async {
    try {
      final cursoId = _uuid.v4();

      final curso = Curso(
        id: cursoId,
        nombre: nombre,
        asignatura: asignatura,
        secciones: secciones,
        oculto: oculto,
        activo: false,
        createdAt: DateTime.now(),
      );

      return await create(
        id: cursoId,
        item: curso,
      );
    } catch (e) {
      return null;
    }
  }

  /// Actualizar un curso
  Future<bool> actualizarCurso(String cursoId, Map<String, dynamic> datos) async {
    try {
      return await update(
        id: cursoId,
        updates: datos,
      );
    } catch (e) {
      return false;
    }
  }

  /// Eliminar un curso
  Future<bool> eliminarCurso(String cursoId) async {
    try {
      return await delete(cursoId);
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // GESTIÓN DE VISIBILIDAD
  // ============================================

  /// Ocultar/mostrar curso
  Future<bool> toggleOcultarCurso(String cursoId, bool oculto) async {
    try {
      return await update(
        id: cursoId,
        updates: {'oculto': oculto},
      );
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // GESTIÓN DE CURSO ACTIVO
  // ============================================

  /// Establecer curso activo
  /// Desactiva todos los demás cursos del usuario
  Future<bool> establecerCursoActivo(String cursoId) async {
    try {
      if (currentUserId == null) return false;

      final batch = FirebaseFirestore.instance.batch();

      // Obtener todos los cursos del usuario
      final cursosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId!)
          .collection(collectionName);

      final todosLosCursos = await cursosRef.get();

      // Desactivar todos los cursos
      for (var doc in todosLosCursos.docs) {
        batch.update(doc.reference, {'activo': false});
      }

      // Activar el curso seleccionado
      final cursoRef = cursosRef.doc(cursoId);
      batch.update(cursoRef, {
        'activo': true,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener curso activo
  Future<Curso?> obtenerCursoActivo() async {
    try {
      final cursos = await getWhere('activo', isEqualTo: true);

      if (cursos.isEmpty) {
        return null;
      }

      return cursos.first;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // GESTIÓN DE SECCIONES
  // ============================================

  /// Agregar sección a un curso
  Future<bool> agregarSeccion(String cursoId, String seccion) async {
    try {
      // Obtener el curso actual
      final curso = await getById(cursoId);

      if (curso == null) {
        return false;
      }

      // Verificar que la sección no exista
      if (curso.secciones.contains(seccion)) {
        return true; // Ya existe, no hace falta agregarla
      }

      // Agregar la nueva sección
      final nuevasSecciones = [...curso.secciones, seccion];

      return await update(
        id: cursoId,
        updates: {'secciones': nuevasSecciones},
      );
    } catch (e) {
      return false;
    }
  }

  /// Eliminar sección de un curso
  Future<bool> eliminarSeccion(String cursoId, String seccion) async {
    try {
      // Obtener el curso actual
      final curso = await getById(cursoId);

      if (curso == null) {
        return false;
      }

      // Eliminar la sección
      final nuevasSecciones = curso.secciones.where((s) => s != seccion).toList();

      // Asegurar que al menos quede una sección
      if (nuevasSecciones.isEmpty) {
        return false;
      }

      return await update(
        id: cursoId,
        updates: {'secciones': nuevasSecciones},
      );
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // STREAMS EN TIEMPO REAL
  // ============================================

  /// Stream de todos los cursos del usuario
  /// Actualizaciones en tiempo real
  Stream<List<Curso>> cursosStream() {
    return streamAll();
  }

  /// Stream del curso activo
  Stream<Curso?> cursoActivoStream() {
    return streamWhere('activo', isEqualTo: true).map((cursos) {
      if (cursos.isEmpty) return null;
      return cursos.first;
    });
  }

  /// Stream de cursos visibles (no ocultos)
  Stream<List<Curso>> cursosVisiblesStream() {
    return streamWhere('oculto', isEqualTo: false);
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Obtener cursos visibles (no ocultos)
  Future<List<Curso>> obtenerCursosVisibles() async {
    try {
      return await getWhere('oculto', isEqualTo: false);
    } catch (e) {
      return [];
    }
  }

  /// Obtener cursos ocultos
  Future<List<Curso>> obtenerCursosOcultos() async {
    try {
      return await getWhere('oculto', isEqualTo: true);
    } catch (e) {
      return [];
    }
  }

  /// Contar total de cursos
  Future<int> contarCursos() async {
    final cursos = await obtenerCursos();
    return cursos.length;
  }
}
