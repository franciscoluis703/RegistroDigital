import 'package:flutter/material.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';
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
    try {
      // Esperar un momento para mostrar el splash
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Verificar si el usuario está autenticado con Firebase
      final authService = FirebaseAuthService();
      final isAuthenticated = authService.isAuthenticated;

      print('🔍 Splash: Usuario autenticado: $isAuthenticated');

      if (isAuthenticated) {
        // Usuario autenticado - ir a Home
        print('➡️ Navegando a Home');
        Navigator.of(context).pushReplacementNamed(Routes.home);
      } else {
        // Usuario no autenticado - ir a Sign In
        print('➡️ Navegando a Sign In');
        Navigator.of(context).pushReplacementNamed(Routes.signIn);
      }
    } catch (e, stackTrace) {
      print('❌ Error en splash: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      // En caso de error, ir al sign in
      Navigator.of(context).pushReplacementNamed(Routes.signIn);
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
              'Registro Digital',
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