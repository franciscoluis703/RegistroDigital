class FotoEvidencia {
  final String id;
  final String nombre;
  final String carpetaId;
  final String usuarioId;
  final String urlFoto;
  final String? descripcion;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final int? tamanioBytes;
  final String? tipoMime;

  FotoEvidencia({
    required this.id,
    required this.nombre,
    required this.carpetaId,
    required this.usuarioId,
    required this.urlFoto,
    this.descripcion,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.tamanioBytes,
    this.tipoMime,
  });

  factory FotoEvidencia.fromJson(Map<String, dynamic> json) {
    return FotoEvidencia(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      carpetaId: json['carpeta_id'] as String,
      usuarioId: json['usuario_id'] as String,
      urlFoto: json['url_foto'] as String,
      descripcion: json['descripcion'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaModificacion: json['fecha_modificacion'] != null
          ? DateTime.parse(json['fecha_modificacion'] as String)
          : null,
      tamanioBytes: json['tamanio_bytes'] as int?,
      tipoMime: json['tipo_mime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'carpeta_id': carpetaId,
      'usuario_id': usuarioId,
      'url_foto': urlFoto,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
      'tamanio_bytes': tamanioBytes,
      'tipo_mime': tipoMime,
    };
  }

  FotoEvidencia copyWith({
    String? id,
    String? nombre,
    String? carpetaId,
    String? usuarioId,
    String? urlFoto,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    int? tamanioBytes,
    String? tipoMime,
  }) {
    return FotoEvidencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      carpetaId: carpetaId ?? this.carpetaId,
      usuarioId: usuarioId ?? this.usuarioId,
      urlFoto: urlFoto ?? this.urlFoto,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      tamanioBytes: tamanioBytes ?? this.tamanioBytes,
      tipoMime: tipoMime ?? this.tipoMime,
    );
  }
}
