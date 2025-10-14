import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Estudiante para Firestore
class Estudiante {
  final String id;
  final String cursoId;
  final String nombre;
  final String? apellido;
  final String? sexo;
  final DateTime? fechaNacimiento;
  final int? edad;
  final String? cedula;
  final String? rne; // Registro Nacional de Estudiantes
  final String? lugarResidencia;
  final String? provincia;
  final String? municipio;
  final String? sector;
  final String? correoElectronico;
  final String? telefono;
  final String? centroEducativo;
  final String? regional;
  final String? distrito;
  final bool repiteGrado;
  final bool nuevoIngreso;
  final bool promovido;
  final String? contactoEmergenciaNombre;
  final String? contactoEmergenciaTelefono;
  final String? contactoEmergenciaParentesco;
  final String? seccion;
  final int numeroOrden;
  final String? fotoUrl;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Estudiante({
    required this.id,
    required this.cursoId,
    required this.nombre,
    this.apellido,
    this.sexo,
    this.fechaNacimiento,
    this.edad,
    this.cedula,
    this.rne,
    this.lugarResidencia,
    this.provincia,
    this.municipio,
    this.sector,
    this.correoElectronico,
    this.telefono,
    this.centroEducativo,
    this.regional,
    this.distrito,
    this.repiteGrado = false,
    this.nuevoIngreso = false,
    this.promovido = false,
    this.contactoEmergenciaNombre,
    this.contactoEmergenciaTelefono,
    this.contactoEmergenciaParentesco,
    this.seccion,
    this.numeroOrden = 0,
    this.fotoUrl,
    this.observaciones,
    required this.createdAt,
    this.updatedAt,
  });

  /// Nombre completo del estudiante
  String get nombreCompleto {
    if (apellido != null && apellido!.isNotEmpty) {
      return '$nombre $apellido';
    }
    return nombre;
  }

