import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Calificación para Firestore
///
/// Representa las calificaciones de estudiantes organizadas por grupos
/// Cada curso puede tener 4 grupos de calificaciones personalizables
class Calificacion {
  final String id;
  final String cursoId;
  final String seccion;

  /// Notas del Grupo 1 (matriz de estudiantes x columnas)
  final List<List<String>> notasGrupo1;

  /// Notas del Grupo 2
  final List<List<String>> notasGrupo2;

  /// Notas del Grupo 3
  final List<List<String>> notasGrupo3;

  /// Notas del Grupo 4
  final List<List<String>> notasGrupo4;

  /// Nombres personalizados de los grupos
  final String nombreGrupo1;
  final String nombreGrupo2;
  final String nombreGrupo3;
  final String nombreGrupo4;

  final DateTime createdAt;
  final DateTime? updatedAt;

  Calificacion({
    required this.id,
    required this.cursoId,
    required this.seccion,
    required this.notasGrupo1,
    required this.notasGrupo2,
    required this.notasGrupo3,
    required this.notasGrupo4,
    this.nombreGrupo1 = 'Grupo 1',
    this.nombreGrupo2 = 'Grupo 2',
    this.nombreGrupo3 = 'Grupo 3',
    this.nombreGrupo4 = 'Grupo 4',
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory para crear desde Firestore
  factory Calificacion.fromFirestore(Map<String, dynamic> data, String id) {
    return Calificacion(
      id: id,
      cursoId: data['curso_id'] ?? '',
      seccion: data['seccion'] ?? '',
      notasGrupo1: parseNotasGrupo(data['notas_grupo_1']),
      notasGrupo2: parseNotasGrupo(data['notas_grupo_2']),
      notasGrupo3: parseNotasGrupo(data['notas_grupo_3']),
      notasGrupo4: parseNotasGrupo(data['notas_grupo_4']),
      nombreGrupo1: data['nombre_grupo_1'] ?? 'Grupo 1',
      nombreGrupo2: data['nombre_grupo_2'] ?? 'Grupo 2',
      nombreGrupo3: data['nombre_grupo_3'] ?? 'Grupo 3',
      nombreGrupo4: data['nombre_grupo_4'] ?? 'Grupo 4',
      createdAt: data['created_at'] != null
          ? (data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now())
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] is Timestamp
              ? (data['updated_at'] as Timestamp).toDate()
              : null)
          : null,
    );
  }

  /// Parsear notas de grupo desde Firestore
  static List<List<String>> parseNotasGrupo(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((row) {
        if (row is List) {
          return row.map((cell) => cell.toString()).toList();
        }
        return <String>[];
      }).toList();
    }

    return [];
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'curso_id': cursoId,
      'seccion': seccion,
      'notas_grupo_1': notasGrupo1,
      'notas_grupo_2': notasGrupo2,
      'notas_grupo_3': notasGrupo3,
      'notas_grupo_4': notasGrupo4,
      'nombre_grupo_1': nombreGrupo1,
      'nombre_grupo_2': nombreGrupo2,
      'nombre_grupo_3': nombreGrupo3,
      'nombre_grupo_4': nombreGrupo4,
    };
  }

  /// Copiar con cambios
  Calificacion copyWith({
    String? id,
    String? cursoId,
    String? seccion,
    List<List<String>>? notasGrupo1,
    List<List<String>>? notasGrupo2,
    List<List<String>>? notasGrupo3,
    List<List<String>>? notasGrupo4,
    String? nombreGrupo1,
    String? nombreGrupo2,
    String? nombreGrupo3,
    String? nombreGrupo4,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Calificacion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      seccion: seccion ?? this.seccion,
      notasGrupo1: notasGrupo1 ?? this.notasGrupo1,
      notasGrupo2: notasGrupo2 ?? this.notasGrupo2,
      notasGrupo3: notasGrupo3 ?? this.notasGrupo3,
      notasGrupo4: notasGrupo4 ?? this.notasGrupo4,
      nombreGrupo1: nombreGrupo1 ?? this.nombreGrupo1,
      nombreGrupo2: nombreGrupo2 ?? this.nombreGrupo2,
      nombreGrupo3: nombreGrupo3 ?? this.nombreGrupo3,
      nombreGrupo4: nombreGrupo4 ?? this.nombreGrupo4,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de Promoción de Grado
/// Representa los datos de promoción matricial (tabla final de calificaciones)
class PromocionGrado {
  final String id;
  final String cursoId;
  final String asignatura;
  final String grado;
  final String docente;

  /// Matriz de datos de promoción (estudiantes x columnas)
  final List<List<String>> datosPromocion;

  final DateTime createdAt;
  final DateTime? updatedAt;

  PromocionGrado({
    required this.id,
    required this.cursoId,
    required this.asignatura,
    required this.grado,
    required this.docente,
    required this.datosPromocion,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory para crear desde Firestore
  factory PromocionGrado.fromFirestore(Map<String, dynamic> data, String id) {
    return PromocionGrado(
      id: id,
      cursoId: data['curso_id'] ?? '',
      asignatura: data['asignatura'] ?? '',
      grado: data['grado'] ?? '',
      docente: data['docente'] ?? '',
      datosPromocion: parseDatosPromocion(data['datos_promocion']),
      createdAt: data['created_at'] != null
          ? (data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now())
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] is Timestamp
              ? (data['updated_at'] as Timestamp).toDate()
              : null)
          : null,
    );
  }

  /// Parsear datos de promoción desde Firestore
  static List<List<String>> parseDatosPromocion(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((row) {
        if (row is List) {
          return row.map((cell) => cell.toString()).toList();
        }
        return <String>[];
      }).toList();
    }

    return [];
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'curso_id': cursoId,
      'asignatura': asignatura,
      'grado': grado,
      'docente': docente,
      'datos_promocion': datosPromocion,
    };
  }

  /// Copiar con cambios
  PromocionGrado copyWith({
    String? id,
    String? cursoId,
    String? asignatura,
    String? grado,
    String? docente,
    List<List<String>>? datosPromocion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromocionGrado(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      asignatura: asignatura ?? this.asignatura,
      grado: grado ?? this.grado,
      docente: docente ?? this.docente,
      datosPromocion: datosPromocion ?? this.datosPromocion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
