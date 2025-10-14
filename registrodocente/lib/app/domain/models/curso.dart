/// Modelo de Curso para Firestore
class Curso {
  final String id;
  final String nombre;
  final String asignatura;
  final List<String> secciones;
  final bool oculto;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Curso({
    required this.id,
    required this.nombre,
    required this.asignatura,
    required this.secciones,
    this.oculto = false,
    this.activo = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Nombre completo del curso (formato: "Nombre - Asignatura")
  String get nombreCompleto => '$nombre - $asignatura';

  /// Factory para crear desde Firestore
  factory Curso.fromFirestore(Map<String, dynamic> data, String id) {
    return Curso(
      id: id,
      nombre: data['nombre'] ?? '',
      asignatura: data['asignatura'] ?? '',
      secciones: data['secciones'] != null
          ? List<String>.from(data['secciones'])
          : ['A'],
      oculto: data['oculto'] ?? false,
      activo: data['activo'] ?? false,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as dynamic).toDate()
          : null,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'asignatura': asignatura,
      'secciones': secciones,
      'oculto': oculto,
      'activo': activo,
    };
  }

  /// Copiar con cambios
  Curso copyWith({
    String? id,
    String? nombre,
    String? asignatura,
    List<String>? secciones,
    bool? oculto,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Curso(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      asignatura: asignatura ?? this.asignatura,
      secciones: secciones ?? this.secciones,
      oculto: oculto ?? this.oculto,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
