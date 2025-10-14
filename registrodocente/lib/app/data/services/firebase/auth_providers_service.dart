import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Servicio de Gestión de Proveedores de Autenticación
///
/// Permite vincular y desvincular múltiples métodos de acceso:
/// - Email/Contraseña
/// - Google
/// - Facebook
/// - Teléfono
class AuthProvidersService {
  static final AuthProvidersService _instance = AuthProvidersService._internal();
  factory AuthProvidersService() => _instance;
  AuthProvidersService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  // ============================================
  // OBTENER PROVEEDORES VINCULADOS
  // ============================================

  /// Obtener lista de proveedores vinculados al usuario actual
  List<String> getLinkedProviders() {
    if (currentUser == null) return [];

    return currentUser!.providerData.map((info) => info.providerId).toList();
  }

  /// Verificar si un proveedor específico está vinculado
  bool isProviderLinked(String providerId) {
    return getLinkedProviders().contains(providerId);
  }

  /// Obtener información de proveedores disponibles
  Map<String, ProviderInfo> getProvidersInfo() {
    final linked = getLinkedProviders();

    return {
      'password': ProviderInfo(
        providerId: 'password',
        name: 'Correo electrónico/contraseña',
        iconName: 'email',
        isLinked: linked.contains('password'),
      ),
      'google.com': ProviderInfo(
        providerId: 'google.com',
        name: 'Google',
        iconName: 'google',
        isLinked: linked.contains('google.com'),
      ),
      'facebook.com': ProviderInfo(
        providerId: 'facebook.com',
        name: 'Facebook',
        iconName: 'facebook',
        isLinked: linked.contains('facebook.com'),
      ),
      'phone': ProviderInfo(
        providerId: 'phone',
        name: 'Teléfono',
        iconName: 'phone',
        isLinked: linked.contains('phone'),
      ),
    };
  }

  // ============================================
  // VINCULAR PROVEEDORES
  // ============================================

  /// Vincular cuenta de Google
  Future<Map<String, dynamic>> linkGoogleAccount() async {
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }

      // Verificar si ya está vinculado
      if (isProviderLinked('google.com')) {
        return {
          'success': false,
          'message': 'Google ya está vinculado a esta cuenta',
        };
      }

