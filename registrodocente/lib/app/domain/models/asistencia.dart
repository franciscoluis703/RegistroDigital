import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Asistencia para Firestore
///
/// Representa los datos de asistencia de estudiantes por mes
/// Incluye matriz de asistencia, feriados y días del mes
class Asistencia {
  final String id;
  final String cursoId;
  final String seccion;
  final String mes;

  /// Matriz de asistencia (estudiantes × días)
  /// Cada celda puede contener: 'P' (Presente), 'A' (Ausente), 'T' (Tardanza), etc.
  final List<List<String>> asistencia;

  /// Mapa de feriados (día → nombre del feriado)
  /// Ejemplo: {1: 'Año Nuevo', 25: 'Navidad'}
  final Map<int, String> feriados;

  /// Lista de días del mes con su nombre
  /// Ejemplo: ['Lun', 'Mar', 'Mié', ...]
  final List<String> diasMes;

  final DateTime createdAt;
  final DateTime? updatedAt;

  Asistencia({
    required this.id,
    required this.cursoId,
    required this.seccion,
    required this.mes,
    required this.asistencia,
    required this.feriados,
    required this.diasMes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory para crear desde Firestore
  factory Asistencia.fromFirestore(Map<String, dynamic> data, String id) {
    return Asistencia(
      id: id,
      cursoId: data['curso_id'] ?? '',
      seccion: data['seccion'] ?? '',
      mes: data['mes'] ?? '',
      asistencia: parseAsistencia(data['asistencia']),
      feriados: parseFeriados(data['feriados']),
      diasMes: parseDiasMes(data['dias_mes']),
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

  /// Parsear matriz de asistencia desde Firestore
  static List<List<String>> parseAsistencia(dynamic data) {
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

  /// Parsear mapa de feriados desde Firestore
  static Map<int, String> parseFeriados(dynamic data) {
    if (data == null) return {};

    if (data is Map) {
      final result = <int, String>{};
      data.forEach((key, value) {
        final intKey = int.tryParse(key.toString());
        if (intKey != null) {
          result[intKey] = value.toString();
        }
      });
      return result;
    }

    return {};
  }

  /// Parsear lista de días del mes desde Firestore
  static List<String> parseDiasMes(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'curso_id': cursoId,
      'seccion': seccion,
      'mes': mes,
      'asistencia': asistencia,
      'feriados': feriados.map((key, value) => MapEntry(key.toString(), value)),
      'dias_mes': diasMes,
    };
  }

  /// Copiar con cambios
  Asistencia copyWith({
    String? id,
    String? cursoId,
    String? seccion,
    String? mes,
    List<List<String>>? asistencia,
    Map<int, String>? feriados,
    List<String>? diasMes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asistencia(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      seccion: seccion ?? this.seccion,
      mes: mes ?? this.mes,
      asistencia: asistencia ?? this.asistencia,
      feriados: feriados ?? this.feriados,
      diasMes: diasMes ?? this.diasMes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de Registro de Meses
/// Representa la configuración de meses para un curso
class RegistroMeses {
  final String id;
  final String cursoId;
  final String seccion;

  /// Lista de meses configurados
  /// Ejemplo: [{'mes': 'Enero', 'materia': 'Matemáticas', 'seccion': 'A'}, ...]
  final List<Map<String, dynamic>> registros;

  final DateTime createdAt;
  final DateTime? updatedAt;

  RegistroMeses({
    required this.id,
    required this.cursoId,
    required this.seccion,
    required this.registros,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory para crear desde Firestore
  factory RegistroMeses.fromFirestore(Map<String, dynamic> data, String id) {
    return RegistroMeses(
      id: id,
      cursoId: data['curso_id'] ?? '',
      seccion: data['seccion'] ?? '',
      registros: parseRegistros(data['registros']),
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

  /// Parsear lista de registros desde Firestore
  static List<Map<String, dynamic>> parseRegistros(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    return [];
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'curso_id': cursoId,
      'seccion': seccion,
      'registros': registros,
    };
  }

  /// Copiar con cambios
  RegistroMeses copyWith({
    String? id,
    String? cursoId,
    String? seccion,
    List<Map<String, dynamic>>? registros,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegistroMeses(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      seccion: seccion ?? this.seccion,
      registros: registros ?? this.registros,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
