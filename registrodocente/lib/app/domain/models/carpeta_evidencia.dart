class CarpetaEvidencia {
  final String id;
  final String nombre;
  final String? carpetaPadreId; // null si es carpeta raíz
  final String usuarioId;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final String? descripcion;

  CarpetaEvidencia({
    required this.id,
    required this.nombre,
    this.carpetaPadreId,
    required this.usuarioId,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.descripcion,
  });

  factory CarpetaEvidencia.fromJson(Map<String, dynamic> json) {
    return CarpetaEvidencia(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      carpetaPadreId: json['carpeta_padre_id'] as String?,
      usuarioId: json['usuario_id'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaModificacion: json['fecha_modificacion'] != null
          ? DateTime.parse(json['fecha_modificacion'] as String)
          : null,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'carpeta_padre_id': carpetaPadreId,
      'usuario_id': usuarioId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
      'descripcion': descripcion,
    };
  }

  CarpetaEvidencia copyWith({
    String? id,
    String? nombre,
    String? carpetaPadreId,
    String? usuarioId,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    String? descripcion,
  }) {
    return CarpetaEvidencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      carpetaPadreId: carpetaPadreId ?? this.carpetaPadreId,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
