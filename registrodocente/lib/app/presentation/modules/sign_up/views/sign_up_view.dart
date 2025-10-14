import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/routes.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_button.dart';
import '../../../widgets/common/dojo_input.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';
import '../../../../core/providers/user_provider.dart';

/// 🎨 Pantalla de Registro - Diseño ClassDojo
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = FirebaseAuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Registrar usuario con Firebase
      final result = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombreCompleto: _nameController.text.trim(),
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
            content: Text('¡Cuenta creada exitosamente! Bienvenido 🎉'),
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
                        gradient: AppColors.secondaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.4),
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
                        Icons.school,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Título con estilo ClassDojo
                    Text(
                      'Crear Cuenta',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¡Únete a nuestra comunidad! 🎓',
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
                          // Nombre Input
                          DojoInput(
                            label: 'Nombre Completo',
                            hint: 'Tu nombre completo',
                            prefixIcon: Icons.person_outline,
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              if (value.length < 3) {
                                return 'El nombre debe tener al menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

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
                            hint: 'Mínimo 6 caracteres',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Input
                          DojoInput(
                            label: 'Confirmar Contraseña',
                            hint: 'Repite tu contraseña',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconPressed: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSignUp(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Sign Up Button
                          DojoButton(
                            text: 'Crear Cuenta',
                            icon: Icons.person_add,
                            style: DojoButtonStyle.secondary,
                            size: DojoButtonSize.large,
                            isFullWidth: true,
                            isLoading: _isLoading,
                            onPressed: _handleSignUp,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign In Link
                    DojoCard(
                      style: DojoCardStyle.primary,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(Routes.signIn);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            child: Text(
                              'Inicia sesión aquí',
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
