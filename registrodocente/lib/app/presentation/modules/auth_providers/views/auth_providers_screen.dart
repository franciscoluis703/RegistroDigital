import 'package:flutter/material.dart';
import '../../../../data/services/firebase/auth_providers_service.dart';

class AuthProvidersScreen extends StatefulWidget {
  const AuthProvidersScreen({super.key});

  @override
  State<AuthProvidersScreen> createState() => _AuthProvidersScreenState();
}

class _AuthProvidersScreenState extends State<AuthProvidersScreen> {
  final _authProvidersService = AuthProvidersService();
  bool _isLoading = false;
  String? _verificationId; // Para el flujo de teléfono

  @override
  Widget build(BuildContext context) {
    final providers = _authProvidersService.getProvidersInfo();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Acceso'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado informativo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vincula múltiples métodos de acceso para mayor seguridad y flexibilidad',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título de sección
                  const Text(
                    'Proveedores Disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email/Contraseña
                  _buildProviderCard(
                    provider: providers['password']!,
                    icon: Icons.email,
                    color: Colors.blue,
                    onLink: null, // No se puede vincular email/contraseña desde aquí
                    onUnlink: () => _unlinkProvider('password', 'Email/Contraseña'),
                  ),
                  const SizedBox(height: 12),

                  // Google
                  _buildProviderCard(
                    provider: providers['google.com']!,
                    icon: Icons.g_mobiledata,
                    color: Colors.red,
                    onLink: _linkGoogle,
                    onUnlink: () => _unlinkProvider('google.com', 'Google'),
                  ),
                  const SizedBox(height: 12),

                  // Facebook
                  _buildProviderCard(
                    provider: providers['facebook.com']!,
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onLink: _linkFacebook,
                    onUnlink: () => _unlinkProvider('facebook.com', 'Facebook'),
                  ),
                  const SizedBox(height: 12),

                  // Teléfono
                  _buildProviderCard(
                    provider: providers['phone']!,
                    icon: Icons.phone,
                    color: Colors.green,
                    onLink: _linkPhone,
                    onUnlink: () => _unlinkProvider('phone', 'Teléfono'),
                  ),
                  const SizedBox(height: 24),

                  // Advertencia de seguridad
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Debes mantener al menos un método de acceso vinculado',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProviderCard({
    required ProviderInfo provider,
    required IconData icon,
    required Color color,
    required VoidCallback? onLink,
    required VoidCallback? onUnlink,
  }) {
    final canUnlink = _authProvidersService.canUnlinkProvider(provider.providerId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: provider.isLinked
            ? Border.all(color: color.withOpacity(0.5), width: 2)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          provider.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          provider.isLinked ? 'Habilitada' : 'No vinculada',
          style: TextStyle(
            color: provider.isLinked ? Colors.green : Colors.grey,
            fontSize: 13,
          ),
        ),
        trailing: provider.isLinked
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Vinculada',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canUnlink) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.link_off, color: Colors.red),
                      onPressed: onUnlink,
                      tooltip: 'Desvincular',
                    ),
                  ],
                ],
              )
            : ElevatedButton.icon(
                onPressed: onLink,
                icon: const Icon(Icons.link),
                label: const Text('Vincular'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================
  // VINCULAR PROVEEDORES
  // ============================================

  Future<void> _linkGoogle() async {
    setState(() => _isLoading = true);

    final result = await _authProvidersService.linkGoogleAccount();

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }

    if (result['success']) {
      setState(() {}); // Refrescar UI
    }
  }

  Future<void> _linkFacebook() async {
    setState(() => _isLoading = true);

    final result = await _authProvidersService.linkFacebookAccount();

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }

    if (result['success']) {
      setState(() {}); // Refrescar UI
    }
  }

  Future<void> _linkPhone() async {
    final phoneController = TextEditingController();

    // Mostrar diálogo para ingresar teléfono
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular Teléfono'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu número de teléfono con código de país',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Número de teléfono',
                hintText: '+1 123 456 7890',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar Código'),
          ),
        ],
      ),
    );

    if (confirmar != true || phoneController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final result = await _authProvidersService.linkPhoneNumber(
      phoneNumber: phoneController.text,
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        _showVerificationCodeDialog();
      },
    );

    if (!result['requiresVerification']) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showVerificationCodeDialog() async {
    final codeController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Código de Verificación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el código que recibiste por SMS',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código',
                hintText: '123456',
                prefixIcon: Icon(Icons.sms),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verificar'),
          ),
        ],
      ),
    );

    if (confirmar != true || codeController.text.isEmpty || _verificationId == null) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authProvidersService.completeLinkPhoneNumber(
      verificationId: _verificationId!,
      smsCode: codeController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }

    if (result['success']) {
      setState(() {}); // Refrescar UI
    }
  }

  // ============================================
  // DESVINCULAR PROVEEDORES
  // ============================================

  Future<void> _unlinkProvider(String providerId, String providerName) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desvinculación'),
        content: Text(
          '¿Estás seguro de que deseas desvincular $providerName?\n\n'
          'Podrás volver a vincularlo en cualquier momento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> result;

    switch (providerId) {
      case 'google.com':
        result = await _authProvidersService.unlinkGoogle();
        break;
      case 'facebook.com':
        result = await _authProvidersService.unlinkFacebook();
        break;
      case 'phone':
        result = await _authProvidersService.unlinkPhone();
        break;
      default:
        result = await _authProvidersService.unlinkProvider(providerId);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }

    if (result['success']) {
      setState(() {}); // Refrescar UI
    }
  }
}
