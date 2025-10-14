import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_button.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../widgets/common/dojo_input.dart';
import '../../../widgets/common/dojo_badge.dart';

/// 🎨 Pantalla de Demostración del Sistema de Diseño
///
/// Muestra todos los componentes personalizados en acción.
/// Útil para desarrollo, pruebas y documentación visual.
class DesignShowcaseScreen extends StatefulWidget {
  const DesignShowcaseScreen({super.key});

  @override
  State<DesignShowcaseScreen> createState() => _DesignShowcaseScreenState();
}

class _DesignShowcaseScreenState extends State<DesignShowcaseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sistema de Diseño ClassDojo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Text(
              '🎨 Componentes Personalizados',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sistema de diseño inspirado en ClassDojo',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Sección: Botones
            _buildSection(
              context,
              title: 'Botones (DojoButton)',
              children: [
                DojoButton(
                  text: 'Primary Button',
                  style: DojoButtonStyle.primary,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DojoButton(
                  text: 'Secondary Button',
                  style: DojoButtonStyle.secondary,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DojoButton(
                  text: 'Success Button',
                  icon: Icons.check_circle,
                  style: DojoButtonStyle.success,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DojoButton(
                  text: 'Warning Button',
                  icon: Icons.warning,
                  style: DojoButtonStyle.warning,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DojoButton(
                  text: 'Outlined Button',
                  style: DojoButtonStyle.outlined,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DojoButton(
                  text: 'Text Button',
                  style: DojoButtonStyle.text,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DojoButton(
                  text: 'Loading...',
                  style: DojoButtonStyle.primary,
                  isLoading: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DojoButton(
                  text: 'Full Width Button',
                  icon: Icons.arrow_forward,
                  style: DojoButtonStyle.primary,
                  isFullWidth: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DojoButton(
                        text: 'Small',
                        style: DojoButtonStyle.primary,
                        size: DojoButtonSize.small,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DojoButton(
                        text: 'Medium',
                        style: DojoButtonStyle.primary,
                        size: DojoButtonSize.medium,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DojoButton(
                        text: 'Large',
                        style: DojoButtonStyle.primary,
                        size: DojoButtonSize.large,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sección: Cards
            _buildSection(
              context,
              title: 'Cards (DojoCard)',
              children: [
                DojoCard(
                  style: DojoCardStyle.normal,
                  child: _buildCardContent('Normal Card'),
                ),
                const SizedBox(height: 12),
                DojoCard(
                  style: DojoCardStyle.primary,
                  child: _buildCardContent('Primary Card'),
                ),
                const SizedBox(height: 12),
                DojoCard(
                  style: DojoCardStyle.secondary,
                  child: _buildCardContent('Secondary Card'),
                ),
                const SizedBox(height: 12),
                DojoCard(
                  style: DojoCardStyle.success,
                  child: _buildCardContent('Success Card'),
                ),
                const SizedBox(height: 12),
                DojoCard(
                  style: DojoCardStyle.warning,
                  child: _buildCardContent('Warning Card'),
                ),
                const SizedBox(height: 12),
                DojoCard(
                  style: DojoCardStyle.error,
                  child: _buildCardContent('Error Card'),
                ),
                const SizedBox(height: 12),
                DojoCard(
                  style: DojoCardStyle.gradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gradient Card',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Con gradiente decorativo azul',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DojoCard(
                  style: DojoCardStyle.celebration,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Card presionada!')),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Celebration Card',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          const Spacer(),
                          const Icon(Icons.celebration, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Con gradiente rosa a naranja (presiona para probar)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sección: Inputs
            _buildSection(
              context,
              title: 'Inputs (DojoInput)',
              children: [
                DojoInput(
                  label: 'Nombre Completo',
                  hint: 'Escribe tu nombre',
                  prefixIcon: Icons.person,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                DojoInput(
                  label: 'Correo Electrónico',
                  hint: 'tu@correo.com',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  helper: 'Usaremos tu correo para notificaciones',
                ),
                const SizedBox(height: 16),
                DojoInput(
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  prefixIcon: Icons.lock,
                  suffixIcon: Icons.visibility_off,
                  obscureText: true,
                  onSuffixIconPressed: () {},
                ),
                const SizedBox(height: 16),
                DojoInput(
                  label: 'Campo con Error',
                  hint: 'Este campo tiene un error',
                  prefixIcon: Icons.error_outline,
                  error: 'Este es un mensaje de error',
                ),
                const SizedBox(height: 16),
                DojoInput(
                  label: 'Comentarios',
                  hint: 'Escribe tus comentarios aquí...',
                  maxLines: 4,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sección: Badges
            _buildSection(
              context,
              title: 'Badges (DojoBadge)',
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    const DojoBadge(
                      text: 'Primary',
                      style: DojoBadgeStyle.primary,
                    ),
                    const DojoBadge(
                      text: 'Secondary',
                      style: DojoBadgeStyle.secondary,
                    ),
                    const DojoBadge(
                      text: 'Success',
                      style: DojoBadgeStyle.success,
                      icon: Icons.check,
                    ),
                    const DojoBadge(
                      text: 'Warning',
                      style: DojoBadgeStyle.warning,
                      icon: Icons.warning,
                    ),
                    const DojoBadge(
                      text: 'Error',
                      style: DojoBadgeStyle.error,
                      icon: Icons.error,
                    ),
                    const DojoBadge(
                      text: 'Info',
                      style: DojoBadgeStyle.info,
                      icon: Icons.info,
                    ),
                    const DojoBadge(
                      text: 'Primary Light',
                      style: DojoBadgeStyle.primaryLight,
                    ),
                    const DojoBadge(
                      text: 'Secondary Light',
                      style: DojoBadgeStyle.secondaryLight,
                    ),
                    const DojoBadge(
                      text: 'Outlined',
                      style: DojoBadgeStyle.outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Tamaños:'),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DojoBadge(
                      text: 'Small',
                      style: DojoBadgeStyle.primary,
                      size: DojoBadgeSize.small,
                    ),
                    DojoBadge(
                      text: 'Medium',
                      style: DojoBadgeStyle.primary,
                      size: DojoBadgeSize.medium,
                    ),
                    DojoBadge(
                      text: 'Large',
                      style: DojoBadgeStyle.primary,
                      size: DojoBadgeSize.large,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sección: Colores
            _buildSection(
              context,
              title: 'Paleta de Colores',
              children: [
                _buildColorRow('Primary', AppColors.primary),
                _buildColorRow('Secondary', AppColors.secondary),
                _buildColorRow('Tertiary', AppColors.tertiary),
                _buildColorRow('Accent', AppColors.accent),
                _buildColorRow('Success', AppColors.success),
                _buildColorRow('Warning', AppColors.warning),
                _buildColorRow('Error', AppColors.error),
                _buildColorRow('Info', AppColors.info),
              ],
            ),

            const SizedBox(height: 32),

            // Sección: Tipografía
            _buildSection(
              context,
              title: 'Tipografía (Nunito)',
              children: [
                Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 8),
                Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildCardContent(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Esta es una card con el estilo "$title". Puedes presionarla para ver el efecto hover.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
