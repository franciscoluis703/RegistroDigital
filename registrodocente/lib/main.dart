
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'app/domain/repositories/authentication_repository.dart';
import 'app/domain/repositories/connectivity_repository.dart';
import 'app/data/repositories_implementation/authentication_repository_impl.dart';
import 'app/data/repositories_implementation/connectivity_repository_impl.dart';
import 'app/data/services/supabase_service.dart';
import 'app/core/providers/user_provider.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('⚠️ Error al cargar .env: $e');
    // Continuar sin .env (usará valores por defecto)
  }

  // Inicializar Hive para persistencia local
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('⚠️ Error al inicializar Hive: $e');
  }

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado correctamente');
  } catch (e) {
    debugPrint('⚠️ Error al inicializar Firebase: $e');
    // Firebase opcional para el almacenamiento de imágenes
  }

  // Inicializar Supabase con manejo de errores
  try {
    await SupabaseService.initialize();
    debugPrint('✅ Supabase inicializado correctamente');
  } catch (e) {
    debugPrint('❌ Error al inicializar Supabase: $e');
    // Error al inicializar Supabase - la app continuará sin autenticación
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Injector(
        connectivityRepository: connectivityRepository,
        authenticationRepository: authenticationRepository,
        child: const MyApp(),
      ),
    ),
  );
}


class Injector extends InheritedWidget {
  const Injector({
    super.key,
    required super.child,
    required this.connectivityRepository,
    required this.authenticationRepository,
  });

  final ConnectivityRepository connectivityRepository;
  final AuthenticationRepository authenticationRepository;


  @override
  bool updateShouldNotify(_) => false;


  static Injector of(BuildContext context) {
    final injector = context.dependOnInheritedWidgetOfExactType<Injector>();
    assert(injector != null, 'Injector could not found');
    return injector!;
  }
}