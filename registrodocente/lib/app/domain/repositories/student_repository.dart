
// lib/app/domain/repositories/student_repository.dart
import '../models/student_general_info.dart';

abstract class StudentRepository {
  Future<void> saveStudentInfo(StudentGeneralInfo student);
  Future<List<StudentGeneralInfo>> getAllStudents();
}
