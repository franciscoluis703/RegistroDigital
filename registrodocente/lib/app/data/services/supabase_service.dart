import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  

  /// Inicializar Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;
  }

  /// Obtener cliente de Supabase
  SupabaseClient? get client {
    return _client;
  }

  /// Verificar si Supabase está disponible
  bool get isAvailable => _client != null;

  /// Auth helpers
  User? get currentUser => client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// Sign in
  Future<AuthResponse> signIn(String email, String password) async {
    if (client == null) {
      throw Exception('Supabase no está disponible');
    }
    return await client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up
  Future<AuthResponse> signUp(String email, String password) async {
    if (client == null) {
      throw Exception('Supabase no está disponible');
    }
    return await client!.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    if (client == null) {
      throw Exception('Supabase no está disponible');
    }
    await client!.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    if (client == null) {
      throw Exception('Supabase no está disponible');
    }
    await client!.auth.resetPasswordForEmail(email);
  }
}