  /// Factory para crear desde Firestore
  factory Estudiante.fromFirestore(Map<String, dynamic> data, String id) {
    return Estudiante(
      id: id,
      cursoId: data['curso_id'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'],
      sexo: data['sexo'],
      fechaNacimiento: data['fecha_nacimiento'] != null
          ? (data['fecha_nacimiento'] is Timestamp
              ? (data['fecha_nacimiento'] as Timestamp).toDate()
              : DateTime.tryParse(data['fecha_nacimiento'].toString()))
          : null,
      edad: data['edad'],
      cedula: data['cedula'],
      rne: data['rne'],
      lugarResidencia: data['lugar_residencia'],
      provincia: data['provincia'],
      municipio: data['municipio'],
      sector: data['sector'],
      correoElectronico: data['correo_electronico'],
      telefono: data['telefono'],
      centroEducativo: data['centro_educativo'],
      regional: data['regional'],
      distrito: data['distrito'],
      repiteGrado: data['repite_grado'] ?? false,
      nuevoIngreso: data['nuevo_ingreso'] ?? false,
      promovido: data['promovido'] ?? false,
      contactoEmergenciaNombre: data['contacto_emergencia_nombre'],
      contactoEmergenciaTelefono: data['contacto_emergencia_telefono'],
      contactoEmergenciaParentesco: data['contacto_emergencia_parentesco'],
      seccion: data['seccion'],
      numeroOrden: data['numero_orden'] ?? 0,
      fotoUrl: data['foto_url'],
      observaciones: data['observaciones'],
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

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'curso_id': cursoId,
      'nombre': nombre,
      'apellido': apellido,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento != null
          ? Timestamp.fromDate(fechaNacimiento!)
          : null,
      'edad': edad,
      'cedula': cedula,
      'rne': rne,
      'lugar_residencia': lugarResidencia,
      'provincia': provincia,
      'municipio': municipio,
      'sector': sector,
      'correo_electronico': correoElectronico,
      'telefono': telefono,
      'centro_educativo': centroEducativo,
      'regional': regional,
      'distrito': distrito,
      'repite_grado': repiteGrado,
      'nuevo_ingreso': nuevoIngreso,
      'promovido': promovido,
      'contacto_emergencia_nombre': contactoEmergenciaNombre,
      'contacto_emergencia_telefono': contactoEmergenciaTelefono,
      'contacto_emergencia_parentesco': contactoEmergenciaParentesco,
      'seccion': seccion,
      'numero_orden': numeroOrden,
      'foto_url': fotoUrl,
      'observaciones': observaciones,
    };
  }

  /// Convertir a Map compatible con el formato antiguo
  /// Para compatibilidad con la UI existente
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'sexo': sexo,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'edad': edad,
      'cedula': cedula,
      'rne': rne,
      'lugarResidencia': lugarResidencia,
      'provincia': provincia,
      'municipio': municipio,
      'sector': sector,
      'correoElectronico': correoElectronico,
      'telefono': telefono,
      'centroEducativo': centroEducativo,
      'regional': regional,
      'distrito': distrito,
      'repiteGrado': repiteGrado,
      'nuevoIngreso': nuevoIngreso,
      'promovido': promovido,
      'contactoEmergenciaNombre': contactoEmergenciaNombre,
      'contactoEmergenciaTelefono': contactoEmergenciaTelefono,
      'contactoEmergenciaParentesco': contactoEmergenciaParentesco,
      'seccion': seccion,
      'numeroOrden': numeroOrden,
      'fotoUrl': fotoUrl,
      'observaciones': observaciones,
    };
  }

  /// Factory para crear desde Map (formato antiguo)
  factory Estudiante.fromMap(Map<String, dynamic> map, String cursoId) {
    return Estudiante(
      id: map['id'] ?? '',
      cursoId: cursoId,
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'],
      sexo: map['sexo'],
      fechaNacimiento: map['fechaNacimiento'] != null
          ? DateTime.tryParse(map['fechaNacimiento'].toString())
          : null,
      edad: map['edad'],
      cedula: map['cedula'],
      rne: map['rne'],
      lugarResidencia: map['lugarResidencia'],
      provincia: map['provincia'],
      municipio: map['municipio'],
      sector: map['sector'],
      correoElectronico: map['correoElectronico'],
      telefono: map['telefono'],
      centroEducativo: map['centroEducativo'],
      regional: map['regional'],
      distrito: map['distrito'],
      repiteGrado: map['repiteGrado'] ?? false,
      nuevoIngreso: map['nuevoIngreso'] ?? false,
      promovido: map['promovido'] ?? false,
      contactoEmergenciaNombre: map['contactoEmergenciaNombre'],
      contactoEmergenciaTelefono: map['contactoEmergenciaTelefono'],
      contactoEmergenciaParentesco: map['contactoEmergenciaParentesco'],
      seccion: map['seccion'],
      numeroOrden: map['numeroOrden'] ?? 0,
      fotoUrl: map['fotoUrl'],
      observaciones: map['observaciones'],
      createdAt: DateTime.now(),
    );
  }

  /// Copiar con cambios
  Estudiante copyWith({
    String? id,
    String? cursoId,
    String? nombre,
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
    bool? repiteGrado,
    bool? nuevoIngreso,
    bool? promovido,
    String? contactoEmergenciaNombre,
    String? contactoEmergenciaTelefono,
    String? contactoEmergenciaParentesco,
    String? seccion,
    int? numeroOrden,
    String? fotoUrl,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Estudiante(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      edad: edad ?? this.edad,
      cedula: cedula ?? this.cedula,
      rne: rne ?? this.rne,
      lugarResidencia: lugarResidencia ?? this.lugarResidencia,
      provincia: provincia ?? this.provincia,
      municipio: municipio ?? this.municipio,
      sector: sector ?? this.sector,
      correoElectronico: correoElectronico ?? this.correoElectronico,
      telefono: telefono ?? this.telefono,
      centroEducativo: centroEducativo ?? this.centroEducativo,
      regional: regional ?? this.regional,
      distrito: distrito ?? this.distrito,
      repiteGrado: repiteGrado ?? this.repiteGrado,
      nuevoIngreso: nuevoIngreso ?? this.nuevoIngreso,
      promovido: promovido ?? this.promovido,
      contactoEmergenciaNombre: contactoEmergenciaNombre ?? this.contactoEmergenciaNombre,
      contactoEmergenciaTelefono: contactoEmergenciaTelefono ?? this.contactoEmergenciaTelefono,
      contactoEmergenciaParentesco: contactoEmergenciaParentesco ?? this.contactoEmergenciaParentesco,
      seccion: seccion ?? this.seccion,
      numeroOrden: numeroOrden ?? this.numeroOrden,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
