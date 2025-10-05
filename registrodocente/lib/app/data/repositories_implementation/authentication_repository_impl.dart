import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../services/supabase_service.dart';

AuthenticationRepository get authenticationRepository =>
    AuthenticationRepositoryImpl();

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final _supabase = SupabaseService.instance;

  @override
  Future<User?> getUserData() async {
    final supabaseUser = _supabase.currentUser;
    if (supabaseUser == null) return null;

    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] ?? '',
    );
  }

  @override
  Future<bool> get isSignedIn async {
    return _supabase.isAuthenticated;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      if (response.user == null) {
        throw Exception('Error al crear la cuenta');
      }

      return User(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: name,
      );
    } catch (e) {
      throw Exception('Error al registrarse: ${e.toString()}');
    }
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      return User(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: response.user!.userMetadata?['name'] ?? '',
      );
    } catch (e) {
      throw Exception('Credenciales incorrectas');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.signOut();
  }
}