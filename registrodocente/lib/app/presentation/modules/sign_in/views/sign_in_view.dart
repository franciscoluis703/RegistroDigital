import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/routes.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_button.dart';
import '../../../widgets/common/dojo_input.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';
import '../../../../core/providers/user_provider.dart';

/// 🎨 Pantalla de Inicio de Sesión - Diseño ClassDojo
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = FirebaseAuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final user = _authService.currentUser;

    if (user != null && mounted) {
      // Usuario ya tiene sesión activa, redirigir a home
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Iniciar sesión con Firebase
      final result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!result['success']) {
        throw Exception(result['message']);
      }

      if (mounted) {
        // Cargar datos del usuario en el provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.cargarDatosUsuario();

        // Redirigir a home
        Navigator.of(context).pushReplacementNamed(Routes.home);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido de nuevo! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (!result['success']) {
        throw Exception(result['message']);
      }

      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.cargarDatosUsuario();

        Navigator.of(context).pushReplacementNamed(Routes.home);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo con diseño ClassDojo
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 8,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 6,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Título con estilo ClassDojo
                    Text(
                      'Registro Docente',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¡Bienvenido de nuevo! 👋',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Card contenedor del formulario
                    DojoCard(
                      style: DojoCardStyle.normal,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          // Email Input
                          DojoInput(
                            label: 'Correo Electrónico',
                            hint: 'tu@correo.com',
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo';
                              }
                              if (!value.contains('@')) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Input
                          DojoInput(
                            label: 'Contraseña',
                            hint: 'Tu contraseña segura',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSignIn(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(Routes.forgotPassword);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Sign In Button
                          DojoButton(
                            text: 'Iniciar Sesión',
                            icon: Icons.login,
                            style: DojoButtonStyle.primary,
                            size: DojoButtonSize.large,
                            isFullWidth: true,
                            isLoading: _isLoading,
                            onPressed: _handleSignIn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Divider con texto
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.divider,
                            thickness: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'O continúa con',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: AppColors.divider,
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Google Sign In Button
                    DojoButton(
                      text: 'Google',
                      icon: Icons.g_mobiledata,
                      style: DojoButtonStyle.outlined,
                      size: DojoButtonSize.large,
                      isFullWidth: true,
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 32),

                    // Sign Up Link
                    DojoCard(
                      style: DojoCardStyle.primary,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(Routes.signUp);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            child: Text(
                              'Regístrate aquí',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Version info
                    Text(
                      'Versión 1.0.0 • ClassDojo Style',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
