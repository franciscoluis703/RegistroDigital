
import 'package:flutter/material.dart';

import '../../../../data/repositories_implementation/connectivity_repository_impl.dart';
import '../../../../domain/repositories/connectivity_repository.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../../app/presentation/routes/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();
    _init();
  }


  Future<void> _init() async {
    ConnectivityRepository connectivityRepository =
        ConnectivityRepositoryImpl();
    final hasInternet = await connectivityRepository.hasInternet;

    // Esperar un momento para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar si el usuario está autenticado
    final supabase = SupabaseService.instance;
    final isAuthenticated = supabase.isAuthenticated;

    if (isAuthenticated) {
      // Usuario autenticado - ir a Home
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
      // Usuario no autenticado - ir a Login (nueva pantalla con Supabase)
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 24),
            Text(
              'Registro Docente',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}