      // Iniciar flujo de Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Inicio de sesión cancelado',
        };
      }

      // Obtener credenciales
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Vincular cuenta
      await currentUser!.linkWithCredential(credential);

      return {
        'success': true,
        'message': 'Google vinculado exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        return {
          'success': false,
          'message': 'Esta cuenta de Google ya está vinculada a otro usuario',
        };
      } else if (e.code == 'provider-already-linked') {
        return {
          'success': false,
          'message': 'Google ya está vinculado a esta cuenta',
        };
      }
      return {
        'success': false,
        'message': 'Error al vincular Google: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al vincular Google: ${e.toString()}',
      };
    }
  }

  /// Vincular cuenta de Facebook
  Future<Map<String, dynamic>> linkFacebookAccount() async {
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }

      // Verificar si ya está vinculado
      if (isProviderLinked('facebook.com')) {
        return {
          'success': false,
          'message': 'Facebook ya está vinculado a esta cuenta',
        };
      }

      // Iniciar flujo de Facebook Sign In
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        return {
          'success': false,
          'message': 'Inicio de sesión con Facebook cancelado',
        };
      }

      // Obtener credenciales
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      // Vincular cuenta
      await currentUser!.linkWithCredential(credential);

      return {
        'success': true,
        'message': 'Facebook vinculado exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        return {
          'success': false,
          'message': 'Esta cuenta de Facebook ya está vinculada a otro usuario',
        };
      } else if (e.code == 'provider-already-linked') {
        return {
          'success': false,
          'message': 'Facebook ya está vinculado a esta cuenta',
        };
      }
      return {
        'success': false,
        'message': 'Error al vincular Facebook: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al vincular Facebook: ${e.toString()}',
      };
    }
  }

  /// Vincular número de teléfono
  /// Nota: Requiere un callback para manejar el código de verificación SMS
  Future<Map<String, dynamic>> linkPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  }) async {
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }

      // Verificar si ya está vinculado
      if (isProviderLinked('phone')) {
        return {
          'success': false,
          'message': 'Ya tienes un teléfono vinculado a esta cuenta',
        };
      }

      // Enviar código de verificación
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verificación (solo en Android)
          try {
            await currentUser!.linkWithCredential(credential);
          } catch (e) {
            // Manejar error
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          // Este error se maneja en el callback
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout
        },
      );

      return {
        'success': true,
        'message': 'Código de verificación enviado',
        'requiresVerification': true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al enviar código: ${e.toString()}',
      };
    }
  }

  /// Completar vinculación de teléfono con código SMS
  Future<Map<String, dynamic>> completeLinkPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }

      // Crear credencial con el código
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Vincular cuenta
      await currentUser!.linkWithCredential(credential);

      return {
        'success': true,
        'message': 'Teléfono vinculado exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return {
          'success': false,
          'message': 'Código de verificación inválido',
        };
      } else if (e.code == 'credential-already-in-use') {
        return {
          'success': false,
          'message': 'Este teléfono ya está vinculado a otro usuario',
        };
      }
      return {
        'success': false,
        'message': 'Error al vincular teléfono: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al vincular teléfono: ${e.toString()}',
      };
    }
  }

  // ============================================
  // DESVINCULAR PROVEEDORES
  // ============================================

  /// Desvincular proveedor
  /// IMPORTANTE: No se puede desvincular el último método de acceso
  Future<Map<String, dynamic>> unlinkProvider(String providerId) async {
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado',
        };
      }

      // Verificar que no sea el último proveedor
      final linkedProviders = getLinkedProviders();
      if (linkedProviders.length <= 1) {
        return {
          'success': false,
          'message': 'No puedes desvincular tu único método de acceso',
        };
      }

      // Verificar que el proveedor esté vinculado
      if (!linkedProviders.contains(providerId)) {
        return {
          'success': false,
          'message': 'Este proveedor no está vinculado',
        };
      }

      // Desvincular
      await currentUser!.unlink(providerId);

      return {
        'success': true,
        'message': 'Proveedor desvinculado exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'no-such-provider') {
        return {
          'success': false,
          'message': 'Este proveedor no está vinculado',
        };
      }
      return {
        'success': false,
        'message': 'Error al desvincular: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al desvincular: ${e.toString()}',
      };
    }
  }

  /// Desvincular Google
  Future<Map<String, dynamic>> unlinkGoogle() async {
    final result = await unlinkProvider('google.com');
    if (result['success']) {
      // Cerrar sesión de Google en el device
      await _googleSignIn.signOut();
    }
    return result;
  }

  /// Desvincular Facebook
  Future<Map<String, dynamic>> unlinkFacebook() async {
    final result = await unlinkProvider('facebook.com');
    if (result['success']) {
      // Cerrar sesión de Facebook en el device
      await FacebookAuth.instance.logOut();
    }
    return result;
  }

  /// Desvincular teléfono
  Future<Map<String, dynamic>> unlinkPhone() async {
    return await unlinkProvider('phone');
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Verificar si el usuario puede desvincular un proveedor
  bool canUnlinkProvider(String providerId) {
    final linked = getLinkedProviders();
    return linked.length > 1 && linked.contains(providerId);
  }

  /// Obtener email del proveedor de email/contraseña
  String? getEmailFromPasswordProvider() {
    if (currentUser == null) return null;

    for (var info in currentUser!.providerData) {
      if (info.providerId == 'password') {
        return info.email;
      }
    }
    return null;
  }

  /// Obtener número de teléfono vinculado
  String? getLinkedPhoneNumber() {
    if (currentUser == null) return null;

    for (var info in currentUser!.providerData) {
      if (info.providerId == 'phone') {
        return info.phoneNumber;
      }
    }
    return null;
  }
}

/// Modelo de información de proveedor
class ProviderInfo {
  final String providerId;
  final String name;
  final String iconName;
  final bool isLinked;

  ProviderInfo({
    required this.providerId,
    required this.name,
    required this.iconName,
    required this.isLinked,
  });
}
