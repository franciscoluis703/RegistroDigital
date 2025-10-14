import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';
import '../../../routes/routes.dart';

/// 🎨 Pantalla de Splash - Diseño ClassDojo
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
    _init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      // Esperar a que termine la animación inicial
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.tertiary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animado con diseño ClassDojo
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 90,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Nombre de la app
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      'Registro Docente',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtítulo
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      'Tu asistente educativo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Loading indicator
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Texto de carga
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      'Cargando...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
