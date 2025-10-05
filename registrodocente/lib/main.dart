
import 'package:flutter/material.dart';

import 'app/domain/repositories/authentication_repository.dart';
import 'app/domain/repositories/connectivity_repository.dart';
import 'app/data/repositories_implementation/authentication_repository_impl.dart';
import 'app/data/repositories_implementation/connectivity_repository_impl.dart';
import 'app/data/services/supabase_service.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con manejo de errores
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('Error al inicializar Supabase: $e');
    print('La app continuará sin autenticación de Supabase');
  }

  runApp(
    Injector(
      connectivityRepository: connectivityRepository,
      authenticationRepository: authenticationRepository,
      child: const MyApp(),
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