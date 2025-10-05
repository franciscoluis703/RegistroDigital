
// lib/app/domain/models/student_general_info.dart
class StudentGeneralInfo {
  final String nombre;
  final String apellido;
  final String sexo;
  final DateTime fechaNacimiento;
  final String cedula;
  final String rne;
  final String lugarResidencia;
  final String correoElectronico;

  StudentGeneralInfo({
    required this.nombre,
    required this.apellido,
    required this.sexo,
    required this.fechaNacimiento,
    required this.cedula,
    required this.rne,
    required this.lugarResidencia,
    required this.correoElectronico,
  });
}
