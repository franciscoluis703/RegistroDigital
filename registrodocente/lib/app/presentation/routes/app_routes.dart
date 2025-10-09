

import 'package:flutter/material.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/sign_in/views/sign_in_view.dart';
import '../modules/sign_up/views/sign_up_view.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/student/general_info/views/general_info_screen.dart';
import '../modules/student/centro_educativo/views/centro_educativo_screen.dart';
import '../modules/student/general_student/views/general_student_screen.dart';
import '../modules/student/condicion_inicial/views/condicion_inicial_screen.dart';
import '../modules/student/emergency_data/views/emergency_data_screen.dart';
import '../modules/student/parentesco/views/parentesco_screen.dart';
import '../modules/cursos/views/cursos_screen.dart';
import '../modules/curso_detalle/views/curso_detalle_screen.dart';
import '../modules/perfil/views/perfil_screen.dart';
import '../modules/asistencia/views/asistencia_screen.dart';
import '../modules/asistencia_evaluaciones/views/asistencia_evaluaciones_screen.dart';
import '../modules/asistencias_menu/views/asistencias_menu_screen.dart';
import '../modules/calificaciones/views/calificaciones_screen.dart';
import '../modules/promocion_grado/views/promocion_grado_screen.dart';
import '../modules/calendario_escolar/views/calendario_escolar_screen.dart';
import '../modules/horario_clase/views/horario_clase_screen.dart';
import '../modules/notas/views/notas_screen.dart';
import 'routes.dart';


Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    Routes.splash: (context) => const SplashView(),
    Routes.login: (context) => const LoginScreen(),  // Nueva ruta con Supabase
    Routes.signIn: (context) => const SignInView(),
    Routes.signUp: (context) => const SignUpView(),
    Routes.forgotPassword: (context) => const ForgotPasswordView(),
    Routes.home: (context) => const HomeScreen(),
    Routes.generalInfo: (context) => const GeneralInfoScreen(),
    Routes.centroEducativo: (context) => const CentroEducativoScreen(),
    Routes.generalStudent: (context) => const GeneralStudentScreen(),
    Routes.condicionInicial: (context) => const CondicionInicialScreen(),
    Routes.emergencyData: (context) => const EmergencyDataScreen(),
    Routes.parentesco: (context) => const ParentescoScreen(),
    Routes.cursos: (context) => const CursosScreen(),
    Routes.cursoDetalle: (context) => const CursoDetalleScreen(),
    Routes.perfil: (context) => const PerfilScreen(),
    Routes.asistencia: (context) => const AsistenciaScreen(),
    Routes.asistenciaEvaluaciones: (context) => const AsistenciaEvaluacionesScreen(),
    Routes.asistenciasMenu: (context) => const AsistenciasMenuScreen(),
    Routes.calificaciones: (context) => const CalificacionesScreen(),
    Routes.promocionGrado: (context) => const PromocionGradoScreen(),
    Routes.calendarioEscolar: (context) => const CalendarioEscolarScreen(),
    Routes.horarioClase: (context) => const HorarioClaseScreen(),
    Routes.notas: (context) => const NotasScreen(),
  };
}