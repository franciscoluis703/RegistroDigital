
// lib/app/data/repositories_implementation/student_repository_impl.dart
import '../../domain/models/student_general_info.dart';
import '../../domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final List<StudentGeneralInfo> _students = [];

  @override
  Future<void> saveStudentInfo(StudentGeneralInfo student) async {
    _students.add(student);
    // Aquí puedes agregar persistencia en DB o API si quieres
  }

  @override
  Future<List<StudentGeneralInfo>> getAllStudents() async {
    return _students;
  }
}
