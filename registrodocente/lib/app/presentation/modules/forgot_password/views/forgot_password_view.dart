import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_button.dart';
import '../../../widgets/common/dojo_input.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';

/// 🎨 Pantalla de Recuperar Contraseña - Diseño ClassDojo
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = FirebaseAuthService();
      final result = await authService.resetPassword(_emailController.text.trim());

      if (!result['success']) {
        throw Exception(result['message']);
      }

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _emailSent ? _buildSuccessMessage() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono con diseño ClassDojo
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
              Icons.lock_reset,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          // Título con estilo ClassDojo
          Text(
            '¿Olvidaste tu contraseña?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'No te preocupes, te ayudaremos a recuperarla 🔒',
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
                // Instrucciones
                Text(
                  'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Email Input
                DojoInput(
                  label: 'Correo Electrónico',
                  hint: 'tu@correo.com',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleResetPassword(),
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
                const SizedBox(height: 28),

                // Send Button
                DojoButton(
                  text: 'Enviar Enlace',
                  icon: Icons.send,
                  style: DojoButtonStyle.primary,
                  size: DojoButtonSize.large,
                  isFullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Back to Login
          DojoCard(
            style: DojoCardStyle.primary,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Volver al inicio de sesión',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icono de éxito con diseño ClassDojo
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: AppColors.successGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
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
            Icons.check_circle,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),

        // Título
        Text(
          '¡Correo Enviado! 📧',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '¡Todo listo! Revisa tu bandeja de entrada 🎉',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Card con información
        DojoCard(
          style: DojoCardStyle.success,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.mail_outline,
                size: 48,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                'Hemos enviado un enlace de recuperación a:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text.trim(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Por favor revisa tu correo electrónico y sigue las instrucciones.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Botón para volver
        DojoButton(
          text: 'Volver al Inicio de Sesión',
          icon: Icons.login,
          style: DojoButtonStyle.success,
          size: DojoButtonSize.large,
          isFullWidth: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),

        // Nota adicional
        Text(
          'No recibiste el correo? Revisa tu carpeta de spam',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
